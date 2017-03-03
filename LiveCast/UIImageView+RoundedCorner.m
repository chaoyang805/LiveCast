//
//  UIImageView+RoundedCorner.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/11.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImageView+RoundedCorner.h"
#import "UIImage+RoundedCorner.h"
#import <objc/runtime.h>


static void *kImageRadius = &kImageRadius;
@implementation UIImageView (RoundedCorner)
// 使用 method swizzling 替换掉 setImage 方法，当有radius时，把 radius 设置上
+ (void)load {
    // 在 load 方法里执行 method swizzling
     Method newMethod = class_getInstanceMethod(NSClassFromString(@"UIImageView"), @selector(zcy_setImage:));
    if (newMethod == NULL) {
        NSLog(@"method not found");
        return;
    }
    Method oldMethod = class_getInstanceMethod(NSClassFromString(@"UIImageView"), @selector(setImage:));
    method_exchangeImplementations(newMethod, oldMethod);
}

- (void)zcy_setImage:(UIImage *)image {
    NSNumber *radiusValue = objc_getAssociatedObject(self, kImageRadius);
    CGFloat radius = radiusValue.floatValue;
    if (radius > 0) {
        UIImage *roundedImage = [image zcy_imageWithRoundedCorner:radius size:self.bounds.size];
        [self zcy_setImage:roundedImage];
    } else {
        [self zcy_setImage:image];
    }
}

- (void)zcy_addRoundedCorner:(CGFloat)radius {
    NSAssert(radius >= 0, @"radius must greater or equal to zero!");
    if (self.image) {
        self.image = [self.image zcy_imageWithRoundedCorner:radius size:self.bounds.size];
    }
    // 用关联属性把 radius 设置到 self 上
    objc_setAssociatedObject(self, kImageRadius, @(radius), OBJC_ASSOCIATION_ASSIGN);
}



@end
