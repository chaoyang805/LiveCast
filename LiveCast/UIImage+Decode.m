//
//  UIImage+Decode.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImage+Decode.h"

static const size_t kBitsPerComponent = 8;
static const size_t kBytesPerPixel = 4;
@implementation UIImage (Decode)
+ (UIImage *)decodeImageWithImage:(UIImage *)image {
    if (![self shouldDecodeImage:image]) {
        return image;
    }
    
    @autoreleasepool {
        
        CGImageRef imageRef = image.CGImage;
        
        CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
        
        size_t width = CGImageGetWidth(imageRef);
        size_t height = CGImageGetHeight(imageRef);
        size_t bytesPerRow = width * kBytesPerPixel;
        CGContextRef context = CGBitmapContextCreate(NULL,
                                                     width,
                                                     height,
                                                     kBitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpaceRef,
                                                     kCGBitmapByteOrderDefault|kCGImageAlphaNoneSkipLast);
        
        if (!context) {
            return image;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGImageRef imageRefWithoutAlpha = CGBitmapContextCreateImage(context);
        
        UIImage *imageWithoutAlpha = [UIImage imageWithCGImage:imageRefWithoutAlpha scale:image.scale orientation:image.imageOrientation];
        
        CGContextRelease(context);
        CGImageRelease(imageRefWithoutAlpha);
        return imageWithoutAlpha;
    }
}

+ (UIImage *)decodeAndScaleDownImageWithImage:(UIImage *)image {
    // TODO implement it
    return image;
}

+ (BOOL)shouldDecodeImage:(UIImage *)image {
    if (!image) {
        return NO;
    }
    if (image.images) {
        return NO;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
    BOOL hasAlpha = (alphaInfo == kCGImageAlphaLast ||
                     alphaInfo == kCGImageAlphaFirst ||
                     alphaInfo == kCGImageAlphaPremultipliedLast ||
                     alphaInfo == kCGImageAlphaPremultipliedFirst);
    if (hasAlpha) {
        return NO;
    }
    return YES;
}
@end
