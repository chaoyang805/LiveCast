//
//  ZCYImageManager.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/27.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYImageManager.h"
#import "ZCYImageDownloaderOperation.h"

@interface ZCYImageCombinedOperation : NSObject <ZCYImageOperation>

@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
@property (nonatomic, copy) void(^cancelBlock)();
@property (nonatomic, strong) NSOperation *cacheOperation;

@end

@implementation ZCYImageCombinedOperation

- (void)setCancelBlock:(void (^)())cancelBlock {
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        _cancelBlock = nil;
    } else {
        _cancelBlock = [cancelBlock copy];
    }
}

- (void)cancel {
    self.cancelled = YES;
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    if (self.cancelBlock) {
        self.cancelBlock();
        
        _cancelBlock = nil;
    }
}

@end

@interface ZCYImageManager ()

@property (nonatomic, strong, readwrite) ZCYImageCache *imageCache;
@property (nonatomic, strong, readwrite) ZCYImageDownloader *imageDownloader;
@property (nonatomic, strong) NSMutableSet<NSURL *> *failedURLs;
@property (nonatomic, strong) NSMutableArray<ZCYImageCombinedOperation *> *runningOperations;

@end

@implementation ZCYImageManager

+ (instancetype)sharedManager {
    static ZCYImageManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (instancetype)init {
    return [self initWithCache:[ZCYImageCache sharedImageCache] downloader:[ZCYImageDownloader sharedDownloader]];
}

- (instancetype)initWithCache:(ZCYImageCache *)imageCache downloader:(ZCYImageDownloader *)downloader
{
    self = [super init];
    if (self) {
        _imageCache = imageCache;
        _imageDownloader = downloader;
        _failedURLs = [NSMutableSet set];
        _runningOperations = [NSMutableArray array];
    }
    return self;
}

- (void)cacheImageExistsForURL:(NSURL *)url
                    completion:(void(^)(BOOL isInCache))completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    BOOL isInMemoryCache = ([self.imageCache imageFromMemoryCacheForKey:key] != nil);
    if (isInMemoryCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES);
            }
        });
        return;
    }
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInCache) {
        if (completionBlock) {
            completionBlock(isInCache);
        }
    }];
}

- (void)diskImageExistsWithURL:(NSURL *)url
                    completion:(void (^)(BOOL isInDiskCache))completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (!url) {
        return @"";
    }
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    } else {
        return url.absoluteString;
    }
    
}

- (id<ZCYImageOperation>)loadImageWithURL:(NSURL *)url
                                          options:(ZCYImageOptions)options
                                         progress:(ZCYImageDownloaderProgressBlock)progressBlock
                                        completed:(ZCYImageInternalCompletionBlock)completionBlock {
    NSAssert(completionBlock != nil, @"completedBlock is nil");
    
    if ([url isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    if (![url isKindOfClass:[NSURL class]]) {
        url = nil;
    }
    __block ZCYImageCombinedOperation *operation = [ZCYImageCombinedOperation new];
    __weak ZCYImageCombinedOperation *weakOperation = operation;
    BOOL isFailedURL = NO;
    if (url) {
        @synchronized (self.failedURLs) {
            isFailedURL = [self.failedURLs containsObject:url];
        }
    }
    if (url.absoluteString.length == 0 || (!(options & ZCYImageRetryFailed) && isFailedURL)) {
        [self callCompletionBlockForOperation:operation completionBlock:completionBlock error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil] url:url];
        return operation;
    }
    
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    
    NSString *key = [self cacheKeyForURL:url];
    operation.cacheOperation = [self.imageCache queryCacheOperationForKey:key done:^(UIImage *cachedImage, NSData *cachedData, ZCYImageCacheType cacheType) {
        if (operation.isCancelled) {
            [self safelyRemoveOperationFromRunning:operation];
            return;
        }
        if ((!cachedImage || options & ZCYImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url ])) {
            if (cachedImage && options & ZCYImageRefreshCached) {
                [self callCompletionBlockForOperation:weakOperation completionBlock:completionBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            }
            
            ZCYImageDownloaderOptions downloaderOptions = 0;
            if (options & ZCYImageLowPriority) downloaderOptions |= ZCYImageDownloaderLowPriority;
            if (options & ZCYImageProgressiveDownload) downloaderOptions |= ZCYImageDownloaderProgressiveDownload;
            if (options & ZCYImageRefreshCached) downloaderOptions |= ZCYImageDownloaderUseNSURLCache;
            if (options & ZCYImageContinueInBackground) downloaderOptions |= ZCYImageDownloaderContinueInBackground;
            if (options & ZCYImageHandleCookies) downloaderOptions |= ZCYImageDownloaderHandleCookies;
            if (options & ZCYImageAllowInvalidSSLCertificates) downloaderOptions |= ZCYImageDownloaderAllowInvalidSSLCertificates;
            if (options & ZCYImageHighPriority) downloaderOptions |= ZCYImageDownloaderHighPriority;
            if (options & ZCYImageScaleDownLargeImages) downloaderOptions |= ZCYImageDownloaderScaleDownLargeImages;
            
            if (cachedImage && options & ZCYImageRefreshCached) {
                downloaderOptions &= ~ZCYImageDownloaderProgressiveDownload;
                downloaderOptions |= ZCYImageDownloaderIgnoreCachedRespose;
            }
            ZCYImageDownloadToken *subOperationToken = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *downloadedData, NSError *error, BOOL finished) {
                __strong typeof(weakOperation) strongOperation = weakOperation;
                if (!strongOperation || strongOperation.isCancelled) {
                    
                } else if (error) {
                    [self callCompletionBlockForOperation:strongOperation completionBlock:completionBlock error:error url:url];
                    
                    if (error.code != NSURLErrorNotConnectedToInternet &&
                        error.code != NSURLErrorCancelled &&
                        error.code != NSURLErrorTimedOut &&
                        error.code != NSURLErrorInternationalRoamingOff &&
                        error.code != NSURLErrorDataNotAllowed &&
                        error.code != NSURLErrorCannotFindHost &&
                        error.code != NSURLErrorCannotConnectToHost) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                } else {
                    if (options & ZCYImageRetryFailed) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs removeObject:url];
                        }
                    }
                    
                    BOOL cacheOnDisk = !(options & ZCYImageCacheMemoryOnly);
                    if (options & ZCYImageRefreshCached && cachedImage && !downloadedImage) {
                        
                    } else if (downloadedImage && (!downloadedImage.images || (options & ZCYImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
                            if (transformedImage && finished) {
                                BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                [self.imageCache storeImage:transformedImage imageData:imageWasTransformed ? nil : downloadedData forKey:key toDisk:cacheOnDisk onCompletion:nil];
                            }
                            [self callCompletionBlockForOperation:strongOperation completionBlock:completionBlock image:transformedImage data:downloadedData error:nil cacheType:ZCYImageCacheTypeNone finished:finished url:url];
                        });
                    } else {
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage imageData:downloadedData forKey:key toDisk:cacheOnDisk onCompletion:nil];
                        }
                        [self callCompletionBlockForOperation:strongOperation completionBlock:completionBlock image:downloadedImage data:downloadedData error:nil cacheType:ZCYImageCacheTypeNone finished:finished url:url];
                    }
                    
                }
                
                if (finished) {
                    [self safelyRemoveOperationFromRunning:strongOperation];
                }
                
            }];
            __weak typeof(subOperationToken) weakSubOperationToken = subOperationToken;
            operation.cancelBlock = ^{
                [self.imageDownloader cancel:weakSubOperationToken];
                __strong typeof(weakOperation) strongOperation = weakOperation;
                [self safelyRemoveOperationFromRunning:strongOperation];
            };
        } else if (cachedImage) {
            __strong typeof(weakOperation) strongOperation = weakOperation;
            [self callCompletionBlockForOperation:strongOperation completionBlock:completionBlock image:cachedImage data:cachedData error:nil cacheType:cacheType finished:YES url:url];
            [self safelyRemoveOperationFromRunning:operation];
        } else {
            __strong typeof(weakOperation) strongOperation = weakOperation;
            [self callCompletionBlockForOperation:strongOperation completionBlock:completionBlock image:nil data:nil error:nil cacheType:ZCYImageCacheTypeNone finished:YES url:url];
            [self safelyRemoveOperationFromRunning:operation];
        }
    }];
    return operation;
}

- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    [self.imageCache storeImage:image forKey:key toDisk:YES onCompletion:nil];
}

- (void)cancelAll {
    @synchronized (self.runningOperations) {
        NSArray<ZCYImageCombinedOperation *> *copiedOperations = [self.runningOperations copy];
        [copiedOperations makeObjectsPerformSelector:@selector(cancel)];
        [self.runningOperations removeObjectsInArray:copiedOperations];
    }
}
- (BOOL)isRunning {
    BOOL isRunning = NO;
    @synchronized (self.runningOperations) {
        isRunning = (self.runningOperations.count > 0);
    }
    return isRunning;
}
- (void)safelyRemoveOperationFromRunning:(ZCYImageCombinedOperation *)operation {
    @synchronized (self.runningOperations) {
        if (operation) {
            [self.runningOperations removeObject:operation];
        }
    }
}

- (void)callCompletionBlockForOperation:(ZCYImageCombinedOperation *)operation
                        completionBlock:(ZCYImageInternalCompletionBlock)completionBlock
                                  error:(NSError *)error
                                    url:(NSURL *)url {
    [self callCompletionBlockForOperation:operation completionBlock:completionBlock image:nil data:nil error:error cacheType:ZCYImageCacheTypeNone finished:YES url:url];
}

- (void)callCompletionBlockForOperation:(ZCYImageCombinedOperation *)operation
                        completionBlock:(ZCYImageInternalCompletionBlock)completionBlock
                                  image:(UIImage *)image
                                   data:(NSData *)data
                                  error:(NSError *)error
                              cacheType:(ZCYImageCacheType)cacheType
                               finished:(BOOL)finished
                                    url:(NSURL *)url {
    dispatch_main_safe(^{
        if (operation && !operation.cancelled && completionBlock) {
            completionBlock(image, data, error, cacheType, finished, url);
        }
    });
}

@end
