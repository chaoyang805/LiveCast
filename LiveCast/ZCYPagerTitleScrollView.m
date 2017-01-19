//
//  ZCYPagerTitleScrollView.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/26.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYPagerTitleScrollView.h"
#import "UIColor+HexStringColor.h"

static const CGFloat kDefaultSpacing = 4;
static const CGFloat kDefaultIndicatorHeight = 4;
static const NSTimeInterval kAnimationDuration = 0.3;
@interface ZCYPagerTitleScrollView ()

@property (nonatomic, assign) CGFloat horizontalSpacing;
@property (nonatomic, copy) NSArray<ZCYLabel *> *titleLabels;
@property (nonatomic, readwrite, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, readwrite, strong) ZCYLabel *touchedLabel;

@end

@implementation ZCYPagerTitleScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        _horizontalSpacing = kDefaultSpacing;
        _highlightedColor = [UIColor colorWithHexString:@"0xFA8837"];
        _selectedIndex = 0;
        _indicatorHeight = kDefaultIndicatorHeight;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark scroll state

- (void)syncTitleStateWithProgress:(CGFloat)scrollProgress {
    // current -> next
    if (scrollProgress > 1) {
        if (self.selectedIndex >= self.titleLabels.count - 1) {
            return;
        }
        ZCYLabel *current = self.selectedLabel;
        ZCYLabel *next = self.titleLabels[self.selectedIndex + 1];
        
        current.alpha = 1 - fabs(1 - scrollProgress);
        next.alpha = fabs(1 - scrollProgress);
        
        CGFloat currentPositionX = CGRectGetMinX(current.frame);
        CGFloat nextPositionX = CGRectGetMinX(next.frame);
        
        CGFloat distance = nextPositionX - currentPositionX;
        CGFloat increment = distance * fabs(1 - scrollProgress);
        
        CGFloat x = CGRectGetMinX(current.frame) + increment;
        CGRect indicatorRect = CGRectMake(x, CGRectGetMinY(self.indicatorView.frame),
                                          CGRectGetWidth(self.indicatorView.frame),
                                          CGRectGetHeight(self.indicatorView.frame));
        self.indicatorView.frame = indicatorRect;
        // current -> prev
    } else if (scrollProgress < 1) {
        
        if (self.selectedIndex <= 0) {
            return;
        }
        ZCYLabel *current = self.selectedLabel;
        ZCYLabel *prev = self.titleLabels[self.selectedIndex - 1];
        
        current.alpha = scrollProgress;
        prev.alpha = fabs(1 - scrollProgress);
        
        CGFloat currentPositionX = CGRectGetMinX(current.frame);
        CGFloat nextPositionX = CGRectGetMinX(prev.frame);
        
        CGFloat distance = nextPositionX - currentPositionX;
        CGFloat increment = distance * fabs(1 - scrollProgress);
        CGFloat x = CGRectGetMinX(current.frame) + increment;
        CGRect indicatorRect = CGRectMake(x, CGRectGetMinY(self.indicatorView.frame),
                                          CGRectGetWidth(self.indicatorView.frame),
                                          CGRectGetHeight(self.indicatorView.frame));
        self.indicatorView.frame = indicatorRect;
    }
    
}

#pragma mark touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchedPoint = [touches.allObjects.firstObject locationInView:self];
    ZCYLabel *touchedLabel = [self findTouchedLabelWithPoint:touchedPoint];
    self.touchedLabel = touchedLabel;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint touchEndedPoint = [touches.allObjects.firstObject locationInView:self];
    
    if (!self.touchedLabel) {
        return;
    }
    if (self.touchedLabel == [self findTouchedLabelWithPoint:touchEndedPoint]) {
        
        NSUInteger selectedIndex = [self.titleLabels indexOfObject:self.touchedLabel];
        if (selectedIndex != NSNotFound) {
            if (self.pagerDelegate && [self.pagerDelegate respondsToSelector:@selector(pagerTitleScrollView:didSelectAtIndex:)]) {
                [self setSelected:selectedIndex];
                [self.pagerDelegate pagerTitleScrollView:self didSelectAtIndex:selectedIndex];
            }
        }
        self.touchedLabel = nil;
    }
}

- (nullable ZCYLabel *)findTouchedLabelWithPoint:(CGPoint)point {
    for (ZCYLabel *label in self.titleLabels) {
        if (CGRectContainsPoint(label.frame, point)) {
            return label;
        }
    }
    return nil;
}

#pragma mark layoutViews
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self layoutButtons];
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"0xEAEAEA"];
    bottomLine.frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 0.5f, CGRectGetWidth(self.bounds), 0.5f);
    [self addSubview:bottomLine];
}

- (void)layoutButtons {
    [self removeSubviews];
    
    NSMutableArray<ZCYLabel *> *allLabels = [NSMutableArray arrayWithCapacity:self.titles.count];
    
    for (NSString *title in self.titles) {
        ZCYLabel *label = [self labelForTitle:title];
        [allLabels addObject:label];
    }
    self.titleLabels = allLabels;
    CGSize scrollViewSize = [self calculateContentSizeWithLabels:allLabels];
    self.contentSize = scrollViewSize;
    
    BOOL canScroll = self.contentSize.width > CGRectGetWidth(self.bounds);
    if (!canScroll) {
        CGFloat labelWidth = (CGRectGetWidth(self.bounds) - (self.titleLabels.count - 1) * self.horizontalSpacing) / self.titleLabels.count;
        [self addLabelWithEqualWidth:labelWidth];
        self.scrollEnabled = NO;
    } else {
        [self addLabelWithExactWidth];
    }
    
    CGFloat x = CGRectGetMinX(self.selectedLabel.frame);
    CGFloat y = CGRectGetHeight(self.bounds) - self.indicatorHeight;
    CGFloat width = CGRectGetWidth(self.selectedLabel.bounds);
    CGFloat height = self.indicatorHeight;
    CGRect indicatorRect = CGRectMake(x, y, width, height);
    self.indicatorView = [[UIView alloc] initWithFrame:indicatorRect];
    self.indicatorView.backgroundColor = self.highlightedColor;
    
    [self addSubview:self.indicatorView];
    
    [self setSelected:self.selectedIndex];
}

- (void)removeSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)addLabelWithEqualWidth:(CGFloat)width {
    
    CGFloat currentLabelX = 0;
    
    for (ZCYLabel *label in self.titleLabels) {
        
        CGFloat x = currentLabelX;
        CGFloat y = CGRectGetMidY(self.bounds) - CGRectGetMidY(label.bounds) - self.indicatorHeight / 2;
        CGFloat height = CGRectGetHeight(label.frame);
        
        label.frame = CGRectMake(x, y, width, height);
        
        [self addSubview:label];
        currentLabelX += CGRectGetWidth(label.frame) + self.horizontalSpacing;
    }
}

- (void)addLabelWithExactWidth {
    CGFloat currentLabelX = 0;
    for (NSUInteger i = 0; i < self.titleLabels.count; i++) {
        ZCYLabel *label = self.titleLabels[i];
        
        CGFloat y = CGRectGetMidY(self.bounds) - CGRectGetMidY(label.bounds) - self.indicatorHeight / 2;
        label.frame = CGRectMake(
                                  currentLabelX,
                                  y,
                                  CGRectGetWidth(label.bounds),
                                  CGRectGetHeight(label.bounds)
                                  );
        
        [self addSubview:label];
        currentLabelX += CGRectGetWidth(label.bounds) + self.horizontalSpacing;
    }
}

- (CGSize)calculateContentSizeWithLabels:(NSArray<ZCYLabel *> *)labels {
    
    __block CGFloat width = (labels.count - 1) * self.horizontalSpacing;
    __block CGFloat maxHeight = 0;
    [labels enumerateObjectsUsingBlock:^(ZCYLabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        width += CGRectGetWidth(obj.bounds);
        CGFloat height = CGRectGetHeight(obj.bounds);
        
        if (height > maxHeight) {
            maxHeight = height;
        }
    }];
    
    CGSize contentSize = CGSizeMake(width, maxHeight + self.indicatorHeight);
    return contentSize;
}

- (ZCYLabel *)labelForTitle:(NSString *)title {
    
    ZCYLabel *label = [[ZCYLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 36)];
    label.text = title;
    [label sizeToFit];
    label.userInteractionEnabled = NO;
    label.selected = NO;
    label.tintColor = self.highlightedColor;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    return label;
}

#pragma mark selections

- (void)setSelected:(NSUInteger)index {
    [self clearSelection];
    [self labelForIndex:index].selected = YES;
    
    CGRect destButtonRect = [self labelForIndex:index].frame;
    CGRect destIndicatorRect = CGRectMake(
                                          CGRectGetMinX(destButtonRect),
                                          CGRectGetHeight(self.bounds) - self.indicatorHeight,
                                          CGRectGetWidth(destButtonRect),
                                          self.indicatorHeight
                                          );
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.indicatorView.frame = destIndicatorRect;
    } completion:^(BOOL finished) {
        [self scrollCurrentIndexToMiddle:index];
    }];
    
    self.selectedIndex = index;
    
}

- (void)scrollCurrentIndexToMiddle:(NSUInteger)index {
    if (!self.scrollEnabled) {
        return;
    }
    ZCYLabel *label = [self labelForIndex:index];
    CGFloat midX = CGRectGetMidX(label.frame);
    
    if (!(midX > CGRectGetWidth(self.bounds) / 2)) {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
        return;
    }
    
    CGFloat offset = midX - CGRectGetWidth(self.bounds) / 2;
    
    CGFloat maxOffset = self.contentSize.width - CGRectGetWidth(self.bounds);
    BOOL noScrollSpace = offset > maxOffset;
    
    if (noScrollSpace && offset > self.contentOffset.x) {
        [self setContentOffset:CGPointMake(maxOffset, 0) animated:YES];
    } else {
        [self setContentOffset:CGPointMake(offset, 0) animated:YES];
    }

}

- (void)clearSelection {
    ZCYLabel *selectedLabel = [self labelForIndex:self.selectedIndex];
    selectedLabel.selected = NO;
}

- (ZCYLabel *)labelForIndex:(NSUInteger)index {
    return self.titleLabels[index];
}

- (ZCYLabel *)selectedLabel {
    return [self labelForIndex:self.selectedIndex];
}
@end
