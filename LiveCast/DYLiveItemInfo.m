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

- (Class)mappableClassInArrayForJSONKey:(NSString *)key {
    
    return nil;
}

- (Class)mappableClassForJSONKey:(NSString *)key {
    if ([key isEqualToString:@"room"]) {
        return [DYLiveRoom class];
    }
    return nil;
}

- (NSString *)keyPathForJSONKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        return NSStringFromSelector(@selector(ID));
    }
    if ([key isEqualToString:@"title"]) {
        return NSStringFromSelector(@selector(title));
    }
    if ([key isEqualToString:@"pic_url"]) {
        return NSStringFromSelector(@selector(picURL));
    }
    if ([key isEqualToString:@"tv_pic_url"]) {
        return NSStringFromSelector(@selector(tvPicURL));
    }
    if ([key isEqualToString:@"room"]) {
        return NSStringFromSelector(@selector(room));
    }
    return nil;
}

- (BOOL)shouldParseToObjectForJSONKey:(NSString *)key {
    return YES;
}
@end
