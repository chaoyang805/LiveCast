//
//  DYLoadingBackgroundView.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/3/6.
//  Copyright © 2017年. All rights reserved.
//

#import "DYLoadingBackgroundView.h"
#import "UIColor+HexStringColor.h"
static const NSTimeInterval kAnimationDuration = 0.5f;
static NSString * const kLoadingText = @"内容正在加载...";
static const CGFloat kLoadingTextFontSize = 11;
@interface DYLoadingBackgroundView ()

@property (nonatomic, strong) UIImageView *animatedImageView;
@property (nonatomic, strong) UILabel *loadingLabel;
@end

@implementation DYLoadingBackgroundView

- (instancetype)initWithFrame:(CGRect)frame animationImages:(NSArray<UIImage *> *)images {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xF4F4F4"];
        
        _animatedImageView = [[UIImageView alloc] init];
        _animatedImageView.animationDuration = kAnimationDuration;
        _animatedImageView.animationImages = images;
        _animatedImageView.contentMode = UIViewContentModeCenter;
        
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.text = kLoadingText;
        _loadingLabel.font = [UIFont systemFontOfSize:kLoadingTextFontSize];
        _loadingLabel.textColor = [UIColor colorWithHexString:@"0xB4B4B4"];
        
        [self addSubview:_animatedImageView];
        [self addSubview:_loadingLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.animatedImageView sizeToFit];
    [self.loadingLabel sizeToFit];
    self.animatedImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.loadingLabel.center = CGPointMake(
                                           self.animatedImageView.center.x,
                                           CGRectGetMaxY(self.animatedImageView.frame) + CGRectGetMidY(self.loadingLabel.bounds)
                                           );
}

- (void)startAnimating {
    self.hidden = NO;
    [self.animatedImageView startAnimating];
}

- (void)stopAnimating {
    self.hidden = YES;
    [self.animatedImageView stopAnimating];
}
@end
