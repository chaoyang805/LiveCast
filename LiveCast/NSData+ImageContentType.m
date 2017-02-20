//
//  NSData+ImageContentType.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "NSData+ImageContentType.h"

@implementation NSData (ImageContentType)

+ (ZCYImageFormat)zcy_imageFormatFromImageData:(NSData *)imageData {
    unsigned char c;
    [imageData getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return ZCYImageFormatJEPG;
        case 0x89:
            return ZCYImageFormatPNG;
        case 0x47:
            return ZCYImageFormatGIF;
        case 0x49:
        case 0x4D:
            return ZCYImageFormatTIFF;
        case 0x52:
            if (imageData.length < 12) {
                return ZCYImageFormatUnDefined;
            }
            NSString *testString = [[NSString alloc] initWithData:[imageData subdataWithRange:NSMakeRange(0, 12)]  encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return ZCYImageFormatWebP;
            }
    }
    return ZCYImageFormatUnDefined;
}
@end
