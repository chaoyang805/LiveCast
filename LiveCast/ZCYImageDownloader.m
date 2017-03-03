//
//  ZCYImageDownloader.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/21.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYImageDownloader.h"
#import "ZCYImageDownloaderOperation.h"

@implementation ZCYImageDownloadToken
@end

@interface ZCYImageDownloader () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) NSOperation *lastAddedOperation;

@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, ZCYImageDownloaderOperation *> *URLOperations;
@property (nonatomic, strong) ZCYHTTPHeadersMutableDictionary HTTPHeaders;
@property (nonatomic, assign) Class operationClass;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation ZCYImageDownloader

+ (instancetype)sharedDownloader {
    static ZCYImageDownloader *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super init];
    if (self) {
        _operationClass = [ZCYImageDownloaderOperation class];
        _shouldDecompressImages = YES;
        _executionOrder = ZCYImageDownloaderFIFOExecutionOrder;
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _downloadQueue.name = @"me.chaoyang805.ImageDownloader";
        _URLOperations = [NSMutableDictionary new];
        _HTTPHeaders = [@{@"Accept" : @"image/webp, image/*; q=0.8"} mutableCopy];
        _barrierQueue = dispatch_queue_create("me.chaoyang805.ImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;
        
        configuration.timeoutIntervalForRequest = _downloadTimeout;
        
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    [self.downloadQueue cancelAllOperations];
}

- (ZCYImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                        options:(ZCYImageDownloaderOptions)options
                                       progress:(ZCYImageDownloaderProgressBlock)progressBlock
                                      completed:(ZCYImageDownloaderCompletedBlock)completedBlock {
    __weak ZCYImageDownloader *weakSelf = self;
    return [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^ZCYImageDownloaderOperation *{
        // strongify self
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // set timeout interval
        NSTimeInterval timeoutInterval = strongSelf.downloadTimeout;
        if (timeoutInterval == 0) {
            timeoutInterval = 15.0;
        }
        // create mutableRequest
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:(options & ZCYImageDownloaderUseNSURLCache) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeoutInterval];
        // config request
        mutableRequest.HTTPShouldHandleCookies = (options & ZCYImageDownloaderHandleCookies);
        mutableRequest.HTTPShouldUsePipelining = YES;
        // config request headers headerFilter
        if (strongSelf.headerFilter) {
            mutableRequest.allHTTPHeaderFields = strongSelf.headerFilter(url, [strongSelf.HTTPHeaders copy]);
        } else {
            mutableRequest.allHTTPHeaderFields = strongSelf.HTTPHeaders;
        }
        // create operation
        ZCYImageDownloaderOperation *operation = [[strongSelf.operationClass alloc] initWithRequest:mutableRequest inSession:strongSelf.session options:options];
        // config operation
        operation.shouldDecompressImages = strongSelf.shouldDecompressImages;
        // config credential
        if (strongSelf.urlCredential) {
            operation.credential = strongSelf.urlCredential;
        } else if (strongSelf.username && strongSelf.password){
            operation.credential = [NSURLCredential credentialWithUser:strongSelf.username password:strongSelf.password persistence:NSURLCredentialPersistenceForSession];
        }
        // config priority
        if (options & ZCYImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & ZCYImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }
        // config execution order
        [strongSelf.downloadQueue addOperation:operation];
        if (strongSelf.executionOrder == ZCYImageDownloaderLIFOExecutionOrder) {
            [strongSelf.lastAddedOperation addDependency:operation];
            strongSelf.lastAddedOperation = operation;
        }
        return operation;
    }];
}

- (ZCYImageDownloadToken *)addProgressCallback:(ZCYImageDownloaderProgressBlock)progressBlock
             completedBlock:(ZCYImageDownloaderCompletedBlock)completedBlock
                     forURL:(NSURL *)url
             createCallback:(ZCYImageDownloaderOperation *(^)())createCallback {
    // check url if nil just completedBlock
    if (!url) {
        if (completedBlock) {
            completedBlock(nil, nil, nil, NO);
        }
        return nil;
    }
    __block ZCYImageDownloadToken *token;
    // dispatch_barrier sync
    // createCallback add to operations dict
    dispatch_barrier_sync(self.barrierQueue, ^{
        
        ZCYImageDownloaderOperation *operation = self.URLOperations[url];
        if (!operation) {
            operation = createCallback();
            self.URLOperations[url] = operation;
            
            __weak ZCYImageDownloaderOperation *weakOperation = operation;
            operation.completionBlock = ^{
                __strong ZCYImageDownloaderOperation *strongOperation = weakOperation;
                if (strongOperation) {
                    if (self.URLOperations[url] == strongOperation) {
                        [self.URLOperations removeObjectForKey:url];
                    }
                }
            };
        }
        
        id downloadOperationToken = [operation addHandlersForProgress:progressBlock completedBlock:completedBlock];
        
        token = [ZCYImageDownloadToken new];
        token.downloadOperationCancelToken = downloadOperationToken;
        token.url = url;
    });
    return token;
}

- (void)cancel:(ZCYImageDownloadToken *)token {
    dispatch_barrier_async(self.barrierQueue, ^{
        
        ZCYImageDownloaderOperation *operation = self.URLOperations[token.url];
        BOOL cancelled = [operation cancel:token.downloadOperationCancelToken];
        if (cancelled) {
            [self.URLOperations removeObjectForKey:token.url];
        }
    });
}

- (void)setSuspend:(BOOL)suspend {
    self.downloadQueue.suspended = suspend;
}

- (void)cancelAllDownloads {
    [self.downloadQueue cancelAllOperations];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(nonnull NSString *)field {
    if (value) {
        self.HTTPHeaders[field] = value;
    } else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return self.HTTPHeaders[field];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (ZCYImageDownloaderOperation *)operationForTask:(NSURLSessionTask *)task {
    
    __block ZCYImageDownloaderOperation *operation = nil;
    [self.URLOperations enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, ZCYImageDownloaderOperation * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.dataTask.taskIdentifier == task.taskIdentifier) {
            *stop = YES;
            operation = obj;
        }
    }];
    return operation;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    ZCYImageDownloaderOperation *dataOperation = [self operationForTask:dataTask];
    [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    ZCYImageDownloaderOperation *operation = [self operationForTask:dataTask];
    [operation URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    ZCYImageDownloaderOperation *operation = [self operationForTask:dataTask];
    [operation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    ZCYImageDownloaderOperation *operation = [self operationForTask:task];
    [operation URLSession:session task:task didCompleteWithError:error];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    ZCYImageDownloaderOperation *operation = [self operationForTask:task];
    [operation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    completionHandler(request);
}

@end
