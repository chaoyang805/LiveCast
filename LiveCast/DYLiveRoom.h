//
//  DYLiveRoom.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCYJSONMapper.h"

@interface DYLiveRoom : NSObject <ZCYJSONMappable>

@property (readwrite, nonatomic, assign) BOOL isVertical;
@property (readwrite, nonatomic, assign) BOOL isPassPlayer;
@property (readwrite, nonatomic, assign) BOOL openFullScreen;
@property (readwrite, nonatomic, assign) BOOL isHighGame;
@property (readwrite, nonatomic, assign) BOOL isWhiteList;

@property (readwrite, nonatomic, assign) NSInteger online;
@property (readwrite, nonatomic, assign) NSInteger fans;
@property (readwrite, nonatomic, assign) NSInteger childId;
@property (readwrite, nonatomic, assign) NSInteger rankType;
@property (readwrite, nonatomic, assign) NSInteger showType;

@property (readwrite, nonatomic, copy) NSString *roomId;
@property (readwrite, nonatomic, copy) NSString *roomSrc;
@property (readwrite, nonatomic, copy) NSString *anchorCity;
@property (readwrite, nonatomic, copy) NSString *verticalSrc;
@property (readwrite, nonatomic, copy) NSString *ownerWeight;
@property (readwrite, nonatomic, copy) NSString *cateId;
@property (readwrite, nonatomic, copy) NSString *roomName;
@property (readwrite, nonatomic, copy) NSString *vodQuality;
@property (readwrite, nonatomic, copy) NSString *showStatus;
@property (readwrite, nonatomic, copy) NSString *subject;
@property (readwrite, nonatomic, copy) NSString *showTime;
@property (readwrite, nonatomic, copy) NSString *ownerUID;
@property (readwrite, nonatomic, copy) NSString *specificCatalog;
@property (readwrite, nonatomic, copy) NSString *specificStatus;
@property (readwrite, nonatomic, copy) NSString *creditIllegal;
@property (readwrite, nonatomic, copy) NSString *currentCredit;
@property (readwrite, nonatomic, copy) NSString *lowCredit;
@property (readwrite, nonatomic, copy) NSString *nickname;
@property (readwrite, nonatomic, copy) NSString *URL;
@property (readwrite, nonatomic, copy) NSString *gameURL;
@property (readwrite, nonatomic, copy) NSString *gameName;
@property (readwrite, nonatomic, copy) NSString *gameIconURL;
@property (readwrite, nonatomic, copy) NSString *showDetails;
@property (readwrite, nonatomic, copy) NSString *columnId;
@property (readwrite, nonatomic, copy) NSString *ownerAvatar;
@property (readwrite, nonatomic, copy) NSString *avatarMid;
@property (readwrite, nonatomic, copy) NSString *avatarSmall;
@property (readwrite, nonatomic, copy) NSString *jumpURL;
@property (readwrite, nonatomic, copy) NSString *iconURL;
@property (readwrite, nonatomic, copy) NSString *pushIos;
@property (readwrite, nonatomic, copy) NSString *recomType;
@property (readwrite, nonatomic, copy) NSString *rpos;


@property (readwrite, nonatomic, copy) NSArray<NSDictionary *> *cdnsWithName;
@property (readwrite, nonatomic, copy) NSArray<NSString *> *strs;
@property (readwrite, nonatomic, copy) NSDictionary<NSString *, NSNumber *> *cateLimit;

@end
