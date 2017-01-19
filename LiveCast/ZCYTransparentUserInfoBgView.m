//
//  ZCYTransparentUserInfoBgView.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYTransparentUserInfoBgView.h"

@implementation ZCYTransparentUserInfoBgView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1f];
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
        
    }
    return self;
}


@end
