//
//  DYLiveItemInfo.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYLiveItemInfo.h"
#import "DYLiveRoom.h"

@implementation DYLiveItemInfo

- (NSDictionary<NSString *, Class> *)mappableClassesForKeyPaths {
    return @{@"room" : [DYLiveRoom class]};
}

- (NSDictionary<NSString *,NSString *> *)customKeyPathsForJSONKeys {
    return @{@"id" : @"ID"};
}

@end
