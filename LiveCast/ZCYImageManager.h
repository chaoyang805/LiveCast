//
//  ZCYImageManager.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/27.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//


#import "ZCYImageCache.h"
#import "ZCYImageDownloader.h"
@protocol ZCYImageOperation <NSObject>

- (void)cancel;

@end

typedef NS_ENUM(NSUInteger, ZCYImageOptions) {
    ZCYImageRetryFailed = 1 << 0,
    ZCYImageLowPriority = 1 << 1,
    ZCYImageCacheMemoryOnly = 1 << 2,
    ZCYImageProgressiveDownload = 1 << 3,
    ZCYImageRefreshCached = 1 << 4,
    ZCYImageContinueInBackground = 1 << 5,
    ZCYImageHandleCookies = 1 << 6,
    ZCYImageAllowInvalidSSLCertificates = 1 << 7,
    ZCYImageHighPriority = 1 << 8,
    ZCYImageScaleDownLargeImages = 1 << 9,
    ZCYImageTransformAnimatedImage = 1 << 10,
    ZCYImageAvoidAutoSetImage = 1 << 11,
    ZCYImageDelayPlaceholder = 1 << 12
};

typedef void (^ZCYImageInternalCompletionBlock)(UIImage *image, NSData *data, NSError *error, ZCYImageCacheType cacheType, BOOL finished, NSURL *imageURL);
typedef void (^ZCYImageExternalCompletionBlock)(UIImage *image, NSError *error, ZCYImageCacheType cacheType, NSURL *imageURL);
@class ZCYImageManager;

@protocol ZCYImageManagerDelegate <NSObject>
@optional

- (BOOL)imageManager:(ZCYImageManager *)manager shouldDownloadImageForURL:(NSURL *)imageURL;

- (UIImage *)imageManager:(ZCYImageManager *)manager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL;
@end


@interface ZCYImageManager : NSObject
@property (nonatomic, weak) id<ZCYImageManagerDelegate> delegate;
@property (nonatomic, strong, readonly) ZCYImageCache *imageCache;
@property (nonatomic, strong, readonly) ZCYImageDownloader *imageDownloader;
@property (nonatomic, copy) NSString *(^cacheKeyFilter)(NSURL *url);

+ (instancetype)sharedManager;

- (instancetype)initWithCache:(ZCYImageCache *)imageCache downloader:(ZCYImageDownloader *)downloader;

- (id<ZCYImageOperation>)loadImageWithURL:(NSURL *)url
                                  options:(ZCYImageOptions)options
                                 progress:(ZCYImageDownloaderProgressBlock)progressBlock
                                completed:(ZCYImageInternalCompletionBlock)completionBlock;

- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url;

- (NSString *)cacheKeyForURL:(NSURL *)url;

- (void)cancelAll;

- (BOOL)isRunning;

- (void)cacheImageExistsForURL:(NSURL *)url
                    completion:(void(^)(BOOL isInCache))completionBlock;

- (void)diskImageExistsWithURL:(NSURL *)url
                    completion:(void (^)(BOOL isInDiskCache))completionBlock;

@end
