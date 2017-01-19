//
//  ZCYUserLevelInfoView.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//
#import "ZCYTransparentUserInfoBgView.h"

@interface ZCYUserLevelInfoView : ZCYTransparentUserInfoBgView

@property (nonatomic, assign) CGFloat levelupProgress;
@property (nonatomic, assign) NSUInteger currentLevel;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
@end
