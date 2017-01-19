//
//  JKBannerView.m
//  Banner
//
//  Created by chaoyang805 on 2016/12/21.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYBannerView.h"
#import "UIColor+HexStringColor.h"
#import "ZCYPageControl.h"

static const NSTimeInterval kDefaultTimeInterval = 4;
static const CGFloat kDefaultPageControlHeight = 20;
static const NSTimeInterval kMinimumTimeInterval = 1;

@interface ZCYBannerView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ZCYPageControl *pageControl;
@property (nonatomic, readwrite, assign) NSUInteger currentPage;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizer;

@end

@implementation ZCYBannerView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _autoScrollTimeInterval = kDefaultTimeInterval;
        _autoScrollEnabled = YES;
        _pageControlEnabled = YES;
        _currentPage = 0;
        _bannerItems = @[];
    }
    return self;
}

- (instancetype)initWithBannerItems:(NSArray<id<ZCYBannerItemType>> *)bannerItems frame:(CGRect)frame {
    self = [super init];
    if (self) {
        _autoScrollTimeInterval = kDefaultTimeInterval;
        _autoScrollEnabled = YES;
        _pageControlEnabled = YES;
        _currentPage = 0;
        self.frame = frame;
        
        NSMutableArray<id<ZCYBannerItemType>> *cycleItems = [bannerItems mutableCopy];
        [cycleItems insertObject:bannerItems[bannerItems.count - 1] atIndex:0];
        [cycleItems addObject:bannerItems[0]];
        _bannerItems = [cycleItems copy];
    }
    return self;
}

#pragma mark setter getter

- (void)setBannerItems:(NSArray<id<ZCYBannerItemType>> *)bannerItems {
    NSMutableArray<id<ZCYBannerItemType>> *cycleItems = [bannerItems mutableCopy];
    [cycleItems insertObject:bannerItems[bannerItems.count - 1] atIndex:0];
    [cycleItems addObject:bannerItems[0]];
    _bannerItems = [cycleItems copy];
    [self setup];
}

- (NSUInteger)count {
    
    return self.bannerItems.count;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
//    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setup];
}

- (void)setup {
    
    [self addGestureRecognizer:self.gestureRecognizer];
    
    [self loadScrollView];
    // pageControl
    [self loadPageControl];
    // timer
    if (self.autoScrollEnabled) {
        [self startTimer];
    }
}

#pragma mark TapGestureRecognizer

- (UITapGestureRecognizer *)gestureRecognizer {
    if (!_gestureRecognizer) {
        _gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    }
    return _gestureRecognizer;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:tappedAtIndex:withBannerItem:)]) {
        [self.delegate bannerView:self tappedAtIndex:self.currentPage withBannerItem:self.bannerItems[self.currentPage + 1]];
    }
}

#pragma mark UIScrollView

- (void)loadScrollView {
    if (self.scrollView.superview) {
        [self.scrollView removeFromSuperview];
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    CGFloat contentWidth = self.count * self.bounds.size.width;
    self.scrollView.contentSize = CGSizeMake(contentWidth ,self.bounds.size.height);
    
    for (NSUInteger i = 0; i < self.count; i++) {
        UIImage *image = self.bannerItems[i].bannerImage;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        CGFloat x = i * width;
        CGFloat y = 0;
        
        imageView.frame = CGRectMake(x, y, width, height);
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    [self addSubview:self.scrollView];
}


#pragma mark pageControl

- (void)loadPageControl {
    
    if (self.pageControl && self.pageControl.superview) {
        [self.pageControl removeFromSuperview];
    }
    
    if (!self.pageControlEnabled) {
        return;
    }
    
    CGFloat pageControlHeight = kDefaultPageControlHeight;
    self.pageControl = [[ZCYPageControl alloc] initWithFrame:
                        CGRectMake(
                                   0,
                                   self.bounds.size.height - pageControlHeight,
                                   self.bounds.size.width,
                                   pageControlHeight
                                   )];
    self.pageControl.numberOfPages = self.count - 2;
    self.pageControl.currentPage = 0;
    [self addSubview:self.pageControl];
}

#pragma mark Timer

- (void)setAutoScrollTimeInterval:(NSTimeInterval)autoScrollTimeInterval {
    if (autoScrollTimeInterval < kMinimumTimeInterval) {
        _autoScrollTimeInterval = kMinimumTimeInterval;
    } else {
        _autoScrollTimeInterval = autoScrollTimeInterval;
    }
    [self resetTimer];
}

- (void)resetTimer {
    [self stopTimer];
    [self startTimer];
}

- (void)startTimer {
    if (!self.autoScrollEnabled) {
        return;
    }
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
    }
    
}

- (void)stopTimer {
    if (!self.autoScrollEnabled) {
        return;
    }
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollToNextPage {
    CGFloat currentOffsetX = self.scrollView.contentOffset.x;
    CGPoint nextOffset = CGPointMake(currentOffsetX + self.bounds.size.width, 0);
    [self.scrollView setContentOffset:nextOffset animated:YES];

    CGFloat currentPage = (self.currentPage + 1) % (self.count - 2);
    self.currentPage = (NSUInteger)currentPage;
    
    if (self.pageControlEnabled) {
        
        self.pageControl.currentPage = currentPage;
    }
}

- (void)dealloc {
    [self stopTimer];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX == 0) {
        [scrollView setContentOffset:CGPointMake((self.count - 2) * self.bounds.size.width, 0)];
    } else if (offsetX == (self.count - 1) * self.bounds.size.width) {
        [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentPage = scrollView.contentOffset.x / self.bounds.size.width - 1;
    
    self.currentPage = currentPage;
    if (self.pageControlEnabled) {
        self.pageControl.currentPage = (NSUInteger)currentPage;
    }
}


@end
