//
//  NSString+ZCYTabBarItem.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "UIViewController+ZCYTabBarItem.h"

@implementation UIViewController (ZCYTabBarItem)

- (void)zcy_setTabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image selectedImage:selectedImage];
}

@end
