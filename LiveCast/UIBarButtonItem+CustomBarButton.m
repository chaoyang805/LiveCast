//
//  UIBarButtonItem+CustomBarButton.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "UIBarButtonItem+CustomBarButton.h"

@implementation UIBarButtonItem (CustomBarButton)

+ (instancetype)zcy_customBarButtonItemWithImageNamed:(nonnull NSString  *)normalImageName
                        highlightedImageNamed:(nullable NSString *)highlightedImageName
                                       target:(nullable id)target
                                     selector:(nullable SEL)selector
                                withEdgeInset:(UIEdgeInsets)edgeInsets {
    UIButton *button = [[UIButton alloc] init];
    
    [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    if (highlightedImageName)
        [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
    
    if (selector)
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    button.contentEdgeInsets = edgeInsets;
    [button sizeToFit];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}
@end
