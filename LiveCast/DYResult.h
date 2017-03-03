//
//  DYResult.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

@class DYLiveItemInfo;

@interface DYResult : NSObject <ZCYJSONMappable>

@property (nonatomic, assign) NSInteger error;
@property (nonatomic, copy) NSArray<DYLiveItemInfo *> *data;

@end
