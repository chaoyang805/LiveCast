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

static const CGFloat kDestImageSizeMB = 60.0f;

static const CGFloat kTileImageSourceSizeMB = 20.0f;

static const CGFloat kBytesPerMB = 1024.0f * 1024.0f;
static const CGFloat kPixelsPerMB = kBytesPerMB / kBytesPerPixel;
static const CGFloat kDestTotalPixels = kDestImageSizeMB * kPixelsPerMB; // 60 * 1024 * 1024 / 4
static const CGFloat kTileTotalPixels = kTileImageSourceSizeMB * kPixelsPerMB; // 20 * 1024 * 1024 / 4 = 5242880

static const CGFloat kDestSeemOverlap = 2.0f;

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
    if (![UIImage shouldDecodeImage:image]) {
        return image;
    }
    if (![UIImage shouldScaleDownImage:image]) {
        return [UIImage decodeImageWithImage:image];
    }
    
    CGContextRef destContext;
    @autoreleasepool {
        CGImageRef sourceImageRef = image.CGImage;
        CGSize sourceResolution = CGSizeZero;
        sourceResolution.width = CGImageGetWidth(sourceImageRef); // width = 9000
        sourceResolution.height = CGImageGetHeight(sourceImageRef); // height = 8000
        float sourceTotalPixels = sourceResolution.width * sourceResolution.height; // 72000000
        
        float scale = kDestTotalPixels / sourceTotalPixels; // 15728640 / 72000000 = 0.2184533333
        CGSize destResolution = CGSizeZero;
        destResolution.width = (int)(sourceResolution.width * scale); // 9000 * 0.2184533333 = 1966
        destResolution.height = (int)(sourceResolution.height * scale); // 8000 * 0.2184533333 = 1747
        
        CGColorSpaceRef colorspaceRef = [UIImage colorSpaceForImageRef:sourceImageRef];
        
        size_t bytesPerRow = kBytesPerPixel * destResolution.width; // 4 * 1966 = 7864 bytes
        void* destBitmapData = malloc(bytesPerRow * destResolution.height); // 13.1MB
        if (destBitmapData == NULL) {
            return image;
        }
        
        destContext = CGBitmapContextCreate(
                              destBitmapData,
                              destResolution.width,
                              destResolution.height,
                              kBitsPerComponent,
                              bytesPerRow,
                              colorspaceRef,
                              kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast);
        
        if (destContext == NULL) {
            free(destBitmapData);
            return image;
        }
        CGContextSetInterpolationQuality(destContext, kCGInterpolationHigh);
        
        CGRect sourceTile = CGRectZero;
        sourceTile.size.width = sourceResolution.width;
        sourceTile.size.height =  (int)(kTileTotalPixels / sourceTile.size.width); // 5242880 / 9000 = 582
        sourceTile.origin.x = 0.0f;  // sourceTile = { 0, y, 9000, 582 }
        
        CGRect destTile;
        destTile.size.width = destResolution.width;
        destTile.size.height = scale * sourceTile.size.height; // 582 * 0.2184533333 = 127.1398399806
        destTile.origin.x = 0.0f; // destTile = { 0, y, 1966,  127.14}
        
        // sourceSeemOverlap = (2 / 1747) * 8000  = 9
        float sourceSeemOverlap = (int)((kDestSeemOverlap / destResolution.height) * sourceResolution.height);
        CGImageRef sourceTileImageRef;
        // iterations = 13
        int iterations = (int)(sourceResolution.height / sourceTile.size.height);
        int remainder = (int)(sourceResolution.height) % (int)(sourceTile.size.height);
        
        if (remainder) {
            iterations++; // iterations = 14
        }
        
        float sourceTileHeightMinusOverlap = sourceTile.size.height; // 582
        sourceTile.size.height += sourceSeemOverlap; // 591
        destTile.size.height += kDestSeemOverlap; // 129.14
        for (int y = 0; y < iterations; ++y) {
            @autoreleasepool {
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                // y = 0 origin.y = 1747 - (14 * 127 + 2)
                destTile.origin.y = destResolution.height - ((y + 1) * sourceTileHeightMinusOverlap * scale + kDestSeemOverlap);
                sourceTileImageRef = CGImageCreateWithImageInRect(sourceImageRef, sourceTile);
                if (y == iterations - 1 && remainder) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight(sourceTileImageRef) * scale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                CGContextDrawImage(destContext, destTile, sourceTileImageRef);
                CGImageRelease(sourceTileImageRef);
            }
        }
        
        CGImageRef destImageRef = CGBitmapContextCreateImage(destContext);
        CGContextRelease(destContext);
        if (destImageRef == NULL) {
            return image;
        }
        UIImage *destImage = [UIImage imageWithCGImage:destImageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(destImageRef);
        if (destImage == nil) {
            return image;
        }
        return destImage;
    }
    
}

+ (BOOL)shouldScaleDownImage:(UIImage *)image {

    CGImageRef imageSource = image.CGImage;
    size_t width = CGImageGetWidth(imageSource);
    size_t height = CGImageGetHeight(imageSource);
    float sourceTotalPixels = width * height;
    float scale = kDestTotalPixels / sourceTotalPixels;
    return scale < 1;
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

+ (CGColorSpaceRef)colorSpaceForImageRef:(CGImageRef)imageRef {
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
    
    BOOL unsupportedColorSpace = (
                                  colorSpaceModel == kCGColorSpaceModelUnknown ||
                                  colorSpaceModel == kCGColorSpaceModelCMYK ||
                                  colorSpaceModel == kCGColorSpaceModelMonochrome ||
                                  colorSpaceModel == kCGColorSpaceModelIndexed
                                  );
    if (unsupportedColorSpace) {
        colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        CFAutorelease(colorSpaceRef);
    }
    return colorSpaceRef;
}
@end


