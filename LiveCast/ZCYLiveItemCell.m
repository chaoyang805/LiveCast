//
//  ZCYLiveItemCell.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/11.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYLiveItemCell.h"
#import "UIImageView+RoundedCorner.h"
#import "UIView+RoundedCorner.h"
#import "UIColor+HexStringColor.h"

NSString * const ZCYLiveItemCellIdentifier = @"ZCYLiveItemCell";
NSString * const ZCYLiveItemCellNibName = @"ZCYLiveItemCell";
@implementation ZCYLiveItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.liveCoverImage zcy_addRoundedCorner:4];
    
    self.liveCountBgView.backgroundColor = [UIColor clearColor];
    UIImage *gradientImage = [UIImage imageNamed:@"topRightMask1"];
    UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientImage];
    [self.liveCountBgView insertSubview:gradientView atIndex:0];
    
}

@end
