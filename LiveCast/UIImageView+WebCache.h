//
//  UIImageView+WebCache.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+WebCache.h"

@interface UIImageView (WebCache)
- (void)zcy_setImageWithURL:(NSURL *)url;

- (void)zcy_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder;

- (void)zcy_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                    options:(ZCYImageOptions)options;


- (void)zcy_setImageWithURL:(NSURL *)url
                  completed:(ZCYImageExternalCompletionBlock)completedBlock;

- (void)zcy_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                  completed:(ZCYImageExternalCompletionBlock)completedBlock;


- (void)zcy_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                    options:(ZCYImageOptions)options
                  completed:(ZCYImageExternalCompletionBlock)completedBlock;

- (void)zcy_setImageWithURL:(NSURL *)url
           placeholderImage:(UIImage *)placeholder
                    options:(ZCYImageOptions)options
                   progress:(ZCYImageDownloaderProgressBlock)progressBlock
                  completed:(ZCYImageExternalCompletionBlock)completedBlock;

- (void)zcy_setImageWithPreviousCachedImageWithURL:(NSURL *)url
                                  placeholderImage:(UIImage *)placeholder
                                           options:(ZCYImageOptions)options
                                          progress:(ZCYImageDownloaderProgressBlock)progressBlock
                                         completed:(ZCYImageExternalCompletionBlock)completedBlock;

@end
