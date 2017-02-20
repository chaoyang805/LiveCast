//
//  UIImage+GIF.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GIF)
+ (UIImage *)zcy_animatedGIFWithData:(NSData *)data;
- (BOOL)isGIF;
@end
