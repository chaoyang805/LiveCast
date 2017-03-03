//
//  ZCYPagerTitleScrollView.h
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/26.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYLabel.h"
@class ZCYPagerTitleScrollView;

@protocol ZCYPagerTitleScrollViewDelegate <NSObject>

@optional
- (void)pagerTitleScrollView:(ZCYPagerTitleScrollView *)scrollView didSelectAtIndex:(NSUInteger)index;

@end
@interface ZCYPagerTitleScrollView : UIScrollView

@property (nonatomic, weak) id<ZCYPagerTitleScrollViewDelegate> pagerDelegate;
@property (nonatomic, readonly, strong) ZCYLabel *selectedLabel;
@property (nonatomic, readonly, assign) NSUInteger selectedIndex;
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, strong) UIColor *highlightedColor;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setTitles:(NSArray<NSString *> *)titles;
- (void)setSelected:(NSUInteger)index;
- (ZCYLabel *)labelForIndex:(NSUInteger)index;
- (void)syncTitleStateWithProgress:(CGFloat)scrollProgress;
@end
