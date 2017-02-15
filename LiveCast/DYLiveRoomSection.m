//
//  DYLiveRoomSection.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYLiveRoomSection.h"

@implementation DYLiveRoomSection


- (NSDictionary<NSString *,NSString *> *)customKeyPathsForJSONKeys {
    return @{
             @"icon_url" : @"iconURL",
             @"small_icon_url" : @"smallIconURL"
             };
}

- (NSDictionary<NSString *,Class> *)mappableClassesForKeyPaths {
    return @{ @"roomList" :  [DYLiveRoom class] };
}
@end
