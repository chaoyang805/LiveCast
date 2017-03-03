//
//  DYLiveItemInfo.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

@class DYLiveRoom;

@interface DYLiveItemInfo : NSObject <ZCYJSONMappable>

@property (readwrite, nonatomic, assign) NSUInteger ID;
@property (readwrite, nonatomic, copy) NSString *title;
@property (readwrite, nonatomic, copy) NSString *picUrl;
@property (readwrite, nonatomic, copy) NSString *tvPicUrl;

@property (readwrite, nonatomic, strong) DYLiveRoom *room;

@end
