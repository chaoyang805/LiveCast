//
//  UIButton+BadgeDot.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <objc/runtime.h>
#import "UIButton+BadgeDot.h"

@implementation UIButton (BadgeDot)

- (void)zcy_showBadgeDot {
    CGFloat x = CGRectGetMaxX(self.bounds) * .7f;
    CGFloat y = 8;
    
    [self zcy_showBadgeDotAtPoint:CGPointMake(x, y) radius:8];
}

@end

@implementation UILabel (BadgeDot)

- (void)zcy_showBadgeDot {
    CGFloat radius = 8;
    [self layoutIfNeeded];
    CGFloat x = CGRectGetMaxX(self.bounds) - radius / 2;
    CGFloat y = CGRectGetMinY(self.bounds) - radius / 2;

    [self zcy_showBadgeDotAtPoint:CGPointMake(x, y) radius:radius constraintBy:^NSArray<NSLayoutConstraint *> *(UIView *badgeView) {
        
        NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:badgeView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0 constant:0];
        
        NSLayoutConstraint *vConstraint = [NSLayoutConstraint constraintWithItem:badgeView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0 constant:y];
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:badgeView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0 constant:radius];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:badgeView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0 constant:radius];
        
        return @[hConstraint, vConstraint, width, height];
        
    }];
}

@end
