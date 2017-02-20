//
//  ZCYPagerViewController.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/21.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYPagerViewController.h"

@interface ZCYPagerViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, copy) NSArray<__kindof UIViewController *> *allViewControllers;
@property (nonatomic, copy) NSArray<NSString *> *allPageTitles;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, strong) ZCYPagerTitleScrollView *headerView;

@end

@implementation ZCYPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    // 解决 tableView 位置偏移的问题
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addPageViewControllerAsChild];
}

- (void)reloadPages {
    [self loadDataFromDataSource];

    self.currentPageIndex = 0;
    if (self.allViewControllers.count > 0) {
        UIViewController *currentViewController = self.allViewControllers[0];
        [self.pageViewController setViewControllers:@[currentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    self.headerView = [[ZCYPagerTitleScrollView alloc] initWithFrame: CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 40)];
    
    self.headerView.titles = self.allPageTitles;
    self.headerView.pagerDelegate = self;
    [self.view addSubview:self.headerView];
    
    
}

- (void)setHeaderViewToTop:(BOOL)top {
    if (top) {
        CGRect destFrame = CGRectMake(0, 20, CGRectGetWidth(self.headerView.bounds), CGRectGetHeight(self.headerView.bounds));
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.headerView.frame = destFrame;
                         }
                         completion:nil];
    } else {
        CGRect destFrame = CGRectMake(0, 64, CGRectGetWidth(self.headerView.bounds), CGRectGetHeight(self.headerView.bounds));
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.headerView.frame = destFrame;
                         }
                         completion:nil];
    }
}

#pragma mark Configure pageViewController

- (void)addPageViewControllerAsChild {
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.view.backgroundColor = [UIColor yellowColor];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    for (UIView *subview in self.pageViewController.view.subviews) {

        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).delegate = self;
            break;
        }
    }
}
// next [375, 750] / 375 - 1 [1, 2] current ↓ next ↑
// prev [375, 0]             [1, 0] current ↓ prev ↑
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"offset:%f", scrollView.contentOffset.x);
    CGFloat progress = scrollView.contentOffset.x / CGRectGetWidth(self.view.bounds);
    [self.headerView syncTitleStateWithProgress:progress];
}

#pragma mark Configure data source

- (void)loadDataFromDataSource {
    if (!self.dataSource) {
        self.pageCount = 0;
        self.allPageTitles = @[];
        self.allViewControllers = @[];
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberOfViewControllersInPagerController:)]) {
        self.pageCount = [self.dataSource numberOfViewControllersInPagerController:self];
    }
    
    if ([self.dataSource respondsToSelector:@selector(pagerController:viewControllerAtIndex:)]) {
        
        NSMutableArray<__kindof UIViewController *> *allControllers = [NSMutableArray arrayWithCapacity:self.pageCount];
        
        for (NSUInteger i = 0; i < self.pageCount; i++) {
            UIViewController * vc = [self.dataSource pagerController:self viewControllerAtIndex:i];
            [allControllers addObject:vc];
        }
        
        self.allViewControllers = allControllers;
    }
    
    NSMutableArray<NSString *> *allPageTitles = [NSMutableArray arrayWithCapacity:self.pageCount];
    
    if ([self.dataSource respondsToSelector:@selector(pagerController:titleForViewControllerAtIndex:)]) {
        
        for (NSUInteger i = 0; i < self.pageCount; i++) {
            
            NSString *title = [self.dataSource pagerController:self titleForViewControllerAtIndex:i];
            [allPageTitles addObject:title];
        }
        
        self.allPageTitles = allPageTitles;
        
    }
    
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return self.allViewControllers[index];
}

#pragma mark ZCYPagerTitleScrollViewDelegate

- (void)pagerTitleScrollView:(ZCYPagerTitleScrollView *)scrollView didSelectAtIndex:(NSUInteger)index {
    NSLog(@"current index:%lu ,select index %ld", (unsigned long)self.currentPageIndex, (unsigned long)index);
    UIPageViewControllerNavigationDirection direction = self.currentPageIndex > index ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    
    UIViewController *vc = [self.dataSource pagerController:self viewControllerAtIndex:index];
    // Can't animate this, otherwise it will cause wrong indicator position due to PageViewController's scrollView contentOfset callback get called while animating.
    [self.pageViewController setViewControllers:@[vc] direction:direction animated:NO completion:nil];
    self.currentPageIndex = index;
}

#pragma mark UIPageViewControllerDataSource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.allViewControllers indexOfObject:viewController];
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self.allViewControllers indexOfObject:viewController];
    if (index == self.pageCount - 1 || index == NSNotFound) {
        return nil;
    }
    index++;
    
    return [self viewControllerAtIndex:index];
}

#pragma mark UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
    self.currentPageIndex = [self.allViewControllers indexOfObject:pendingViewControllers[0]];
    
    if (!self.delegate) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(pagerController:willScrollFromCurrentViewController:toNextViewController:)]) {
        
        UIViewController *currentViewController = self.allViewControllers[self.currentPageIndex];
        UIViewController *nextViewController = pendingViewControllers[0];
        
        [self.delegate pagerController:self willScrollFromCurrentViewController:currentViewController toNextViewController:nextViewController];
    }
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (!completed || !self.delegate) {
        return;
    }
    [self.headerView setSelected:self.currentPageIndex];
    
    if ([self.delegate respondsToSelector:@selector(pagerController:didScrollToViewController:atIndex:)]) {
        [self.delegate pagerController:self didScrollToViewController:self.allViewControllers[self.currentPageIndex] atIndex:self.currentPageIndex];
    }
    
}

- (UIInterfaceOrientationMask)pageViewControllerSupportedInterfaceOrientations:(UIPageViewController *)pageViewController {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)pageViewControllerPreferredInterfaceOrientationForPresentation:(UIPageViewController *)pageViewController {
    return UIInterfaceOrientationPortrait;
}


@end
