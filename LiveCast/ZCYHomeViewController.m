//
//  ZCYHomeViewController.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYHomeViewController.h"
#import "ZCYDetailViewController.h"
#import "UIColor+HexStringColor.h"
#import "UIBarButtonItem+CustomBarButton.h"
#import "ZCYRecommendViewController.h"
#import "UITabBar+BadgeDot.h"

@interface ZCYHomeViewController ()

@property (nonatomic, copy) NSArray<UIViewController *> *pages;
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, strong) NSMutableArray<UIScrollView *> *observedScrollView;
@end

@implementation ZCYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBarAppearence];
    
    self.delegate = self;
    self.dataSource = self;
    
    ZCYRecommendViewController *redView = [[ZCYRecommendViewController alloc] initWithNibName:@"ZCYRecommendViewController" bundle:nil];
    
    UIViewController *blueView = [[UIViewController alloc] init];
    blueView.view.backgroundColor = [UIColor blueColor];
    
    UIViewController *yellowView = [[UIViewController alloc] init];
    yellowView.view.backgroundColor = [UIColor yellowColor];
    
    UIViewController *greenView = [UIViewController new];
    greenView.view.backgroundColor = [UIColor greenColor];
    
    UIViewController *grayView = [UIViewController new];
    grayView.view.backgroundColor = [UIColor grayColor];
    
    self.pages = @[redView, blueView, yellowView, greenView, grayView];
    self.titles = @[@"推荐", @"手游", @"娱乐", @"游戏", @"趣玩"];
    [self reloadPages];
    UIView *view = redView.view;
    
    if ([view isKindOfClass:[UIScrollView class]]) {
        
        [view addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:nil];
        [self.observedScrollView addObject:(UIScrollView *)view];
    } else {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                [subview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:nil];
                [self.observedScrollView addObject:(UIScrollView *)subview];
                break;
            }
        }
    }
}

- (NSMutableArray<UIScrollView *> *)observedScrollView {
    if (!_observedScrollView) {
        _observedScrollView = [NSMutableArray array];
    }
    return _observedScrollView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIScrollView *scrollView = (UIScrollView *)object;
    CGPoint oldOffset = ((NSValue *)change[NSKeyValueChangeOldKey]).CGPointValue;
    CGPoint newOffset = scrollView.contentOffset;
    
    if (oldOffset.y < newOffset.y && newOffset.y > 0) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self setHeaderViewToTop:YES];
    } else if (oldOffset.y > newOffset.y && newOffset.y < scrollView.contentSize.height - scrollView.bounds.size.height) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self setHeaderViewToTop:NO];
    }
}

- (void)dealloc {
    
    for (UIScrollView *scrollView in self.observedScrollView) {
        [scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observedScrollView = nil;
    }
}

#pragma ZCYPagerViewController data source
- (__kindof UIViewController *)pagerController:(ZCYPagerViewController *)pagerController viewControllerAtIndex:(NSUInteger)index {
    return self.pages[index];
}

- (NSUInteger)numberOfViewControllersInPagerController:(ZCYPagerViewController *)pagerController {
    return self.pages.count;
}

- (NSString *)pagerController:(ZCYPagerViewController *)pagerController titleForViewControllerAtIndex:(NSUInteger)index {
    return self.titles[index];
}

#pragma ZCYPagerViewController delegate

- (void)pagerController:(ZCYPagerViewController *)pagerController didScrollToViewController:(UIViewController *)currentViewController atIndex:(NSUInteger)index {
    NSLog(@"did scroll to %lu", index);
}

- (void)pagerController:(ZCYPagerViewController *)pagerController willScrollFromCurrentViewController:(UIViewController *)currentVC toNextViewController:(UIViewController *)nextVC {
    NSLog(@"will scroll to next VC");
}

#pragma mark NavigationBar appearence

- (void)setupNavigationBarAppearence {
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"0xFA8837"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem =
        [UIBarButtonItem zcy_customBarButtonItemWithImageNamed:@"homeLogoIcon"
                                         highlightedImageNamed:nil
                                                        target:nil
                                                      selector:nil
                                                 withEdgeInset:UIEdgeInsetsMake(0, -10, 0, 0)];
    
    UIEdgeInsets rightButtonInset = UIEdgeInsetsMake(10, 10, 10, 10);
    UIBarButtonItem *siteMessageItem =
        [UIBarButtonItem zcy_customBarButtonItemWithImageNamed:@"siteMessageHome"
                                         highlightedImageNamed:@"siteMessageHomeH"
                                                        target:nil
                                                      selector:nil
                                                 withEdgeInset:rightButtonInset];
    ;
    
    UIBarButtonItem *viewHistoryItem =
        [UIBarButtonItem zcy_customBarButtonItemWithImageNamed:@"viewHistoryIcon"
                                         highlightedImageNamed:@"viewHistoryIconHL"
                                                        target:nil
                                                      selector:nil
                                                 withEdgeInset:rightButtonInset];
    
    UIBarButtonItem *scanItem =
        [UIBarButtonItem zcy_customBarButtonItemWithImageNamed:@"scanIcon"
                                         highlightedImageNamed:@"scanIconHL"
                                                        target:nil
                                                      selector:nil
                                                 withEdgeInset:rightButtonInset];
    
    UIBarButtonItem *searchItem =
        [UIBarButtonItem zcy_customBarButtonItemWithImageNamed:@"searchBtnIcon"
                                         highlightedImageNamed:@"searchBtnIconHL"
                                                        target:nil
                                                      selector:nil
                                                 withEdgeInset:rightButtonInset];
    
    self.navigationItem.rightBarButtonItems = @[searchItem, scanItem, viewHistoryItem, siteMessageItem];
}


- (IBAction)didClickButton:(id)sender {
    ZCYDetailViewController *detailVC = [[ZCYDetailViewController alloc] initWithNibName:@"ZCYDetailViewController" bundle:nil];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

@end
