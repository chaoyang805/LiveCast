//
//  ZCYPageControl.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/16.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYPageControl.h"
#import "UIColor+HexStringColor.h"
#import "ZCYDotWrapper.h"

static const CGFloat kDefaultDotSpacing = 5;

@interface ZCYPageControl ()

@property (nonatomic, strong) UIView *currentPageDot;
@property (nonatomic, assign) CGFloat dotSpacing;
@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, assign) CGSize currentDotSize;
@property (nonatomic, copy) NSArray<ZCYDotWrapper *> *allDots;

@end

@implementation ZCYPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _numberOfPages = 0;
        _dotSpacing = kDefaultDotSpacing;
        _currentPage = 0;
        _dotSize = CGSizeMake(6, 6);
        _currentDotSize = CGSizeMake(12, 6);
        
        _currentPageIndicatorTintColor = [UIColor colorWithHexString:@"0xFA8837"];
        _pageIndicatorTintColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
    }
    return self;
}
- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    self.subviews.lastObject.backgroundColor = _currentPageIndicatorTintColor;
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    if (self.subviews.count <= 0) {
        return;
    }
    for (NSUInteger i = 0; i < self.subviews.count - 1; i++) {
        
        self.subviews[i].backgroundColor = _pageIndicatorTintColor;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    CGFloat dotsWidth = _currentDotSize.width + (_numberOfPages - 1) * (_dotSize.width + _dotSpacing);
    CGFloat dotsHeight = _dotSize.height;
    CGFloat x = (CGRectGetWidth(self.bounds) - dotsWidth) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - dotsHeight) / 2;
    
    NSMutableArray<ZCYDotWrapper *> *dots = [NSMutableArray array];
    
    for (NSInteger i = 0; i < _numberOfPages; i++) {
        CGFloat dotX, dotY;
        
        if (i == 0) {
            dotX = x;
            dotY = y;
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(dotX, dotY, _currentDotSize.width, _currentDotSize.height)];
            dot.backgroundColor = _currentPageIndicatorTintColor;
            dot.layer.cornerRadius = _dotSize.height / 2;
            
            [self addSubview:dot];
            
            [dots addObject:[[ZCYDotWrapper alloc] initWithDotView:dot atIndex:i]];
            
        } else {
            CGFloat dotX = x + _currentDotSize.width + (i - 1) * _dotSize.width + i * _dotSpacing;
            CGFloat dotY = y;
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(dotX, dotY, _dotSize.width, _dotSize.height)];
            dot.layer.cornerRadius = _dotSize.height / 2;
            dot.backgroundColor = _pageIndicatorTintColor;
            
            [dots addObject:[[ZCYDotWrapper alloc] initWithDotView:dot atIndex:i]];
            [self addSubview:dot];
        }
        
        self.allDots = dots;
        [self bringSubviewToFront:dots[0].dotView];
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    
    if (currentPage == _currentPage) {
        return;
    }
    NSInteger destPage = currentPage;
    NSInteger prevPage = _currentPage;
    
    NSInteger delta = destPage - prevPage;
    
    ZCYDotWrapper *prevDot = [self dotAtIndex:destPage];
    ZCYDotWrapper *currentDot = [self dotAtIndex:prevPage];
    
    CGFloat currentDestX = 0;
    CGFloat prevDestX = 0;
    NSMutableArray<ZCYDotWrapper *> *pendingDots = [NSMutableArray array];
    
    NSValue *offsetValue = nil;
    
    if (delta > 0) {
        
        // 大的向后走
        // bigDestY = smallOriginX - 12;
        // smallDestY = bigOriginX;
        currentDestX = CGRectGetMinX(prevDot.dotView.frame) - _dotSize.width;
        prevDestX = CGRectGetMinX(currentDot.dotView.frame);
        
        for (NSUInteger i = prevPage + 1; i < destPage; i++) {
            ZCYDotWrapper *dotWrapper = [self dotAtIndex:i];
            if (dotWrapper) {
                [pendingDots addObject:dotWrapper];
            }
        }
        
        offsetValue = [NSValue valueWithCGPoint:CGPointMake(-_dotSize.width, 0)];
    } else if (delta < 0) {
        
        // 大的向前走
        // bigDestY = smallOriginX;
        // smallDestY = originBigX + 12;
        currentDestX = CGRectGetMinX(prevDot.dotView.frame);
        prevDestX = CGRectGetMinX(currentDot.dotView.frame) + _dotSize.width;
        
        for (NSUInteger i = destPage + 1; i < prevPage; i++) {
            ZCYDotWrapper *dotWrapper = [self dotAtIndex:i];
            if (dotWrapper) {
                [pendingDots addObject:dotWrapper];
            }
        }
        offsetValue = [NSValue valueWithCGPoint:CGPointMake(_dotSize.width, 0)];
    }
    
    [prevDot animateWithOffset:[NSValue valueWithCGPoint:CGPointMake(prevDestX - prevDot.origin.x, 0)]];
    [currentDot animateWithOffset:[NSValue valueWithCGPoint:CGPointMake(currentDestX - currentDot.origin.x, 0)]];
    [pendingDots makeObjectsPerformSelector:@selector(animateWithOffset:) withObject:offsetValue];
    
    prevDot.index = prevPage;
    currentDot.index = destPage;
    
    _currentPage = currentPage;
}

- (ZCYDotWrapper *)dotAtIndex:(NSUInteger)index {
    
    __block ZCYDotWrapper *result = nil;
    [self.allDots enumerateObjectsUsingBlock:^(ZCYDotWrapper * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.index == index) {
            
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

@end


