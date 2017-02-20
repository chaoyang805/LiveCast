//
//  UIImage+GIF.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImage+GIF.h"
#import <ImageIO/ImageIO.h>
@implementation UIImage (GIF)

+ (UIImage *)zcy_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(imageSource);
    UIImage *staticImage;
    if (count <= 1) {
        staticImage = [[UIImage alloc] initWithData:data];
    } else {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        CGImageRef CGImage = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
        UIImage *frameImage = [UIImage imageWithCGImage:CGImage scale:scale orientation:UIImageOrientationUp];
        staticImage = [UIImage animatedImageWithImages:@[frameImage] duration:0];
        CGImageRelease(CGImage);
    }
    CFRelease(imageSource);
    return staticImage;
}

- (BOOL)isGIF {
    return self.images != nil;
}
@end
