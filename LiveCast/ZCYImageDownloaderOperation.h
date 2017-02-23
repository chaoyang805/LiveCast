//
//  ZCYImageDownloaderOperation.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/21.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYImageDownloader.h"

@interface ZCYImageDownloaderOperation : NSOperation <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong, readonly) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong) NSURLCredential *credential;
@property (nonatomic, strong) NSURLResponse *response;

@property (nonatomic, assign) BOOL shouldDecompressImages;
@property (nonatomic, assign) BOOL shouldUseCredentialStorage;
@property (nonatomic, assign) NSUInteger expectedSize;

@property (nonatomic, assign) ZCYImageDownloaderOptions options;

- (instancetype)initWithRequest:(NSURLRequest *)request
                      inSession:(NSURLSession *)session
                        options:(ZCYImageDownloaderOptions)options;

- (id)addHandlersForProgress:(void (^)(NSUInteger receivedSize, NSUInteger expectedSize, NSURL *targetURL))progressBlock
              completedBlock:(void (^)(UIImage *image, NSData *data, NSError *error))completedBlock;
@end
