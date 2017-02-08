//
//  ZCYSessionManager.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/25.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYSessionManager.h"
#import "ZCYURLRequestSerialization.h"

__unused static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t zcy_url_session_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zcy_url_session_manager_creation_queue = dispatch_queue_create("me.chaoyang805.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    return zcy_url_session_manager_creation_queue;
}

static dispatch_queue_t url_session_manager_processing_queue() {
    static dispatch_queue_t zcy_url_session_manager_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zcy_url_session_manager_processing_queue = dispatch_queue_create("me.chaoyang805.session.manager.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return zcy_url_session_manager_processing_queue;
}

static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t zcy_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zcy_url_session_manager_completion_group = dispatch_group_create();
    });
    return zcy_url_session_manager_completion_group;
}

NSString * const ZCYNetworkTaskDidResumeNotification = @"me.chaoyang805.task.resume";
NSString * const ZCYNetworkTaskDidCompleteNotification = @"me.chaoyang805.task.complete";
NSString * const ZCYNetworkTaskDidSuspendNotification = @"me.chaoyang805.task.suspend";
NSString * const ZCYURLSessionDidInvalidateNotification = @"me.chaoyang805.session.invalidate";
NSString * const ZCYURLSessionDownloadTaskDidFailToMoveFileNotification = @"me.chaoyang805.session.download.file-manager-error";

NSString * const ZCYNetworkTaskDidCompleteSerializedResponseKey = @"me.chaoyang805.task.complete.serializedresponse";
NSString * const ZCYNetworkTaskDidCompleteResponseSerializerKey = @"me.chaoyang805.task.complete.responseserializer";
NSString * const ZCYNetworkTaskDidCompleteResponseDataKey = @"me.chaoyang805.task.complete.finish.responsedata";
NSString * const ZCYNetworkTaskDidCompleteErrorKey = @"me.chaoyang805.task.complete.error";
NSString * const ZCYNetworkTaskDidCompleteAssetPathKey = @"me.chaoyang805.task.complete.assetpath";

static NSString * const ZCYURLSessionManagerLockName = @"me.chaoyang805.session.manager.lock";

typedef void(^ZCYSessionTaskCompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);
typedef void(^ZCYURLSessionDidBecomeInvalidBlock)(NSURLSession *session, NSError *error);
typedef NSURLSessionAuthChallengeDisposition (^ZCYURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
typedef NSURLRequest * (^ZCYURLSessionTaskWillPerformHTTPRedirectionBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request);
typedef NSURLSessionAuthChallengeDisposition (^ZCYURLSessionTaskDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential);
typedef void(^ZCYURLSessionDidFinishEventsForBackgroundURLSessionBlock)(NSURLSession *session);
typedef NSInputStream * (^ZCYURLTaskNeedNewBodyStreamBlock)(NSURLSession *session, NSURLSessionTask *task);
typedef void(^ZCYURLSessionTaskDidSendBodyDataBlock)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend);
typedef void(^ZCYURLSessionTaskDidCompleteBlock)(NSURLSession *session, NSURLSessionTask *task, NSError *error);
typedef NSURLSessionResponseDisposition (^ZCYURLSessionDataTaskDidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);
typedef void (^ZCYURLSessionDataTaskDidBecomeDownloadTaskBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
typedef void (^ZCYURLSessionDataTaskDidReceiveData)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
typedef NSCachedURLResponse * (^ZCYURLSessionDataTaskWillCacheResponse)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse);
typedef NSURL * (^ZCYURLSessionDownloadTaskDidFinishDownloading)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location);
typedef void (^ZCYURLSessionDownloadTaskDidWriteDataBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^ZCYURLSessionDownloadTaskDidResumeBlock)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes);

@interface ZCYSessionManagerTaskDelegate : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, weak) ZCYSessionManager *manager;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, copy) ZCYSessionTaskCompletionHandler completionHandler;

@end

@implementation ZCYSessionManagerTaskDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mutableData = [NSMutableData data];
    }
    return self;
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    __strong ZCYSessionManager *manager = self.manager;
    
    __block id responseObject = nil;
    
    __block NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[ZCYNetworkTaskDidCompleteResponseSerializerKey] = manager.responseSerializer;
    
    NSData *data = nil;
    if (self.mutableData) {
        data = [self.mutableData copy];
        self.mutableData = nil;
    }
    
    // TODO downloadFileURL
    if (data) {
        userInfo[ZCYNetworkTaskDidCompleteResponseDataKey] = data;
    }
    
    if (error) {
        userInfo[ZCYNetworkTaskDidCompleteErrorKey] = error;
        dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
            if (self.completionHandler) {
                self.completionHandler(task.response, responseObject, error);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:ZCYNetworkTaskDidCompleteNotification object:task userInfo:userInfo];
            });
        });
    } else {
        
        dispatch_async(url_session_manager_processing_queue(), ^{
            NSError *serializationError = nil;
            
            responseObject = [manager.responseSerializer responseObjectForResponse:task.response data:data error:&serializationError];
            
            if (responseObject) {
                userInfo[ZCYNetworkTaskDidCompleteSerializedResponseKey] = responseObject;
            }
            
            dispatch_group_async(manager.completionGroup ?: url_session_manager_completion_group(), manager.completionQueue ?: dispatch_get_main_queue(), ^{
                if (self.completionHandler) {
                    self.completionHandler(task.response, responseObject, serializationError);
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:ZCYNetworkTaskDidCompleteNotification object:task userInfo:userInfo];
                });
            });
        });
        
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.mutableData appendData:data];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    // TODO move downloaded file
}

@end

#pragma mark ZCYSessionManager

@interface ZCYSessionManager ()

@property (readonly, nonatomic, copy) NSString *taskDescriptionForSessionTasks;

@property (readwrite, nonatomic, strong) NSLock *lock;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mutableTaskDelegatesKeyedByTaskIdentifier;

@property (readwrite, nonatomic, copy) ZCYURLSessionDidBecomeInvalidBlock sessionDidBecomInvalid;
@property (readwrite, nonatomic, copy) ZCYURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;
@property (readwrite, nonatomic, copy) ZCYURLSessionTaskWillPerformHTTPRedirectionBlock taskWillPerformHTTPRedirection;
@property (readwrite, nonatomic, copy) ZCYURLSessionTaskDidReceiveAuthenticationChallengeBlock taskDidReceiveAuthenticationChallenge;
@property (readwrite, nonatomic, copy) ZCYURLTaskNeedNewBodyStreamBlock taskNeedNewBodyStream;
@property (readwrite, nonatomic, copy) ZCYURLSessionTaskDidSendBodyDataBlock taskDidSendBodyData;
@property (readwrite, nonatomic, copy) ZCYURLSessionTaskDidCompleteBlock taskDidComplete;
@property (readwrite, nonatomic, copy) ZCYURLSessionDataTaskDidReceiveResponseBlock dataTaskDidReceiveResponse;
@property (readwrite, nonatomic, copy) ZCYURLSessionDataTaskDidBecomeDownloadTaskBlock dataTaskDidBecomeDownloadTask;
@property (readwrite, nonatomic, copy) ZCYURLSessionDataTaskDidReceiveData dataTaskDidReceiveData;
@property (readwrite, nonatomic, copy) ZCYURLSessionDataTaskWillCacheResponse dataTaskWillCacheResponse;
@property (readwrite, nonatomic, copy) ZCYURLSessionDidFinishEventsForBackgroundURLSessionBlock didFinishEventsForBackgroundURLSession;
@property (readwrite, nonatomic, copy) ZCYURLSessionDownloadTaskDidFinishDownloading downloadTaskDidFinishDownloading;
@property (readwrite, nonatomic, copy) ZCYURLSessionDownloadTaskDidWriteDataBlock downloadTaskDidWriteData;
@property (readwrite, nonatomic, copy) ZCYURLSessionDownloadTaskDidResumeBlock downloadTaskDidResume;

@end

@implementation ZCYSessionManager

- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    if (!configuration) {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    self.sessionConfiguration = configuration;
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.operationQueue.maxConcurrentOperationCount = 1;
    
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.operationQueue];
    
    self.lock = [[NSLock alloc] init];
    self.lock.name = ZCYURLSessionManagerLockName;
    
    self.mutableTaskDelegatesKeyedByTaskIdentifier = [NSMutableDictionary dictionary];
    
    self.responseSerializer = [ZCYJSONResponseSerializer serializer];
    // TODO securityPolicy
    // TODO reachabilityManager
    
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        
        for (NSURLSessionDataTask *dataTask in dataTasks) {
            [self addDelegateForTask:dataTask completionHandler:nil];
        }
        
        for (NSURLSessionUploadTask * __unused uploadTask in uploadTasks) {
            // TODO addDelegateForUploadTask
        }
        
        for (NSURLSessionDownloadTask * __unused downloadTask in downloadTasks) {
            // TODO addDelegateForDownloadTask
        }
    }];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSURLSessionDataTask *dataTask;
    dataTask = [self.session dataTaskWithRequest:request];
    
    // TODO add delegate
    [self addDelegateForTask:dataTask completionHandler:completionHandler];
    return dataTask;
}

- (NSString *)taskDescriptionForSessionTasks {
    return [NSString stringWithFormat:@"%p", self];
}

- (void)addDelegateForTask:(NSURLSessionDataTask *)dataTask
         completionHandler:(void (^)(NSURLResponse * response, id responseObject, NSError *error))completionHandler {
    ZCYSessionManagerTaskDelegate *delegate = [[ZCYSessionManagerTaskDelegate alloc] init];
    
    delegate.completionHandler = completionHandler;
    delegate.manager = self;
    
    [self setDelegate:delegate forTask:dataTask];
    
}

- (ZCYSessionManagerTaskDelegate *)delegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    ZCYSessionManagerTaskDelegate * delegate = nil;
    [self.lock lock];
    delegate = self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    return delegate;
}

- (void)setDelegate:(ZCYSessionManagerTaskDelegate *)delegate forTask:(NSURLSessionTask *)task {
    NSParameterAssert(delegate);
    NSParameterAssert(task);
    [self.lock lock];
    self.mutableTaskDelegatesKeyedByTaskIdentifier[@(task.taskIdentifier)] = delegate;
    // TODO addNotificationObserverForTask
    [self.lock unlock];
    
}

- (void)removeDelegateForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    [self.lock lock];
    
    // TODO removeProgressForTask
    // TODO removeNotificationForTask
    [self.mutableTaskDelegatesKeyedByTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

#pragma mark - 

- (NSArray<NSURLSessionTask *> *)tasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray<NSURLSessionDataTask *> *)dataTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray<NSURLSessionUploadTask *> *)uploadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray<NSURLSessionDownloadTask *> *)downloadTasks {
    return [self tasksForKeyPath:NSStringFromSelector(_cmd)];
}

- (NSArray<__kindof NSURLSessionTask *> *)tasksForKeyPath:(NSString *)keyPath {
    
    __block NSArray *tasks = nil;
    
    [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"unionOfArrays.self"];
        }
    }];
    return tasks;
}

#pragma mark - NSURLSessionDelegateBlock

- (void)setSessionDidBecomInvalidBlock:(ZCYURLSessionDidBecomeInvalidBlock)block {
    self.sessionDidBecomInvalid = block;
}

- (void)setSessionDidReceiveAuthenticationChallengeBlock:(ZCYURLSessionDidReceiveAuthenticationChallengeBlock)block {
    self.sessionDidReceiveAuthenticationChallenge = block;
}

- (void)setDidFinishEventsForBackgroundURLSession:(ZCYURLSessionDidFinishEventsForBackgroundURLSessionBlock)block {
    self.didFinishEventsForBackgroundURLSession = block;
}

#pragma mark - NSURLSessionTaskDelegateBlock

- (void)setTaskWillPerformHTTPRedirectionBlock:(ZCYURLSessionTaskWillPerformHTTPRedirectionBlock)block {
    self.taskWillPerformHTTPRedirection = block;
}

- (void)setTaskDidReceiveAuthenticationChallengeBlock:(ZCYURLSessionTaskDidReceiveAuthenticationChallengeBlock)block {
    self.taskDidReceiveAuthenticationChallenge = block;
}

- (void)setTaskNeedNewBodyStreamBlock:(ZCYURLTaskNeedNewBodyStreamBlock)block {
    self.taskNeedNewBodyStream = block;
}

- (void)setTaskDidSendBodyDataBlock:(ZCYURLSessionTaskDidSendBodyDataBlock)block {
    self.taskDidSendBodyData = block;
}

- (void)setTaskDidCompleteBlock:(ZCYURLSessionTaskDidCompleteBlock)block {
    self.taskDidComplete = block;
}

#pragma mark - NSURLSessionDataDelegateBlock
- (void)setDataTaskDidReceiveResponseBlock:(ZCYURLSessionDataTaskDidReceiveResponseBlock)block {
    self.dataTaskDidReceiveResponse = block;
}

- (void)setDataTaskDidBecomeDownloadTaskBlock:(ZCYURLSessionDataTaskDidBecomeDownloadTaskBlock)block {
    self.dataTaskDidBecomeDownloadTask = block;
}

- (void)setDataTaskDidReceiveDataBlock:(ZCYURLSessionDataTaskDidReceiveData)block {
    self.dataTaskDidReceiveData = block;
}

- (void)setDataTaskWillCacheResponseBlock:(ZCYURLSessionDataTaskWillCacheResponse)block {
    self.dataTaskWillCacheResponse = block;
}

#pragma mark - NSURLSessionDownloadDelegateBlock

- (void)setDownloadTaskDidFinishDownloadingBlock:(ZCYURLSessionDownloadTaskDidFinishDownloading)block {
    self.downloadTaskDidFinishDownloading = block;
}

- (void)setDownloadTaskDidWriteDataBlock:(ZCYURLSessionDownloadTaskDidWriteDataBlock)block {
    self.downloadTaskDidWriteData = block;
}

- (void)setDownloadTaskDidResumeBlock:(ZCYURLSessionDownloadTaskDidResumeBlock)block {
    self.downloadTaskDidResume = block;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if (self.sessionDidBecomInvalid) {
        self.sessionDidBecomInvalid(session, error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ZCYURLSessionDidInvalidateNotification object:session];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    
    NSURLCredential *credential;
    if (self.sessionDidReceiveAuthenticationChallenge) {
        disposition = self.sessionDidReceiveAuthenticationChallenge(session, challenge,&credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            // TODO securityPolicy
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
    
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    NSURLRequest *redirectRequest = request;
    if (self.taskWillPerformHTTPRedirection) {
        redirectRequest = self.taskWillPerformHTTPRedirection(session, task, response, request);
    }
    if (completionHandler) {
        completionHandler(redirectRequest);
    }
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {

    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential;
    if (self.taskDidReceiveAuthenticationChallenge) {
        disposition = self.taskDidReceiveAuthenticationChallenge(session, task, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            // SecurityPolicy
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * _Nullable))completionHandler {
    NSInputStream *inputStream = nil;
    if (self.taskNeedNewBodyStream) {
        inputStream = self.taskNeedNewBodyStream(session, task);
    } else if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }
    
    if (completionHandler) {
        completionHandler(inputStream);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
 
    int64_t totalUnitCount = totalBytesExpectedToSend;
    if (totalUnitCount == NSURLSessionTransferSizeUnknown) {
        NSString *contentLength = [task.originalRequest valueForHTTPHeaderField:@"Content-Length"];
        if (contentLength) {
            totalUnitCount = (int64_t)[contentLength longLongValue];
        }
    }
    
    if (self.taskDidSendBodyData) {
        self.taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalUnitCount);
    }
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    ZCYSessionManagerTaskDelegate *delegate = [self delegateForTask:task];
    if (delegate) {
        [delegate URLSession:session
                        task:task
        didCompleteWithError:error];
        [self removeDelegateForTask:task];
    }
    if (self.taskDidComplete) {
        self.taskDidComplete(session, task, error);
    }
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    if (self.dataTaskDidReceiveResponse) {
        disposition = self.dataTaskDidReceiveResponse(session, dataTask, response);
    }
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {

    ZCYSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    if (delegate) {
        [self removeDelegateForTask:dataTask];
        [self setDelegate:delegate forTask:downloadTask];
    }
    if (self.dataTaskDidBecomeDownloadTask) {
        self.dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask);
    }
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    ZCYSessionManagerTaskDelegate *delegate = [self delegateForTask:dataTask];
    
    [delegate URLSession:session dataTask:dataTask didReceiveData:data];
    
    if (self.dataTaskDidReceiveData) {
        self.dataTaskDidReceiveData(session, dataTask, data);
    }
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
 
    NSCachedURLResponse *cachedResponse = proposedResponse;
    if (self.dataTaskWillCacheResponse) {
        cachedResponse = self.dataTaskWillCacheResponse(session, dataTask, proposedResponse);
    }
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (self.didFinishEventsForBackgroundURLSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.didFinishEventsForBackgroundURLSession(session);
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {

    ZCYSessionManagerTaskDelegate *delegate = [self delegateForTask:downloadTask];
    
    if (self.downloadTaskDidFinishDownloading) {
        NSURL *fileURL = self.downloadTaskDidFinishDownloading(session, downloadTask, location);
        if (fileURL) {
            // TODO deleggate.downloadFileURL = fileURL;
            NSError *error = nil;
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&error];
            if (error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ZCYURLSessionDownloadTaskDidFailToMoveFileNotification object:downloadTask userInfo:error.userInfo];
            }
            return;
        }
    }
    if (delegate) {
        [delegate URLSession:session
                downloadTask:downloadTask
   didFinishDownloadingToURL:location];
    }
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (self.downloadTaskDidWriteData) {
        self.downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {

    if (self.downloadTaskDidResume) {
        self.downloadTaskDidResume(session, downloadTask, fileOffset, expectedTotalBytes);
    }
}

@end
