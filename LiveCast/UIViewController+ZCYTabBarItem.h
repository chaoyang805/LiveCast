//
//  NSString+ZCYTabBarItem.h
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ZCYTabBarItem)

- (void)zcy_setTabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
@end
