//
//  DYRecommendAPI.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

@interface DYRecommendAPI : NSObject

@property (readwrite, nonatomic, strong) NSURL *baseURL;
@property (readonly, nonatomic, strong) ZCYHTTPSessionManager *sessionManager;
@property (readonly, nonatomic, assign) CGFloat apiVersion;

- (void)setApiVersion:(CGFloat)apiVersion;
- (void)getHeaderSlideData:(void (^)(NSArray<DYLiveItemInfo *> *slideData, NSError *error))completionHandler;
- (void)getHotCategoryWithCompletionHandler:(void (^)(id responseObject, NSError *error))completionHandler;
- (void)getVerticalRoomListWithLimit:(NSUInteger)limit
                          fromOffset:(NSUInteger)offset
                   completionHandler:(void (^)(id responseObject, NSError *error))completionHandler;

- (void)getBigDataRoomWithCompletionHandler:(void (^)(id responseObject, NSError *error))completionHandler;
@end
