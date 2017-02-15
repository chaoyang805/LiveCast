//
//  DYLiveRoomSection.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

@interface DYLiveRoomSection : NSObject <ZCYJSONMappable>

@property (nonatomic, assign) BOOL pushVerticalScreen;
@property (nonatomic, assign) BOOL pushNearby;

@property (nonatomic, copy) NSArray<DYLiveRoom *> *roomList;
@property (nonatomic, copy) NSString *iconURL;
@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *smallIconURL;
@end
