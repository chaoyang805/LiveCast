//
//  ZCYUserBalanceInfoView.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYUserBalanceInfoView.h"

@interface ZCYUserBalanceInfoView ()

@property (nonatomic, strong) UILabel *yuwanLabel;
@property (nonatomic, strong) UILabel *yuchiLabel;
@property (nonatomic, strong) UIImageView *yuchiIcon;
@property (nonatomic, strong) UIImageView *yuwanIcon;
@end

@implementation ZCYUserBalanceInfoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _yuchiIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image_headerView_yuchi"]];
        [_yuchiIcon sizeToFit];
        _yuchiIcon.center = CGPointMake(CGRectGetMidX(_yuchiIcon.bounds) + 6, CGRectGetMidY(self.bounds));
        [self addSubview:_yuchiIcon];
        
        _yuchiLabel = [[UILabel alloc] init];
        _yuchiLabel.text = [NSString stringWithFormat:@"%.1f", 0.0f];
        _yuchiLabel.font = [UIFont systemFontOfSize:10];
        _yuchiLabel.textColor = [UIColor whiteColor];
        [_yuchiLabel sizeToFit];
        [self addSubview:_yuchiLabel];
        
        _yuwanIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image_headerView_yuwan"]];
        [_yuwanIcon sizeToFit];
        [self addSubview:_yuwanIcon];
        
        _yuwanLabel = [[UILabel alloc] init];
        _yuwanLabel.text = [NSString stringWithFormat:@"%d", 0];
        _yuwanLabel.font = [UIFont systemFontOfSize:10];
        _yuwanLabel.textColor = [UIColor whiteColor];
        [_yuwanLabel sizeToFit];
        [self addSubview:_yuwanLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _yuchiIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image_headerView_yuchi"]];
        [_yuchiIcon sizeToFit];
        _yuchiIcon.center = CGPointMake(CGRectGetMidX(_yuchiIcon.bounds) + 6, CGRectGetMidY(self.bounds));
        [self addSubview:_yuchiIcon];
        
        _yuchiLabel = [[UILabel alloc] init];
        _yuchiLabel.text = [NSString stringWithFormat:@"%.1f", 0.0f];
        _yuchiLabel.font = [UIFont systemFontOfSize:10];
        _yuchiLabel.textColor = [UIColor whiteColor];
        [_yuchiLabel sizeToFit];
        [self addSubview:_yuwanLabel];
        
        _yuwanIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Image_headerView_yuwan"]];
        [_yuwanIcon sizeToFit];
        [self addSubview:_yuwanIcon];
        
        _yuwanLabel = [[UILabel alloc] init];
        _yuwanLabel.text = [NSString stringWithFormat:@"%d", 0];
        _yuwanLabel.font = [UIFont systemFontOfSize:10];
        _yuwanLabel.textColor = [UIColor whiteColor];
        [_yuwanLabel sizeToFit];
        [self addSubview:_yuwanLabel];
    }
    return self;
}

- (void)setYuwanCount:(NSUInteger)yuwanCount {
    _yuwanCount = yuwanCount;
    self.yuwanLabel.text = [NSString stringWithFormat:@"%lu", yuwanCount];
    [self.yuwanLabel sizeToFit];
    [self setNeedsLayout];
    
}

- (void)setYuchiCount:(CGFloat)yuchiCount {
    _yuchiCount = yuchiCount;
    self.yuchiLabel.text = [NSString stringWithFormat:@"%.1f", yuchiCount];
    [self.yuchiLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat centerY = CGRectGetMidY(self.bounds);
    CGFloat yuchiIconCenterX = 6 + CGRectGetMidX(self.yuchiIcon.bounds);
    self.yuchiIcon.center = CGPointMake(yuchiIconCenterX, centerY);
    
    CGFloat yuchiLabelCenterX = CGRectGetMaxX(self.yuchiIcon.frame) + 4 + CGRectGetMidX(self.yuchiLabel.bounds);
    self.yuchiLabel.center = CGPointMake(yuchiLabelCenterX, centerY);
    
    CGFloat yuwanIconCenterX = CGRectGetMaxX(self.yuchiLabel.frame) + 4 + CGRectGetMidX(self.yuwanIcon.bounds);
    self.yuwanIcon.center = CGPointMake(yuwanIconCenterX, centerY);
    
    CGFloat yuwanLabelCenterX = CGRectGetMaxX(self.yuwanIcon.frame) + 4 + CGRectGetMidX(self.yuwanLabel.bounds);
    self.yuwanLabel.center = CGPointMake(yuwanLabelCenterX, centerY);
    
    CGFloat maxX = CGRectGetMaxX(self.yuwanLabel.frame) + 6;
    if (CGRectGetWidth(self.bounds) < maxX) {
        
        CGFloat x = CGRectGetMinX(self.frame);
        CGFloat y = CGRectGetMinY(self.frame);
        CGFloat width = maxX;
        CGFloat height = CGRectGetHeight(self.bounds);
        self.frame = CGRectMake(x, y, width, height);
    }
    
}

@end
