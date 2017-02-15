//
//  UIBarButtonItem+CustomBarButton.h
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIBarButtonItem (CustomBarButton)
+ (instancetype)zcy_customBarButtonItemWithImageNamed:(nonnull NSString  *)normalImageName
                        highlightedImageNamed:(nullable NSString *)highlightedImageName
                                       target:(nullable id)target
                                     selector:(nullable SEL)selector
                                withEdgeInset:(UIEdgeInsets)edgeInsets;
@end
NS_ASSUME_NONNULL_END
