//
//  NSData+ImageContentType.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZCYImageFormat) {
    ZCYImageFormatUnDefined = -1,
    ZCYImageFormatJEPG = 0,
    ZCYImageFormatPNG,
    ZCYImageFormatGIF,
    ZCYImageFormatTIFF,
    ZCYImageFormatWebP
};

@interface NSData (ImageContentType)
+ (ZCYImageFormat)zcy_imageFormatFromImageData:(NSData *)imageData;
@end
