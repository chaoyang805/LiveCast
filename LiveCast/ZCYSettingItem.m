//
//  ZCYSettingItem.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYSettingItem.h"

@implementation ZCYSettingItem

- (instancetype)initWithTitle:(NSString *)title type:(ZCYSettingItemType)itemType{
    self= [super init];
    if (self) {
        switch (itemType) {
            case ZCYSettingItemTypeRecruitment:
                _settingIcon = [UIImage imageNamed:@"image_my_recruitment"];
                break;
            case ZCYSettingItemTypeFishBar:
                _settingIcon = [UIImage imageNamed:@"image_my_recruitment"];
                break;
            case ZCYSettingItemTypeMyVideo:
                _settingIcon = [UIImage imageNamed:@"my_video_icon"];
                break;
            case ZCYSettingItemTypeRank:
                _settingIcon = [UIImage imageNamed:@"image_my_rank"];
                break;
            case ZCYSettingItemTypeMyAccount:
                _settingIcon = [UIImage imageNamed:@"image_my_account"];
                break;
            case ZCYSettingItemTypeGameCenter:
                _settingIcon = [UIImage imageNamed:@"image_my_recommend"];
                break;
            case ZCYSettingItemTypeRemind:
                _settingIcon = [UIImage imageNamed:@"image_my_remind"];
                break;
            case ZCYSettingItemTypeVideoCollection:
                _settingIcon = [UIImage imageNamed:@"image_video_collection"];
                break;
            
        }
        _settingTitle = [title copy];
    }
    return self;
}

@end
