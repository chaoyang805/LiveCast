//
//  ZCYJSONKeyMappingPolicy.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/10.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZCYJSONKeyMappingPolicy <NSObject>

/**
 不需要进行转换的keyPath
 */
@property (readwrite, nonatomic, copy) NSSet<NSString *> *ignoredKeyPaths;

/**
 将对象的 keyPath 转换成 json 的 key

 @return 返回对应的 json key
 */
- (NSString *)serializedKeyFromKeyPath:(NSString *)keyPath;


/**
 将 json 的key 转换成keyPath

 @param JSONKey json key
 @return keyPath
 */
- (NSString *)deserializedKeyPathFromKey:(NSString *)JSONKey;

@end

@interface ZCYJSONKeyMappingLowerCaseWithUnderScores : NSObject <ZCYJSONKeyMappingPolicy>

@property (readwrite, nonatomic, copy) NSSet<NSString *> *ignoredKeyPaths;

@end
