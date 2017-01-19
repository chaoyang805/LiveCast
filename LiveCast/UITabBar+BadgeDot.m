//
//  UITabBar+BadgeDot.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/18.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UITabBar+BadgeDot.h"
#import "UIView+RoundedCorner.h"
#import "UIColor+HexStringColor.h"
#import <objc/runtime.h>

#define VIEW_TAG 2327
const void *badgeColorKey;
@implementation UITabBar (BadgeDot)

- (void)showBadgeDotAtIndex:(NSUInteger)index {
    
    if (index >= self.items.count) {
        NSLog(@"index out of bounds %@", NSStringFromSelector(_cmd));
        return;
    }
    
    UITabBarItem *item = self.items[index];
    if (item.badgeValue) {
        NSLog(@"already has a badge %@", NSStringFromSelector(_cmd));
        return;
    }
    UIView *tabBarView = self.subviews[index + 1];
    UIView *tabBarImage = tabBarView.subviews[0];
    CGFloat x = CGRectGetMaxX(tabBarImage.frame) - 3;
    CGFloat y = 2;
    UIView *badgeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 8, 8)];
    UIColor *badgeColor = item.badgeColor;
    if (!badgeColor) {
        badgeColor = objc_getAssociatedObject(self, badgeColorKey);
        
        if (!badgeColor) {
            badgeColor = [UIColor colorWithHexString:@"0xF03326"];
            objc_setAssociatedObject(self, badgeColorKey, badgeColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    [badgeView zcy_addRoundedCorner:CGRectGetWidth(badgeView.bounds) / 2 fillColor:badgeColor roundingCorners:UIRectCornerAllCorners];
    
    badgeView.tag = VIEW_TAG + index;
    [tabBarView addSubview:badgeView];
    
}

- (void)clearBadgeDotAtIndex:(NSUInteger)index {
    if (index >= self.items.count) {
        return;
    }
    UIView *tabBarView = self.subviews[index + 1];
    NSUInteger tag = VIEW_TAG + index;
    UIView *badgeView = [tabBarView viewWithTag:tag];
    if (badgeView) {
        [badgeView removeFromSuperview];
    }
}

@end
