//
//  UITabBar+BadgeDot.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/18.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (BadgeDot)

- (void)showBadgeDotAtIndex:(NSUInteger)index;
- (void)clearBadgeDotAtIndex:(NSUInteger)index;
@end
