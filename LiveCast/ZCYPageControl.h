//
//  ZCYPageControl.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/16.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCYPageControl : UIView

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

@property (nonatomic, strong) UIColor *pageIndicatorTintColor;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

- (instancetype)initWithFrame:(CGRect)frame;

@end

