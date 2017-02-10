//
//  ZCYJSONMapper.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYJSONKeyMappingPolicy.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JSONMappable <NSObject>


/**
 把 JSON 里的 key 映射成对象的 keyPath
 @return 返回 json 键对应的对象keyPath
 */
- (NSDictionary<NSString *, NSString *> *)customKeyPathsForJSONKeys;

- (NSDictionary<NSString *, Class> *)mappableClassesForKeyPaths;
@end

@interface ZCYJSONMapper<__covariant ObjectType> : NSObject

@property (nonatomic, strong) id<ZCYJSONKeyMappingPolicy> mappingPolicy;

- (ObjectType)objectFromJSONObject:(id)JSONObject forClass:(Class)clazz;

@end
NS_ASSUME_NONNULL_END
