//
//  ZCYTopHeaderEventHandler.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYRecommendTopHeader.h"
#import "ZCYBannerView.h"

@interface ZCYTopHeaderEventHandler : NSObject <ZCYRecommendTopHeaderDelegate, ZCYBannerViewDelegate>

- (void)topHeader:(ZCYRecommendTopHeader *)topHeader buttonTappedWithButtonType:(ZCYTopHeaderButtonType)buttonType;
- (void)bannerView:(ZCYBannerView *)bannerView tappedAtIndex:(NSUInteger)index withBannerItem:(id<ZCYBannerItemType>)item;

@end
