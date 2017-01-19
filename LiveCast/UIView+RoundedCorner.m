//
//  UIView+RoundedCorner.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/10.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIView+RoundedCorner.h"

@implementation UIView (RoundedCorner)

//- (void)zcy_addRoundedCorner:(CGFloat)radius {
//    [self zcy_addRoundedCorner:radius
//                   borderWidth:1
//               backgroundColor:[UIColor clearColor]
//                   borderColor:[UIColor blackColor]];
//}

//- (void)zcy_addRoundedCorner:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)bgColor borderColor:(UIColor *)borderColor {
//    UIImage *roundedImage = [self zcy_rectWithRoundedCorner:radius
//                                                borderWidth:borderWidth
//                                            backgroundColor:bgColor
//                                                borderColor:borderColor];
//
//    [self insertSubview:[[UIImageView alloc] initWithImage:roundedImage] atIndex:0];
//}

- (void)zcy_addRoundedCorner:(CGFloat)radius
                   fillColor:(UIColor *)color
             roundingCorners:(UIRectCorner)corners {
    
    UIImage *roundedImage = [self zcy_imageWithRoundedCorner:radius
                                                        size:self.bounds.size
                                                   fillColor:color
                                                 borderWidth:0
                                                 borderColor:[UIColor clearColor]
                                             roundingCorners:corners];
    
    [self insertSubview:[[UIImageView alloc] initWithImage:roundedImage] atIndex:0];
}

- (void)zcy_addRoundedCorner:(CGFloat)radius
                   fillColor:(UIColor *)fillColor
                 borderWidth:(CGFloat)borderWidth
                 borderColor:(UIColor *)borderColor {
    
    UIImage *roundedImage = [self zcy_imageWithRoundedCorner:radius
                                                        size:self.bounds.size
                                                   fillColor:fillColor
                                                 borderWidth:borderWidth
                                                 borderColor:borderColor
                                             roundingCorners:UIRectCornerAllCorners];
    
    [self insertSubview:[[UIImageView alloc] initWithImage:roundedImage] atIndex:0];
}

- (UIImage *)zcy_rectWithRoundedCorner:(CGFloat)radius borderWidth:(CGFloat)borderWidth backgroundColor:(UIColor *)bgColor borderColor:(UIColor *)borderColor {
    
    CGSize sizeToFit = CGSizeMake(floor(CGRectGetWidth(self.bounds)),
                                  floor(CGRectGetHeight(self.bounds)));
    UIGraphicsBeginImageContextWithOptions(sizeToFit, NO, [UIScreen mainScreen].scale);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, borderWidth);
    [bgColor setFill];
    [borderColor setStroke];
    
    CGFloat halfBorderWidth = borderWidth / 2.0f;
    CGFloat width = sizeToFit.width;
    CGFloat height = sizeToFit.height;
    CGContextMoveToPoint(ctx, width - halfBorderWidth, radius + halfBorderWidth);
    CGContextAddArcToPoint(ctx, width - halfBorderWidth, height - halfBorderWidth, width - halfBorderWidth - radius, height - halfBorderWidth, radius);
    CGContextAddArcToPoint(ctx, halfBorderWidth, height - halfBorderWidth, halfBorderWidth, height - halfBorderWidth - radius, radius);
    CGContextAddArcToPoint(ctx, halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth, radius);
    CGContextAddArcToPoint(ctx, width - halfBorderWidth, halfBorderWidth, width - halfBorderWidth, halfBorderWidth + radius, radius);
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}
// 带border 的四个角，和不带border 的少于四个角

- (UIImage *)zcy_imageWithRoundedCorner:(CGFloat)radius
                                   size:(CGSize)size
                              fillColor:(UIColor *)color
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor
                        roundingCorners:(UIRectCorner)roundingCorners {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize cornerRadii = CGSizeMake(radius, radius);
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:roundingCorners cornerRadii:cornerRadii];
    CGContextAddPath(ctx, roundedPath.CGPath);
    [borderColor setStroke];
    CGContextClip(ctx);
    
    CGRect bgRect = CGRectMake(borderWidth, borderWidth, size.width - 2 * borderWidth, size.height - 2 * borderWidth);
    UIImage *bgImage = [self zcy_imageWithColor:color inRect:bgRect];
    [bgImage drawInRect:bgRect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return output;
}

- (UIImage *)zcy_imageWithColor:(UIColor *)color inRect:(CGRect)rect {
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    [color setFill];
    UIRectFill(rect);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}
@end
