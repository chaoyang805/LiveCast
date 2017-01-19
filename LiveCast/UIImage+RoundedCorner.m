//
//  UIImage+RoundedCorner.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/10.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImage+RoundedCorner.h"

@implementation UIImage (RoundedCorner)

- (UIImage *)zcy_imageWithRoundedCorner:(CGFloat)radius size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize cornerRadii = CGSizeMake(radius, radius);
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
    CGContextAddPath(ctx, roundedPath.CGPath);
    
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

- (UIImage *)zcy_imageWithRoundedCorner:(CGFloat)radius size:(CGSize)size fillColor:(UIColor *)color roundingCorners:(UIRectCorner)roundingCorners {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize cornerRadii = CGSizeMake(radius, radius);
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
    CGContextAddPath(ctx, roundedPath.CGPath);
    
    CGContextClip(ctx);
    UIImage *bgImage = [self zcy_imageWithColor:color size:size];
    [bgImage drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

- (UIImage *)zcy_imageWithColor:(UIColor *)color size:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}

@end
