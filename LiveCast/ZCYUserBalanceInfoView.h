//
//  ZCYUserBalanceInfoView.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYTransparentUserInfoBgView.h"


@interface ZCYUserBalanceInfoView : ZCYTransparentUserInfoBgView

@property (nonatomic, assign) NSUInteger yuwanCount;
@property (nonatomic, assign) CGFloat yuchiCount;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end
