//
//  ZCYUserLevelInfoView.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYUserLevelInfoView.h"
#import "UIColor+HexStringColor.h"

static const CGFloat kTotalProgressWidth = 36;

@interface ZCYUserLevelInfoView ()

@property (nonatomic, strong) UILabel *levelLabel;
@end

@implementation ZCYUserLevelInfoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _levelLabel = [[UILabel alloc] init];
        _levelLabel.text = @"LV1";
        _levelLabel.font = [UIFont systemFontOfSize:10];
        _levelLabel.textColor = [UIColor whiteColor];
        [_levelLabel sizeToFit];
        _levelLabel.center = CGPointMake(6 + CGRectGetMidX(_levelLabel.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_levelLabel];
        
        _levelupProgress = 0.03;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
        
        _levelLabel = [[UILabel alloc] init];
        _levelLabel.text = @"LV1";
        _levelLabel.font = [UIFont systemFontOfSize:10];
        _levelLabel.textColor = [UIColor whiteColor];
        [_levelLabel sizeToFit];
        _levelLabel.center = CGPointMake(6 + CGRectGetMidX(_levelLabel.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_levelLabel];
        
        _levelupProgress = 0.5;
    }
    return self;
}

- (void)setLevelupProgress:(CGFloat)levelupProgress {
    _levelupProgress = levelupProgress;
    [self setNeedsDisplay];
}

- (void)setCurrentLevel:(NSUInteger)currentLevel {
    _currentLevel = currentLevel;
    self.levelLabel.text = [NSString stringWithFormat:@"LV%lu", currentLevel];
    [self.levelLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.levelLabel.center = CGPointMake(6 + CGRectGetWidth(_levelLabel.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2);
    
    CGPoint startPoint = CGPointMake(CGRectGetMaxX(self.levelLabel.frame) + 5, CGRectGetMidY(self.bounds));
    CGPoint progressPoint = CGPointMake(startPoint.x + kTotalProgressWidth * self.levelupProgress, startPoint.y);
    
    [[UIColor colorWithHexString:@"0xE57630"] setStroke];
    CGContextMoveToPoint(context, progressPoint.x, progressPoint.y);
    CGContextAddLineToPoint(context, startPoint.x + kTotalProgressWidth, startPoint.y);
    CGContextStrokePath(context);
    
    [[UIColor whiteColor] setStroke];
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, progressPoint.x, progressPoint.y);
    CGContextStrokePath(context);
    
}


@end
