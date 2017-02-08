//
//  ZCYHTTPSessionManager.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/7.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYSessionManager.h"

@interface ZCYHTTPSessionManager : ZCYSessionManager

@property (readwrite, nonatomic, strong) ZCYHTTPRequestSerializer *requestSerializer;

@property (readwrite, nonatomic, strong) NSURL *baseURL;

+ (instancetype)manager;

- (instancetype)init;

- (instancetype)initWithBaseURL:(NSURL *)url;

- (instancetype)initWithBaseURL:(NSURL *)baseURL
           sessionConfiguration:(NSURLSessionConfiguration *)configuration;

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *, id))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end
