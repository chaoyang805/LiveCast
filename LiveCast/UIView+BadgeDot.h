//
//  UIView+BadgeDot.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSArray<NSLayoutConstraint *> * _Nonnull (^ConstraintsBlock)(UIView * _Nonnull  viewToConstraint);

@interface UIView (BadgeDot)

- (void)zcy_showBadgeDotAtPoint:(CGPoint)point radius:(CGFloat)radius constraintBy:(nullable ConstraintsBlock)constraintBlock;
- (void)zcy_showBadgeDotAtPoint:(CGPoint)point radius:(CGFloat)radius;
- (void)zcy_setBadgeColorWithColor:(UIColor * _Nonnull)color;
- (void)zcy_hideBadgeDot;
@end
