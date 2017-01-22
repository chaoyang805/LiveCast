//
//  ZCYMineViewModel.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYMineViewModel.h"
#import "ZCYSettingItem.h"

@interface ZCYMineViewModel ()

@property (nonatomic, copy) NSArray<NSArray<ZCYSettingItem *> *> *sectionInfo;

@end

@implementation ZCYMineViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadSectionInfo];
    }
    return self;
}

- (void)loadSectionInfo {
    ZCYSettingItem *item1 = [[ZCYSettingItem alloc] initWithTitle:@"主播招募" type:ZCYSettingItemTypeRecruitment];
    ZCYSettingItem *item2 = [[ZCYSettingItem alloc] initWithTitle:@"排行榜" type:ZCYSettingItemTypeRank];
    ZCYSettingItem *item3 = [[ZCYSettingItem alloc] initWithTitle:@"我的视频" type:ZCYSettingItemTypeMyVideo];
    ZCYSettingItem *item4 = [[ZCYSettingItem alloc] initWithTitle:@"视频收藏" type:ZCYSettingItemTypeVideoCollection];
    ZCYSettingItem *item5 = [[ZCYSettingItem alloc] initWithTitle:@"我的账户" type:ZCYSettingItemTypeMyAccount];
    ZCYSettingItem *item6 = [[ZCYSettingItem alloc] initWithTitle:@"游戏中心" type:ZCYSettingItemTypeGameCenter];
    item6.extraInfo = @"玩游戏领鱼丸鱼丸鱼丸鱼丸";
    ZCYSettingItem *item7 = [[ZCYSettingItem alloc] initWithTitle:@"开播提醒" type:ZCYSettingItemTypeRemind];
    
    self.sectionInfo = @[
                         @[item1, item2],
                         @[item3, item4],
                         @[item5, item6],
                         @[item7]
                         ];
}

- (NSUInteger)sectionCount {
    if (self.sectionInfo) {
        return self.sectionInfo.count;
    } else {
        return 0;
    }
}

- (NSUInteger)itemsCountInSection:(NSUInteger)section {

    return self.sectionInfo[section].count;
}

- (ZCYSettingItem *)modelAtIndexPath:(NSIndexPath *)indexPath {
    return self.sectionInfo[indexPath.section][indexPath.row];
}

- (NSString *)settingTitleAtIndexPath:(NSIndexPath *)indexPath {
    return [self modelAtIndexPath:indexPath].settingTitle;
}

- (UIImage *)settingIconAtIndexPath:(NSIndexPath *)indexPath {
    return [self modelAtIndexPath:indexPath].settingIcon;
}

- (nullable NSString *)extraInfoAtIndexPath:(NSIndexPath *)indexPath {
    return [self modelAtIndexPath:indexPath].extraInfo;
}

- (BOOL)hasUnreadItemAtIndex:(NSIndexPath *)indexPath {
    NSString *extraInfo = [self extraInfoAtIndexPath:indexPath];
    return extraInfo != nil && ![extraInfo isEqualToString:@""];
}


@end
