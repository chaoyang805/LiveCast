//
//  UIImage+MultiFormat.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSData+ImageContentType.h"

@interface UIImage (MultiFormat)
+ (UIImage *)zcy_imageWithData:(NSData *)data;
- (NSData *)zcy_imageData;
- (NSData *)zcy_imageDataAsFormat:(ZCYImageFormat)format;
@end
