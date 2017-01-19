//
//  ZCYSettingItem.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZCYSettingItemType) {
    ZCYSettingItemTypeFishBar,
    ZCYSettingItemTypeRecruitment,
    ZCYSettingItemTypeRank,
    ZCYSettingItemTypeMyVideo,
    ZCYSettingItemTypeVideoCollection,
    ZCYSettingItemTypeMyAccount,
    ZCYSettingItemTypeGameCenter,
    ZCYSettingItemTypeRemind
    
};

@interface ZCYSettingItem : NSObject

@property (nonatomic, strong) UIImage *settingIcon;
@property (nonatomic, copy) NSString *settingTitle;
@property (nonatomic, assign) ZCYSettingItemType itemType;
@property (nonatomic, copy) NSString *extraInfo;

- (instancetype)initWithTitle:(NSString *)title type:(ZCYSettingItemType)itemType;
@end
