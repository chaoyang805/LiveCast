//
//  ZCYRecommendTopHeader.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//
#import "ZCYBannerView.h"
extern NSString * const ZCYRecommendTopHeaderIdentifier;
extern NSString * const ZCYRecommendTopHeaderNibName;

typedef NS_ENUM(NSUInteger, ZCYTopHeaderButtonType) {
    ZCYTopHeaderRankingListButtonType,
    ZCYTopHeaderMessageButtonType,
    ZCYTopHeaderAllLiveButtonType
};
@class ZCYRecommendTopHeader;
@protocol ZCYRecommendTopHeaderDelegate <NSObject>

- (void)topHeader:(ZCYRecommendTopHeader *)topHeader buttonTappedWithButtonType:(ZCYTopHeaderButtonType)buttonType;

@end

@interface ZCYRecommendTopHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet ZCYBannerView *bannerView;
@property (weak, nonatomic) id<ZCYRecommendTopHeaderDelegate> delegate;

@end
