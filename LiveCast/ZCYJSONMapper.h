//
//  ZCYJSONMapper.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYJSONKeyMappingPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZCYJSONMappable <NSObject>

/**
 把 JSON 里的 key 映射成对象的 keyPath
 @return 返回 json 键对应的对象keyPath
 */
- (NSDictionary<NSString *, NSString *> *)customKeyPathsForJSONKeys;

- (NSDictionary<NSString *, Class> *)mappableClassesForKeyPaths;

@end

@interface ZCYNestedClassPair : NSObject

@property (readonly, nonatomic, copy) NSString *key;
@property (readonly, nonatomic, strong) Class clazz;

- (instancetype)initWithClass:(Class)aClass forKey:(NSString *)key;

@end

@interface ZCYJSONMapper<__covariant ObjectType> : NSObject

@property (nonatomic, strong) id<ZCYJSONKeyMappingPolicy> mappingPolicy;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

+ (instancetype)mapper;

- (ObjectType)objectFromJSONObject:(id)JSONObject forClass:(Class)clazz;
- (__kindof NSArray<ObjectType> *)objectsFromJSONObject:(id)JSONObject forClass:(Class)aClass;
- (NSDictionary *)objectInDictionaryFromJSONDictionary:(NSDictionary *)JSONDictionary
                                     withNestedClasses:(NSArray<ZCYNestedClassPair *> *)classes;

@end
NS_ASSUME_NONNULL_END
