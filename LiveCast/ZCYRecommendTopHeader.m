//
//  ZCYRecommendTopHeader.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYRecommendTopHeader.h"
NSString * const ZCYRecommendTopHeaderIdentifier = @"ZCYRecommendTopHeader";
NSString * const ZCYRecommendTopHeaderNibName = @"ZCYRecommendTopHeader";
@implementation ZCYRecommendTopHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (IBAction)allLiveButtonTapped:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate topHeader:self buttonTappedWithButtonType:ZCYTopHeaderAllLiveButtonType];
    }
}

- (IBAction)rankingListButtonTapped:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate topHeader:self buttonTappedWithButtonType:ZCYTopHeaderRankingListButtonType];
    }
}

- (IBAction)messageButtonTapped:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate topHeader:self buttonTappedWithButtonType:ZCYTopHeaderMessageButtonType];
    }
}

@end
