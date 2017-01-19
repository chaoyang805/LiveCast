//
//  ZCYPagerViewController.h
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/21.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCYPagerTitleScrollView.h"
@class ZCYPagerViewController;


@protocol ZCYPagerViewControllerDelegate <NSObject>

- (void)pagerController:(ZCYPagerViewController *)pagerController didScrollToViewController:(UIViewController *)currentViewController atIndex:(NSUInteger)index;

- (void)pagerController:(ZCYPagerViewController *)pagerController willScrollFromCurrentViewController:(UIViewController *)currentVC toNextViewController:(UIViewController *)nextVC;

@end

@protocol ZCYPageViewControllerDataSource <NSObject>

- (__kindof UIViewController *)pagerController:(ZCYPagerViewController *)pagerController viewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfViewControllersInPagerController:(ZCYPagerViewController *)pagerController;

- (NSString *)pagerController:(ZCYPagerViewController *)pagerController titleForViewControllerAtIndex:(NSUInteger)index;


@end

@interface ZCYPagerViewController : UIViewController <ZCYPagerTitleScrollViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate>

@property (nonatomic, weak) id<ZCYPagerViewControllerDelegate> delegate;
@property (nonatomic, weak) id<ZCYPageViewControllerDataSource> dataSource;
@property (nonatomic, assign) NSUInteger currentPageIndex;

- (void)reloadPages;
- (void)setHeaderViewToTop:(BOOL)top;
@end
