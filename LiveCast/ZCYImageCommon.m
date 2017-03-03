//
//  ZCYImageCommon.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYImageCommon.h"

NSString *const ZCYImageErrorDomain = @"ZCYImageErrorDomain";
inline UIImage *ZCYScaledImageForKey(NSString *key, UIImage *image) {
    if (!image) {
        return nil;
    }
    if (image.images.count > 0) {
        
        NSMutableArray *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:ZCYScaledImageForKey(key, tempImage)];
        }
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    } else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat scale = 1;
            if (key.length >= 8) {
                NSRange range = [key rangeOfString:@"@2x."];
                if (range.location != NSNotFound) {
                    scale = 2.0;
                }
                range = [key rangeOfString:@"@3x."];
                if (range.location != NSNotFound) {
                    scale = 3.0;
                }
            }
            image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
            ;
            
        }
        return image;
    }
}
