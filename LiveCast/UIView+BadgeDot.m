//
//  UIView+BadgeDot.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIView+BadgeDot.h"
#import "UIView+RoundedCorner.m"
#import <objc/runtime.h>
#import "UIColor+HexStringColor.h"

void * UIViewAssociatedBadgeViewKey = "UIView.badgeView";
void * UIViewAssociatedBadgeColorKey = "UIView.badgeColor";

@implementation UIView (BadgeDot)

- (void)zcy_setBadgeColorWithColor:(UIColor *)color {
    objc_setAssociatedObject(self, UIViewAssociatedBadgeColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)zcy_showBadgeDotAtPoint:(CGPoint)point radius:(CGFloat)radius {
    [self zcy_showBadgeDotAtPoint:point radius:radius constraintBy:nil];
}
- (void)zcy_showBadgeDotAtPoint:(CGPoint)point radius:(CGFloat)radius constraintBy:(nullable ConstraintsBlock)constraintBlock {
    
    UIView *badgeView = objc_getAssociatedObject(self, UIViewAssociatedBadgeViewKey);
    if (badgeView) {
        return;
    }
    
    CGRect frame = CGRectMake(point.x, point.y, radius, radius);
    UIColor *badgeColor = objc_getAssociatedObject(self, UIViewAssociatedBadgeColorKey);
    if (!badgeColor) {
        badgeColor = [UIColor colorWithHexString:@"0xF03326"];
        objc_setAssociatedObject(self, UIViewAssociatedBadgeColorKey, badgeColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    badgeView = [[UIView alloc] initWithFrame:frame];
    badgeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [badgeView zcy_addRoundedCorner:CGRectGetMidX(badgeView.bounds)
                          fillColor:badgeColor
                    roundingCorners:UIRectCornerAllCorners];
    
    [self addSubview:badgeView];
    if (constraintBlock) {
        [self addConstraints:constraintBlock(badgeView)];
    }
//    NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:badgeView
//                                                                   attribute:NSLayoutAttributeCenterX
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self
//                                                                   attribute:NSLayoutAttributeTrailing
//                                                                  multiplier:1.0 constant:0];
//    
//    NSLayoutConstraint *vConstraint = [NSLayoutConstraint constraintWithItem:badgeView
//                                                                   attribute:NSLayoutAttributeTop
//                                                                   relatedBy:NSLayoutRelationEqual
//                                                                      toItem:self
//                                                                   attribute:NSLayoutAttributeTop
//                                                                  multiplier:1.0 constant:point.y];
//    
//    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:badgeView
//                                                              attribute:NSLayoutAttributeWidth
//                                                              relatedBy:NSLayoutRelationEqual toItem:nil
//                                                              attribute:NSLayoutAttributeNotAnAttribute
//                                                             multiplier:1.0 constant:radius];
//    
//    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:badgeView
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationEqual toItem:nil
//                                                              attribute:NSLayoutAttributeNotAnAttribute
//                                                             multiplier:1.0 constant:radius];
    
//    [self addConstraints:@[width, height, vConstraint, hConstraint]];
    
    objc_setAssociatedObject(self, UIViewAssociatedBadgeViewKey, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)zcy_hideBadgeDot {
    UIView *badgeView = objc_getAssociatedObject(self, UIViewAssociatedBadgeViewKey);
    if (badgeView) {
        [badgeView removeFromSuperview];
        objc_setAssociatedObject(self, UIViewAssociatedBadgeViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
