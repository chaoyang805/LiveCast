//
//  UIImageView+WebCache.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImageView+WebCache.h"


@implementation UIImageView (WebCache)

- (void)zcy_setImageWithURL:(NSURL *)url {
    [self zcy_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)zcy_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self zcy_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)zcy_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(ZCYImageOptions)options {
    [self zcy_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)zcy_setImageWithURL:(NSURL *)url completed:(ZCYImageExternalCompletionBlock)completedBlock {
    [self zcy_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)zcy_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(ZCYImageExternalCompletionBlock)completedBlock {
    [self zcy_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)zcy_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(ZCYImageOptions)options completed:(ZCYImageExternalCompletionBlock)completedBlock {
    [self zcy_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)zcy_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                    options:(ZCYImageOptions)options
                   progress:(ZCYImageDownloaderProgressBlock)progressBlock
                  completed:(ZCYImageExternalCompletionBlock)completedBlock {
    
    [self zcy_internalSetImageWithURL:url
                     placeholderImage:placeholder
                              options:options
                         operationKey:nil
                        setImageBlock:nil
                             progress:progressBlock
                            completed:completedBlock];
}

- (void)zcy_setImageWithPreviousCachedImageWithURL:(NSURL *)url
                                  placeholderImage:(UIImage *)placeholder
                                           options:(ZCYImageOptions)options
                                          progress:(ZCYImageDownloaderProgressBlock)progressBlock
                                         completed:(ZCYImageExternalCompletionBlock)completedBlock {
    NSString *key = [[ZCYImageManager sharedManager] cacheKeyForURL:url];
    UIImage *previousCachedImage = [[ZCYImageCache sharedImageCache] imageFromCacheForKey:key];
    
    [self zcy_setImageWithURL:url
             placeholderImage:previousCachedImage ?: placeholder
                      options:options
                     progress:progressBlock
                    completed:completedBlock];
}

@end
