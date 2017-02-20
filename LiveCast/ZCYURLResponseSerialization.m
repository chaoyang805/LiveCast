//
//  ZCYURLResponseSerialization.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYURLResponseSerialization.h"
#import "ZCYJSONMapper.h"

NSString * const ZCYURLResponseSerializationErrorDomain = @"me.chaoyang805.error.serialization.response";
NSString * const ZCYNetworkOperationFailingURLResponseErrorKey = @"me.chaoyang805.serialization.response.error.response";
NSString * const ZCYNetworkOperationFailingURLResponseDataErrorKey = @"me.chaoyang805.serialization.response.error.data";

static NSError * ZCYErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

static BOOL ZCYErrorOrUnderlyingErrorHasCodeInDomain(NSError *error, NSInteger code, NSErrorDomain domain) {
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return ZCYErrorOrUnderlyingErrorHasCodeInDomain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    return NO;
}

static id ZCYJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:((NSArray *)JSONObject).count];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:ZCYJSONObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        return readingOptions & NSJSONReadingMutableContainers ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [((NSDictionary *)JSONObject) allKeys]) {
            id value = ((NSDictionary *)JSONObject)[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = ZCYJSONObjectByRemovingKeysWithNullValues(value, readingOptions);
            }
        }
        
        return readingOptions & NSJSONReadingMutableContainers ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    return JSONObject;
}

#pragma mark - ZCYHTTPResponseSerializer

@implementation ZCYHTTPResponseSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    // acceptable statusCode range 200...299
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    
    self.acceptableContentTypes = nil;
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    [self validateResponse:(NSHTTPURLResponse *)response data:data error:error];
    return response;
}

- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    
    BOOL responseValid = YES;
    NSError *validationError = nil;
    // response must be a http response
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        // response content-type couldn't math acceptable content-types
        if (self.acceptableContentTypes && ![self.acceptableContentTypes containsObject:[response MIMEType]] && !([response MIMEType] == nil && [data length] == 0)) {
            
            if (data.length > 0 && response.URL) {
                
                NSMutableDictionary *mutableUserInfo = [@{
                                                          NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Request failed: unacceptable content-type %@", response.MIMEType],
                                                          NSURLErrorFailingURLErrorKey : [response URL],
                                                          ZCYNetworkOperationFailingURLResponseErrorKey : response,
                                                          } mutableCopy];
                if (data) {
                    mutableUserInfo[ZCYNetworkOperationFailingURLResponseDataErrorKey] = data;
                }
                validationError = ZCYErrorWithUnderlyingError([NSError errorWithDomain:ZCYURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:mutableUserInfo], validationError);
            }
            responseValid = NO;
        }
    }
    
    if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:response.statusCode] && [response URL]) {
        NSMutableDictionary *mutableUserInfo = [@{
                                                  NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Request failed %@ %ld", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (long)response.statusCode],
                                                  NSURLErrorFailingURLErrorKey : [response URL],
                                                  ZCYNetworkOperationFailingURLResponseErrorKey : response
                                                  } mutableCopy];
        
        if (data) {
            mutableUserInfo[ZCYNetworkOperationFailingURLResponseDataErrorKey] = data;
        }
        validationError = ZCYErrorWithUnderlyingError([NSError errorWithDomain:ZCYURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:mutableUserInfo], validationError);
        responseValid = NO;
    }
    
    if (error && !responseValid) {
        *error = validationError;
    }
    return responseValid;
}

@end


#pragma mark - ZCYJSONResponseSerializer
@interface ZCYJSONResponseSerializer()

@end

@implementation ZCYJSONResponseSerializer

+ (instancetype)serializer {
    return [ZCYJSONResponseSerializer serializerWithJSONReadingOptions:(NSJSONReadingOptions)0];
}

+ (instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)options {
    ZCYJSONResponseSerializer *serializer = [[self alloc] init];
    serializer.readingOptions = options;
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    return self;
}
#pragma mark - ZCYURLResponseSerialization
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || ZCYErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, ZCYURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    id responseObject = nil;
    NSError *serializationError;
    BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
    
    if (data.length > 0 && !isSpace) {
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
    } else {
        return nil;
    }
    
    if (self.removesKeysWithNullValues && responseObject) {
        responseObject = ZCYJSONObjectByRemovingKeysWithNullValues(responseObject, self.readingOptions);
    }
    
    if (error) {
        *error = ZCYErrorWithUnderlyingError(serializationError, *error);
    }
    
    return responseObject;
}

@end
