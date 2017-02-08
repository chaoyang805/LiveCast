//
//  ZCYURLRequestSerialization.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/6.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZCYURLRequestSerialization <NSObject>


- (nullable NSURLRequest *)requestBySerializingRequest:(NSURLRequest * _Nonnull)request
                               withParameters:(nullable id)parameters
                                        error:(NSError * _Nullable __autoreleasing * _Nullable)error;
@end

@interface ZCYHTTPRequestSerializer : NSObject <ZCYURLRequestSerialization>

/**
 HTTPRequestHeaders by default is:
 - `Accept-Language`:NSLocale+preferredLanguages
 - `User-Agent`: bundle identifiers and OS designations
 */
@property (readonly, nonatomic, strong, null_unspecified) NSDictionary<NSString *, NSString *> *HTTPRequestHeaders;

/**
 GET HEAD DELETE by default
 */
@property (nonatomic, strong, null_unspecified) NSSet<NSString *> *HTTPMethodsEncodingParametersInURI;

/**
 default string encoding is UTF-8
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

@property (nonatomic, assign) BOOL allowsCellularAccess;

@property (nonatomic, assign) BOOL HTTPShouldHandleCookies;

@property (nonatomic, assign) BOOL HTTPShouldUsePipelining;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic, assign) NSURLRequestNetworkServiceType networkServiceType;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

+ (nonnull instancetype)serializer;

#pragma mark - 

- (nullable NSDictionary<NSString *,NSString *> *)HTTPRequestHeaders;

- (void)setValue:(nonnull NSString *)value forHTTPHeaderField:(nonnull NSString *)field;

- (nullable NSString *)valueForHTTPHeaderField:(nonnull NSString *)field;

- (void)setAuthorizationHeaderFieldWithUsername:(nonnull NSString *)username password:(nonnull NSString *)password;

- (void)clearAuthorization;

#pragma mark - 
- (nullable NSMutableURLRequest *)requestWithMethod:(nonnull NSString *)method
                                 URLString:(nonnull NSString *)URLString
                                parameters:(nullable id)parameters
                                     error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end
