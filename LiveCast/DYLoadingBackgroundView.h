//
//  DYLoadingBackgroundView.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/3/6.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYLoadingBackgroundView : UIView

- (void)startAnimating;

- (void)stopAnimating;

- (instancetype)initWithFrame:(CGRect)frame animationImages:(NSArray<UIImage *> *)images;

@end
