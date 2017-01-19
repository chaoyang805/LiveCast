//
//  UIView+RoundedCorner.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/10.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoundedCorner)

//- (void)zcy_addRoundedCorner:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)bgColor borderColor:(UIColor *)borderColor;
//- (void)zcy_addRoundedCorner:(CGFloat)radius;

- (void)zcy_addRoundedCorner:(CGFloat)radius
                   fillColor:(UIColor *)fillColor
                 borderWidth:(CGFloat)borderWidth
                 borderColor:(UIColor *)borderColor;
- (void)zcy_addRoundedCorner:(CGFloat)radius
                   fillColor:(UIColor *)color
             roundingCorners:(UIRectCorner)corners;

@end
