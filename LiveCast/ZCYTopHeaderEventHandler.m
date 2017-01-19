//
//  ZCYTopHeaderEventHandler.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYTopHeaderEventHandler.h"

@implementation ZCYTopHeaderEventHandler

#pragma mark <ZCYRecommendTopHeaderDelegate>
- (void)topHeader:(ZCYRecommendTopHeader *)topHeader buttonTappedWithButtonType:(ZCYTopHeaderButtonType)buttonType {
    NSLog(@"%lu", buttonType);
    switch (buttonType) {
        case ZCYTopHeaderRankingListButtonType:
            
            break;
        case ZCYTopHeaderMessageButtonType:
            
            break;
        case ZCYTopHeaderAllLiveButtonType:
            
            break;
    }
}

- (void)bannerView:(ZCYBannerView *)bannerView tappedAtIndex:(NSUInteger)index withBannerItem:(id<ZCYBannerItemType>)item {
    NSLog(@"banner tapped at %lu item:%@", index,item);
}

@end
