//
//  ZCYURLResponseSerialization.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZCYURLResponseSerialization <NSObject>

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError * __autoreleasing *)error;

@end

@interface ZCYHTTPResponseSerializer : NSObject <ZCYURLResponseSerialization>

@property (nonatomic, assign) NSStringEncoding stringEncoding;

@property (nonatomic, copy) NSIndexSet *acceptableStatusCodes;

@property (nonatomic, copy) NSSet<NSString *> *acceptableContentTypes;

+ (instancetype)serializer;

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error;

@end


#pragma mark - ZCYJSONResponseSerializer
@interface ZCYJSONResponseSerializer : ZCYHTTPResponseSerializer

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

@property (nonatomic, assign) BOOL removesKeysWithNullValues;

+ (instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)options;

@end
