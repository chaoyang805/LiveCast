//
//  ZCYImageDownloader.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/21.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//
typedef void(^ZCYImageDownloaderProgressBlock)(NSUInteger receivedSize, NSUInteger expectedSize, NSURL *targetURL);
typedef void(^ZCYImageDownloaderCompletedBlock)(UIImage *image, NSData *imageData, NSError *error, BOOL finished);

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

@interface ZCYImageDownloader : NSOperation

@end
