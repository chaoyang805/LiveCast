//
//  UIView+WebCache.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCYImageManager.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^ZCYSetImageBlock)(UIImage * _Nullable image, NSData * _Nullable imageData);

@interface UIView (WebCache)

- (void)zcy_internalSetImageWithURL:(NSURL *)url
                   placeholderImage:(UIImage *)placeholder
                            options:(ZCYImageOptions)options
                       operationKey:(nullable NSString *)operationKey
                      setImageBlock:(nullable ZCYSetImageBlock)setImageBlock
                           progress:(ZCYImageDownloaderProgressBlock)progressBlock
                          completed:(ZCYImageExternalCompletionBlock)completedBlock;

@end
NS_ASSUME_NONNULL_END
