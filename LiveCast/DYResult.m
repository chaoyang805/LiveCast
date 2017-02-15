//
//  DYResult.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYResult.h"

@implementation DYResult

- (NSDictionary<NSString *,Class> *)mappableClassesForKeyPaths {
    return @{@"data" : NSClassFromString(@"DYLiveItemInfo")};
}

- (NSDictionary<NSString *,NSString *> *)customKeyPathsForJSONKeys {
    return nil;
}

@end
