//
//  ZCYSessionManager.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/25.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCYURLRequestSerialization.h"
#import "ZCYURLResponseSerialization.h"
@interface ZCYSessionManager : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (readonly, nonatomic, strong) NSURLSession *session;

@property (readwrite, nonatomic, strong) id <ZCYURLResponseSerialization> responseSerializer;

@property (readwrite, nonatomic, strong) dispatch_group_t completionGroup;

@property (readwrite, nonatomic, strong) dispatch_queue_t completionQueue;

@property (readonly, nonatomic, strong) NSArray<NSURLSessionTask *> *tasks;

@property (readonly, nonatomic, strong) NSArray<NSURLSessionDataTask *> *dataTasks;

@property (readonly, nonatomic, strong) NSArray<NSURLSessionDownloadTask *> *downloadTasks;

@property (readonly, nonatomic, strong) NSArray<NSURLSessionUploadTask *> *uploadTasks;

#pragma mark -
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

#pragma mark -
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

#pragma mark -

- (void)setSessionDidBecomInvalidBlock:(void(^)(NSURLSession *session, NSError *error))block;

- (void)setSessionDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block;

- (void)setDidFinishEventsForBackgroundURLSession:(void(^)(NSURLSession *session))block;

#pragma mark -
- (void)setTaskWillPerformHTTPRedirectionBlock:(NSURLRequest * (^)(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request))block;

- (void)setTaskDidReceiveAuthenticationChallengeBlock:(NSURLSessionAuthChallengeDisposition (^)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, NSURLCredential * __autoreleasing *credential))block;

- (void)setTaskNeedNewBodyStreamBlock:(NSInputStream * (^)(NSURLSession *session, NSURLSessionTask *task))block;

- (void)setTaskDidSendBodyDataBlock:(void(^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))block;

- (void)setTaskDidCompleteBlock:(void(^)(NSURLSession *session, NSURLSessionTask *task, NSError *error))block;

#pragma mark -
- (void)setDataTaskDidReceiveResponseBlock:(NSURLSessionResponseDisposition (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response))block;

- (void)setDataTaskDidBecomeDownloadTaskBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))block;

- (void)setDataTaskDidReceiveDataBlock:(void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))block;


- (void)setDataTaskWillCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSCachedURLResponse *proposedResponse))block;

#pragma mark -
- (void)setDownloadTaskDidFinishDownloadingBlock:(NSURL * (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, NSURL *location))block;

- (void)setDownloadTaskDidWriteDataBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;

- (void)setDownloadTaskDidResumeBlock:(void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t fileOffset, int64_t expectedTotalBytes))block;

#pragma mark -



@end
