//
//  ZCYRecommendViewModel.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//
@class DYRecommendAPI;
@class DYLiveItemInfo;
@interface ZCYRecommendViewModel : NSObject <ZCYBannerViewDelegate, ZCYRecommendTopHeaderDelegate>

@property (readwrite, nonatomic, copy) void(^slideUpdateBlock)(NSArray<UIImage *> *images);
@property (readwrite, nonatomic, copy) void (^slideSelectedBlock)(DYLiveItemInfo *liveItem);
@property (readwrite, nonatomic, copy) void (^dataLoadedCallback)(void);
@property (readwrite, nonatomic, copy) void (^topHeaderClickCallback)(ZCYTopHeaderButtonType buttonType);
@property (readwrite, nonatomic, strong) DYRecommendAPI *recommendAPI;
@property (readonly, nonatomic, assign) NSUInteger numberOfSections;

- (instancetype)init;
- (void)fetchRecommendPageData;

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section;
- (void)bindCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)bindTopHeader:(ZCYRecommendTopHeader *)headerView;
- (void)bindSectionHeader:(ZCYLiveItemSectionHeader *)sectionHeader atSection:(NSUInteger)section;
@end
