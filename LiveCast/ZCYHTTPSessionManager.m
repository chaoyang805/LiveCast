//
//  ZCYHTTPSessionManager.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/7.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYHTTPSessionManager.h"

@implementation ZCYHTTPSessionManager

+ (instancetype)manager {
    return [[[self class] alloc] initWithBaseURL:nil];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static ZCYHTTPSessionManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [ZCYHTTPSessionManager manager];
    });
    return manager;
}

- (instancetype)init {
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url sessionConfiguration:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL
           sessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self = [super initWithSessionConfiguration:configuration];
    if (!self) {
        return nil;
    }
    
    if ([[baseURL path] length] > 0 && ![baseURL.absoluteString hasSuffix:@"/"]) {
        baseURL = [baseURL URLByAppendingPathComponent:@""];
    }
    self.baseURL = baseURL;
    
    self.requestSerializer = [ZCYHTTPRequestSerializer serializer];
    self.responseSerializer = [ZCYJSONResponseSerializer serializer];
    
    return self;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *, id))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"GET"
                                                        URLString:URLString
                                                       parameters:parameters
                                                          success:success failure:failure];
    
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void(^)(NSURLSessionDataTask *))success
                       failure:(void(^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"HEAD"
                                                        URLString:URLString
                                                       parameters:parameters
                                                          success:^(NSURLSessionDataTask *dataTask, __unused id responseObject) {
                                                              if (success) {
                                                                  success(dataTask);
                                                              }
                                                          } failure:failure];
    
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *, id))success
                       failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"POST"
                                                        URLString:URLString
                                                       parameters:parameters
                                                          success:success
                                                          failure:failure];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *, id))success
                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"PUT"
                                                        URLString:URLString
                                                       parameters:parameters
                                                          success:success
                                                          failure:failure];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *, id))success
                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"DELETE"
                                                        URLString:URLString
                                                       parameters:parameters
                                                          success:success
                                                          failure:failure];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(NSURLSessionDataTask *, id))success
                        failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:@"PATCH"
                                                        URLString:URLString
                                                       parameters:parameters
                                                          success:success
                                                          failure:failure];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSError *serializationError = nil;
    NSURLRequest *request = [self.requestSerializer requestWithMethod:method
                                                            URLString:[NSURL URLWithString:URLString relativeToURL:self.baseURL].absoluteString
                                                           parameters:parameters
                                                                error:&serializationError];
    
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        
        return nil;
    }
    __block NSURLSessionDataTask *dataTask = [self dataTaskWithRequest:request
            completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (error) {
                    if (failure) {
                        failure(dataTask, error);
                    }
                } else {
                    if (success) {
                        success(dataTask, responseObject);
                    }
                }
    }];
    return dataTask;
}

@end
