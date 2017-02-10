//
//  DYLiveItemInfo.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCYJSONMapper.h"

@class DYLiveRoom;

@interface DYLiveItemInfo : NSObject <JSONMappable>

@property (readwrite, nonatomic, assign) NSUInteger ID;
@property (readwrite, nonatomic, copy) NSString *title;
@property (readwrite, nonatomic, copy) NSString *picURL;
@property (readwrite, nonatomic, copy) NSString *tvPicURL;

@property (readwrite, nonatomic, strong) DYLiveRoom *room;

@end
