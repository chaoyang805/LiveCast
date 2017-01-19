//
//  ZCYLiveItemLargeCell.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/11.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYLiveItemLargeCell.h"
#import "UIImageView+RoundedCorner.h"
#import "UIView+RoundedCorner.h"

NSString * const ZCYLiveItemLargeCellIdentifier = @"ZCYLiveItemLargeCell";
NSString * const ZCYLiveItemLargeCellNibName = @"ZCYLiveItemLargeCell";
@interface ZCYLiveItemLargeCell ()

@property (weak, nonatomic) IBOutlet UIView *liveCountBgView;


@end
@implementation ZCYLiveItemLargeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.liveCoverImage zcy_addRoundedCorner:5];
    [self.liveCountBgView zcy_addRoundedCorner:2.5
                                     fillColor:[UIColor colorWithWhite:0.0f alpha:0.4]
                                   borderWidth:0
                                   borderColor:[UIColor clearColor]];
}

@end
