//
//  UIImage+MultiFormat.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"
#import <ImageIO/ImageIO.h>
@implementation UIImage (MultiFormat)

+ (UIImage *)zcy_imageWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    UIImage *image;
    ZCYImageFormat imageFormat = [NSData zcy_imageFormatFromImageData:data];
    if (imageFormat == ZCYImageFormatGIF) {
        image = [UIImage zcy_animatedGIFWithData:data];
    } else {
        image = [[UIImage alloc] initWithData:data];
        UIImageOrientation imageOrientation = [self zcy_imageOrientationFromImageData:data];
        if (imageOrientation != UIImageOrientationUp) {
            image = [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:imageOrientation];
        }
    }
    return image;
}

+ (UIImageOrientation)zcy_imageOrientationFromImageData:(NSData *)data {
    UIImageOrientation orientation = UIImageOrientationUp;
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (source) {
         CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
        if (properties) {
            CFTypeRef val;
            int exifOrientation;
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            if (val) {
                CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
                orientation = [self zcy_exifOrientationToiOSOrientation:exifOrientation];
            }
            CFRelease(properties);
        } else {
            
        }
        CFRelease(source);
    }
    return orientation;
}

+ (UIImageOrientation)zcy_exifOrientationToiOSOrientation:(int)exifOrientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
        case 3:
            orientation = UIImageOrientationDown;
            break;
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
        case 6:
            orientation = UIImageOrientationRight;
            break;
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        case 8:
            orientation = UIImageOrientationLeft;
            break;
        default:
            break;
    }
    return orientation;
}

- (NSData *)zcy_imageData {
    return [self zcy_imageDataAsFormat:ZCYImageFormatUnDefined];
}

- (NSData *)zcy_imageDataAsFormat:(ZCYImageFormat)format {
    NSData *imageData = nil;
    if (self) {
#if TARGET_OS_IOS || TARGET_OS_TV
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipLast ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst);
        
        BOOL usePNG = hasAlpha;
        
        if (format != ZCYImageFormatUnDefined) {
            usePNG = (format == ZCYImageFormatPNG);
        }
        if (usePNG) {
            imageData = UIImagePNGRepresentation(self);
        } else {
            imageData = UIImageJPEGRepresentation(self, 1.0f);
        }
#else
        NSBitmapImageFileType imageFileType = NSJPEGFileType;
        if (format == ZCYImageFormatGIF) {
            imageFileType = NSGIFFileType;
        } else if (format == ZCYImageFormatPNG) {
            imageFileType = NSPNGFileType;
        }
        imageData = [NSBitmapImageRep representationOfImageRepsInArray:self.representations
                                                             usingType:imageFileType
                                                            properties:@{}];
#endif
    }
    
    return imageData;
}

@end
