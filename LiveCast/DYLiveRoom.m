//
//  DYLiveRoom.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYLiveRoom.h"

@implementation DYLiveRoom

- (NSDictionary<NSString *,Class> *)mappableClassesForKeyPaths {
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)customKeyPathsForJSONKeys; {
    return @{@"cur_credit" : @"currentCredit",
             @"url" : @"URL",
             @"game_url" : @"gameURL",
             @"owner_uid" : @"ownerUID",
             @"game_icon_url" : @"gameIconURL"};
}

@end
