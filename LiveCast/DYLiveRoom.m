//
//  DYLiveRoom.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYLiveRoom.h"

@implementation DYLiveRoom

- (Class)mappableClassForJSONKey:(NSString *)key {
    return nil;
}

- (Class)mappableClassInArrayForJSONKey:(NSString *)key {
    return nil;
}

- (NSString *)keyPathForJSONKey:(NSString *)key {
    if ([key isEqualToString:@"isVertical"]) {
        return NSStringFromSelector(@selector(isVertical));
    }
    if ([key isEqualToString:@"is_pass_player"]) {
        return NSStringFromSelector(@selector(isPassPlayer));
    }
    if ([key isEqualToString:@"open_full_screen"]) {
        return NSStringFromSelector(@selector(openFullScreen));
    }
    if ([key isEqualToString:@"online"]) {
        return NSStringFromSelector(@selector(online));
    }
    if ([key isEqualToString:@"fans"]) {
        return NSStringFromSelector(@selector(fans));
    }
    if ([key isEqualToString:@"room_id"]) {
        return NSStringFromSelector(@selector(roomId));
    }
    if ([key isEqualToString:@"room_src"]) {
        return NSStringFromSelector(@selector(roomSrc));
    }
    if ([key isEqualToString:@"vertical_src"]) {
        return NSStringFromSelector(@selector(verticalSrc));
    }
    if ([key isEqualToString:@"owner_weight"]) {
        return NSStringFromSelector(@selector(ownerWeight));
    }
    if ([key isEqualToString:@"cate_id"]) {
        return NSStringFromSelector(@selector(cateId));
    }
    if ([key isEqualToString:@"room_name"]) {
        return NSStringFromSelector(@selector(roomName));
    }
    if ([key isEqualToString:@"vod_quality"]) {
        return NSStringFromSelector(@selector(vodQuality));
    }
    if ([key isEqualToString:@"show_status"]) {
        return NSStringFromSelector(@selector(showStatus));
    }
    if ([key isEqualToString:@"show_time"]) {
        return NSStringFromSelector(@selector(showTime));
    }
    if ([key isEqualToString:@"owner_uid"]) {
        return NSStringFromSelector(@selector(ownerUID));
    }
    if ([key isEqualToString:@"specific_catalog"]) {
        return NSStringFromSelector(@selector(specificCatalog));
    }
    if ([key isEqualToString:@"specific_status"]) {
        return NSStringFromSelector(@selector(specificStatus));
    }
    if ([key isEqualToString:@"credit_illegal"]) {
        return NSStringFromSelector(@selector(creditIllegal));
    }
    if ([key isEqualToString:@"is_white_list"]) {
        return NSStringFromSelector(@selector(isWhiteList));
    }
    if ([key isEqualToString:@"cur_credit"]) {
        return NSStringFromSelector(@selector(currentCredit));
    }
    if ([key isEqualToString:@"low_credit"]) {
        return NSStringFromSelector(@selector(lowCredit));
    }
    if ([key isEqualToString:@"nickname"]) {
        return NSStringFromSelector(@selector(nickname));
    }
    if ([key isEqualToString:@"url"]) {
        return NSStringFromSelector(@selector(url));
    }
    if ([key isEqualToString:@"game_url"]) {
        return NSStringFromSelector(@selector(gameURL));
    }
    if ([key isEqualToString:@"game_name"]) {
        return NSStringFromSelector(@selector(gameName));
    }
    if ([key isEqualToString:@"show_details"]) {
        return NSStringFromSelector(@selector(showDetails));
    }
    if ([key isEqualToString:@"column_id"]) {
        return NSStringFromSelector(@selector(columnId));
    }
    if ([key isEqualToString:@"cate_limit"]) {
        return NSStringFromSelector(@selector(cateLimit));
    }
    if ([key isEqualToString:@"cdnsWithName"]) {
        return NSStringFromSelector(@selector(cdnsWithName));
    }
    if ([key isEqualToString:@"game_icon_url"]) {
        return NSStringFromSelector(@selector(gameIconURL));
    }
    if ([key isEqualToString:@"owner_avatar"]) {
        return NSStringFromSelector(@selector(ownerAvatar));
    }
    if ([key isEqualToString:@"is_high_game"]) {
        return NSStringFromSelector(@selector(isHighGame));
    }
    if ([key isEqualToString:@"strs"]) {
        return NSStringFromSelector(@selector(strs));
    }
    return nil;
}

- (BOOL)shouldParseToObjectForJSONKey:(NSString *)key {
//    if ([key isEqualToString:@"cdnsWithName"] || [key isEqualToString:@"cate_limit"]) {
//        return NO;
//    }
//    
    return !([key isEqualToString:@"cdnsWithName"] || [key isEqualToString:@"cate_limit"] || [key isEqualToString:@"strs"]);
}

@end
