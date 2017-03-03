//
//  ZCYImageDownloader.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/21.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//
typedef void(^ZCYImageDownloaderProgressBlock)(NSUInteger receivedSize, NSUInteger expectedSize, NSURL *targetURL);
typedef void(^ZCYImageDownloaderCompletedBlock)(UIImage *image, NSData *imageData, NSError *error, BOOL finished);

typedef NSDictionary<NSString *, NSString *> * ZCYHTTPHeaderDictionary;
typedef NSMutableDictionary<NSString *, NSString *> * ZCYHTTPHeadersMutableDictionary;
typedef ZCYHTTPHeaderDictionary (^ZCYImageDownloaderHeaderFilterBlock)(NSURL *url, ZCYHTTPHeaderDictionary headers);

typedef NS_OPTIONS(NSUInteger, ZCYImageDownloaderOptions) {
    ZCYImageDownloaderLowPriority = 1 << 0,
    ZCYImageDownloaderProgressiveDownload = 1 << 1,
    ZCYImageDownloaderUseNSURLCache = 1 << 2,
    ZCYImageDownloaderIgnoreCachedRespose = 1 << 3,
    ZCYImageDownloaderContinueInBackground = 1 << 4,
    ZCYImageDownloaderHandleCookies = 1 << 5,
    ZCYImageDownloaderAllowInvalidSSLCertificates = 1 << 6,
    ZCYImageDownloaderHighPriority = 1 << 7,
    ZCYImageDownloaderScaleDownLargeImages = 1 << 8,
};

typedef NS_ENUM(NSUInteger, ZCYImageDownloaderExecutionOrder) {
    ZCYImageDownloaderFIFOExecutionOrder,
    ZCYImageDownloaderLIFOExecutionOrder
};


@class ZCYImageDownloaderOperation;
@interface ZCYImageDownloadToken : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id downloadOperationCancelToken;
@end

@interface ZCYImageDownloader : NSObject

@property (nonatomic, strong) NSURLCredential *urlCredential;

@property (nonatomic, assign) NSTimeInterval downloadTimeout;
@property (nonatomic, assign) BOOL shouldDecompressImages;
@property (nonatomic, assign) NSInteger maxConcurrentDownloads;
@property (nonatomic, assign) ZCYImageDownloaderExecutionOrder executionOrder;
@property (nonatomic, assign, readonly) NSUInteger currentDownloadCount;

@property (nonatomic, copy) ZCYImageDownloaderHeaderFilterBlock headerFilter;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;


+ (instancetype)sharedDownloader;

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

- (ZCYImageDownloadToken *)downloadImageWithURL:(NSURL *)url
                                        options:(ZCYImageDownloaderOptions)options
                                       progress:(ZCYImageDownloaderProgressBlock)progressBlock
                                      completed:(ZCYImageDownloaderCompletedBlock)completedBlock;

- (void)cancel:(ZCYImageDownloadToken *)token;

- (void)setSuspend:(BOOL)suspend;

- (void)cancelAllDownloads;

- (void)setValue:(NSString *)value forHTTPHeaderField:(nonnull NSString *)field;

- (nullable NSString *)valueForHTTPHeaderField:(nullable NSString *)field;

@end
