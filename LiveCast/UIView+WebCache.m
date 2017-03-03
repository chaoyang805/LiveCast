//
//  UIView+WebCache.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIView+WebCache.h"
#import "UIView+WebCacheOperation.h"
#import <objc/runtime.h>

static char imageURLKey;

@implementation UIView (WebCache)

- (NSURL *)sd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)zcy_internalSetImageWithURL:(NSURL *)url
             placeholderImage:(UIImage *)placeholder
                      options:(ZCYImageOptions)options
                       operationKey:(nullable NSString *)operationKey
                      setImageBlock:(nullable ZCYSetImageBlock)setImageBlock
                     progress:(ZCYImageDownloaderProgressBlock)progressBlock
                    completed:(ZCYImageExternalCompletionBlock)completedBlock {
    NSString *validOperationKey = operationKey ?: NSStringFromClass([self class]);

    [self zcy_cancelImageLoadOperationWithKey:validOperationKey];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & ZCYImageDelayPlaceholder)) {
        dispatch_main_safe(^{
            [self zcy_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
        });
    }
    
    if (url) {
        // TODO check activityView
        weakify(self);
        id<ZCYImageOperation> operation = [[ZCYImageManager sharedManager] loadImageWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSData *data, NSError *error, ZCYImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            strongify(self);
            // TODO remove acitivityIndicator
            if (!self) {
                return;
            }
            if (image && options & ZCYImageAvoidAutoSetImage) {
                if (completedBlock) {
                    completedBlock(image, error, cacheType, url);
                }
                return;
            } else if (image) {
                [self zcy_setImage:image imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
                [self setNeedsLayout];
            } else {
                if (options & ZCYImageDelayPlaceholder) {
                    [self zcy_setImage:placeholder imageData:nil basedOnClassOrViaCustomSetImageBlock:setImageBlock];
                    [self setNeedsLayout];
                }
            }
            if (completedBlock && finished) {
                completedBlock(image, error, cacheType, url);
            }
            
        }];
        [self zcy_setImageLoadOperation:operation forKey:validOperationKey];

    } else {
        dispatch_main_safe(^{
            // TODO remove activityIndicator
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:ZCYImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, ZCYImageCacheTypeNone, url);
            }
        });
    }
    
}

- (void)zcy_setImage:(UIImage *)image imageData:(NSData *)data basedOnClassOrViaCustomSetImageBlock:(ZCYSetImageBlock)setImageBlock {
    if (setImageBlock) {
        setImageBlock(image, data);
        return;
    }
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        imageView.image = image;
    }
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button setImage:image forState:UIControlStateNormal];
    }
}

@end





