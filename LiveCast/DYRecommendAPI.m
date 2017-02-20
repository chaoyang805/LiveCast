//
//  DYRecommendAPI.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "DYRecommendAPI.h"

@interface DYRecommendAPI ()

@property (readwrite, nonatomic, strong) ZCYHTTPSessionManager *sessionManager;
@property (readwrite, nonatomic, assign) CGFloat apiVersion;
@end

@implementation DYRecommendAPI
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.sessionManager = [ZCYHTTPSessionManager sharedManager];
    self.baseURL = [NSURL URLWithString:@"https://capi.douyucdn.cn"];
    self.sessionManager.baseURL = self.baseURL;
    ZCYObjectResponseSerializer *serializer = [ZCYObjectResponseSerializer serializer];
    
    [serializer registerClass:[DYResult class] forURL:@"https://capi.douyucdn.cn/api/v1/slide/6"];
    
    [serializer registerNestedClass:[[ZCYNestedClassPair alloc] initWithClass:[DYLiveRoom class] forKey:@"data"]
                       forURLString:@"https://capi.douyucdn.cn/api/v1/getVerticalRoom"];
    
    [serializer registerNestedClass:[[ZCYNestedClassPair alloc] initWithClass:[DYLiveRoomSection class] forKey:@"data"]
                       forURLString:@"https://capi.douyucdn.cn/api/v1/getHotCate"];
    
    [serializer registerNestedClass:[[ZCYNestedClassPair alloc] initWithClass:[DYLiveRoom class] forKey:@"data"]
                       forURLString:@"https://capi.douyucdn.cn/api/v1/getbigDataRoom"];
    
    self.sessionManager.responseSerializer = serializer;
    self.apiVersion = 2.421;
    return self;
}

- (void)getHeaderSlideData:(void (^)(NSArray<DYLiveItemInfo *> *slideData, NSError *error))completionHandler {
    
    [self.sessionManager GET:@"/api/v1/slide/6"
                  parameters:@{ @"version" : [NSString stringWithFormat:@"%.3f", self.apiVersion] }
                     success:^(NSURLSessionDataTask *dataTask, DYResult *responseObject) {
                         
                         if (completionHandler) {
                             completionHandler(responseObject.data, nil);
                         }
                     }
                     failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                         if (completionHandler) {
                             completionHandler(nil, error);
                         }
                     }];
}

- (void)getVerticalRoomListWithLimit:(NSUInteger)limit
                          fromOffset:(NSUInteger)offset
                   completionHandler:(void (^)(id responseObject, NSError *error))completionHandler {
    
    NSString *url = @"/api/v1/getVerticalRoom";
    
    [self.sessionManager GET:url
                  parameters:@{
                               @"limit" : @(limit),
                               @"offset" : @(offset),
                               @"client_sys" : @"ios"
                               }
                     success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                         
                         safelyCallBlock(completionHandler, responseObject, nil)
                     }
                     failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                         safelyCallBlock(completionHandler, nil, error)
                     }];
}

- (void)getHotCategoryWithCompletionHandler:(void (^)(id responseObject, NSError *error))completionHandler {
    
    [self.sessionManager GET:@"/api/v1/getHotCate"
                  parameters:@{
                               @"aid" : @"ios",
                               @"client_sys" : @"ios",
                               @"time" : @(148703890),
                               @"auth" : @"392a1b4952f5b313e5337ad606a5f6e8"
                               }
                     success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                         
                         safelyCallBlock(completionHandler, responseObject, nil)
                     }
                     failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                         safelyCallBlock(completionHandler, nil, error)
                     }];
}

- (void)getBigDataRoomWithCompletionHandler:(void (^)(id responseObject, NSError *error))completionHandler {
    
   // https://capi.douyucdn.cn/api/v1/getBigRoomData?client_sys=ios
    [self.sessionManager POST:@"/api/v1/getbigDataRoom"
                   parameters:@{ @"token" : @"18215774_11_647437ee6f101df0_2_91742941" }
                      success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                          safelyCallBlock(completionHandler, responseObject, nil);
                      }
                      failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                          safelyCallBlock(completionHandler, nil, error);
                      }];
}

@end








