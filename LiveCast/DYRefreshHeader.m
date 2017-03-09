//
//  DYRefreshHeader.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/3/6.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYRefreshHeader.h"
#import "UIColor+HexStringColor.h"

#define GIF_VIEW_H 27
#define REFRESH_HEADER_H 220
#define REFRESH_LABEL_INSET_T 42

#pragma mark - ZCYWaveView

@interface ZCYWaveView : UIView <CAAnimationDelegate>

@property (nonatomic, strong) UIColor *waveColor;
@property (nonatomic, assign) CGRect layerFrame;
/**
 水波纹出现的的间隔帧数
 */
@property (nonatomic, assign) NSRange frequencyRange;

@property (nonatomic, strong) CADisplayLink *displayLink;

- (void)start;

- (void)stop;
@end

@implementation ZCYWaveView {
    NSInteger _updateCount;
    NSInteger _nextUpdate;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        _waveColor = [UIColor whiteColor];
        _frequencyRange = NSMakeRange(5, 3); // 5 ~ 15
    }
    return self;
}

- (void)start {
    self.clipsToBounds = YES;
    _nextUpdate = 2;
    _updateCount = 0;
    if (self.displayLink != nil) {
        return;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop {
    [self.displayLink invalidate];
    self.displayLink = nil;
    _updateCount = 0;
    _nextUpdate = 0;
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

- (void)update:(CADisplayLink *)dispalyLink {
    _updateCount++;
    if (_updateCount == _nextUpdate) {
        _nextUpdate = arc4random_uniform((uint32_t)self.frequencyRange.length) + self.frequencyRange.location;
        
        _updateCount = 0;
        [self addAnimationLayer];
    }
}

- (void)addAnimationLayer {
    CAShapeLayer *waveLayer = [CAShapeLayer layer];
    waveLayer.strokeColor = self.waveColor.CGColor;
    waveLayer.fillColor = [UIColor clearColor].CGColor;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat minSide = MIN(width, height);
    waveLayer.frame = CGRectMake((width - minSide) / 2, (height - minSide) / 2, minSide, minSide);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, minSide, minSide)];
    waveLayer.path = circlePath.CGPath;
    
    [self.layer addSublayer:waveLayer];
    [waveLayer addAnimation:[self animationForWaveLayer] forKey:nil];
}

- (CAAnimation *)animationForWaveLayer {
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.f);
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CGFloat scaleRatio = MAX(self.frame.size.width, self.frame.size.height) / MIN(self.frame.size.width, self.frame.size.height);
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 0.0)];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, scaleRatio, scaleRatio, 0.0)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[alphaAnimation, scaleAnimation];
    group.duration = 1.3f;
    group.autoreverses = NO;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    return group;
}

@end

#pragma mark - DYRefreshHeader
@interface DYRefreshHeader ()

@property (nonatomic, assign) CGFloat insetTDelta;
@property (nonatomic, strong) UIImageView *curveBottomView;
@property (nonatomic, assign, readonly) CGFloat refreshHeight;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) ZCYWaveView *waveView;

@end

@implementation DYRefreshHeader

- (void)prepare {
    [super prepare];
    self.mj_h = REFRESH_HEADER_H;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithHexString:@"0xF2F2F2"];

    [self addSubview:self.refreshLabel];
    
    [self addSubview:self.waveView];
    
    self.curveBottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh-header-title"]];
    [self addSubview:self.curveBottomView];
    
    // gifView
    [self setupAnimationGifView];
}

- (void)setupAnimationGifView {
    UIImage *idleImage = [UIImage imageNamed:@"img_mj_stateIdle"];
    NSMutableArray *idleImages = [NSMutableArray arrayWithObjects:idleImage, nil];
    NSMutableArray *pullingImages = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"img_mj_statePulling"], nil];
    NSMutableArray *refreshingImages = [NSMutableArray array];
    
    for (NSUInteger i = 1; i < 5; i++) {
        UIImage *refreshingImage = [UIImage imageNamed:[NSString stringWithFormat:@"img_mj_stateRefreshing_0%lu", i]];
        [refreshingImages addObject:refreshingImage];
    }
    
    [self setImages:idleImages forState:MJRefreshStateIdle];
    [self setImages:pullingImages forState:MJRefreshStatePulling];
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
    
    UIImageView *gifView = self.gifView;
    [gifView removeFromSuperview];
    gifView.mj_x = CGRectGetMidX(self.curveBottomView.bounds);
    [self.curveBottomView addSubview:gifView];
}
#pragma mark - 懒加载属性
- (UILabel *)refreshLabel {
    if (!_refreshLabel) {
        UILabel *refreshLabel = [[UILabel alloc] init];
        refreshLabel.font = [UIFont systemFontOfSize:13];
        refreshLabel.text = @"松手加载";
        refreshLabel.textColor = [UIColor colorWithHexString:@"C7C7C7"];
        refreshLabel.textAlignment = NSTextAlignmentCenter;
        [refreshLabel sizeToFit];
        _refreshLabel = refreshLabel;
    }
    return _refreshLabel;
}

- (ZCYWaveView *)waveView {
    if (!_waveView) {
        ZCYWaveView *waveView = [[ZCYWaveView alloc] initWithFrame:CGRectMake(0, self.mj_h / 2, self.mj_w, 100)];
        
        _waveView.waveColor = [UIColor whiteColor];
        _waveView.backgroundColor = [UIColor redColor];
        _waveView = waveView;
    }
    return _waveView;
}

- (CGFloat)refreshHeight {
    return 74;
}
#pragma mark - 刷新状态
- (void)beginRefreshing {
    [super beginRefreshing];
    [self.waveView start];
}

- (void)endRefreshing {
    [super endRefreshing];
    [self.waveView stop];
}
#pragma mark - 布局view
- (void)placeSubviews {
    [super placeSubviews];
    
    self.refreshLabel.center = CGPointMake(CGRectGetMidX(self.bounds), REFRESH_LABEL_INSET_T);
    if (self.state == MJRefreshStateRefreshing) {
        self.waveView.mj_w = self.mj_w;
        self.curveBottomView.mj_y = CGRectGetMaxY(self.bounds) - 20;
        self.gifView.mj_y = -GIF_VIEW_H;
    } else if (self.state == MJRefreshStateIdle) {
        self.curveBottomView.mj_w = self.mj_w;
        self.curveBottomView.mj_origin = CGPointMake(0, CGRectGetMaxY(self.bounds));
        self.gifView.mj_y = CGRectGetMinY(self.curveBottomView.bounds);
    }
}
#pragma mark - scrollView 滚动监听
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    // 刷新状态
    if (self.state == MJRefreshStateRefreshing) {
        if (self.window == nil) return; // window == nil，直接 return
        
        // sectionHeader 停留解决
        CGFloat insetTop = - self.scrollView.mj_offsetY > _scrollViewOriginalInset.top ? - self.scrollView.mj_offsetY : _scrollViewOriginalInset.top;
        insetTop = insetTop > self.refreshHeight + _scrollViewOriginalInset.top ? self.refreshHeight + _scrollViewOriginalInset.top : insetTop;
        
        self.scrollView.mj_insetT = insetTop;
        self.insetTDelta = _scrollViewOriginalInset.top - insetTop;
        return;
    }
    
    _scrollViewOriginalInset = self.scrollView.contentInset;
    
    // 当前的 contentOffset
    CGFloat offsetY = self.scrollView.mj_offsetY;
    // 头部刚好出现的 offset
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    if (offsetY > happenOffsetY) return; // 向上划直接返回
    CGFloat fullVisibleY = CGRectGetMaxY(self.bounds) - 70;
    if (self.curveBottomView.mj_y >= fullVisibleY && self.state != MJRefreshStateRefreshing) {
        self.curveBottomView.mj_y = CGRectGetMaxY(self.bounds) + (offsetY - happenOffsetY) / 2;
        if (self.curveBottomView.mj_y <= fullVisibleY) {
            self.curveBottomView.mj_y = fullVisibleY;
        }
    }
    
    CGFloat normal2PullingOffsetY = happenOffsetY - self.refreshHeight;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.refreshHeight;
    
    if (self.scrollView.isDragging) {
        self.pullingPercent = pullingPercent;
        if (self.state == MJRefreshStateIdle && offsetY < normal2PullingOffsetY) {
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && offsetY >= normal2PullingOffsetY) {
            self.state = MJRefreshStateIdle;
        }
    } else if (self.state == MJRefreshStatePulling) {
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
    
}
@end
