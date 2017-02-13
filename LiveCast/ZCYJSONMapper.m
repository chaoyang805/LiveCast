//
//  ZCYJSONMapper.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYJSONMapper.h"
#define ID(obj) ((id)obj)

@implementation ZCYJSONMapper

+ (instancetype)mapper {
    return [[self alloc] init];
}

- (instancetype)init {
    return [self initWithMappingPolicy:[[ZCYJSONKeyMappingLowerCaseWithUnderScores alloc] init]];
}

- (instancetype)initWithMappingPolicy:(id<ZCYJSONKeyMappingPolicy>)mappingPolicy {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.mappingPolicy = mappingPolicy;
    self.readingOptions = NSJSONReadingAllowFragments;
    self.stringEncoding = NSUTF8StringEncoding;
    return self;
}

- (id)objectFromJSONObject:(id)JSONObject forClass:(Class)clazz {
    
    NSParameterAssert(JSONObject);
    NSParameterAssert(clazz);
    
    // if object is a NSString, so convert it to a NSArray or a NSDictionary object.
    if ([JSONObject isKindOfClass:[NSString class]]) {
        return [self objectFromJSONObject:[self JSONObjectFromJSONString:(NSString *)JSONObject]
                                 forClass:clazz];
    }
    
    if ([JSONObject isKindOfClass:[NSData class]]) {
        return [self objectFromJSONObject:[self JSONObjectFromJSONData:(NSData *)JSONObject error:nil]
                                 forClass:clazz];
    }
    
    id<ZCYJSONMappable> object = [[clazz alloc] init];
    
    if (![object conformsToProtocol:@protocol(ZCYJSONMappable)]) {
        return nil;
    }
    
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *keyPathsForJSONKeys = [object customKeyPathsForJSONKeys];
        NSDictionary *classesForKeyPaths = [object mappableClassesForKeyPaths];
        
        for (NSString *key in [((NSDictionary<NSString *, id> *)JSONObject) allKeys]) {
    
            id value = [JSONObject valueForKey:key];
            NSString *keyPath = keyPathsForJSONKeys[key];
            
            if (!keyPath) {
                keyPath = [self.mappingPolicy deserializedKeyPathFromKey:key];
            }
            
            if (!keyPath) {
                NSLog(@"keyPath for key %@ not found on class %@", key, NSStringFromClass(clazz));
                continue;
            }
            
            if (![object respondsToSelector:NSSelectorFromString(keyPath)]) {
                if ([object respondsToSelector:NSSelectorFromString(key)]) {
                    NSLog(@"keyPath %@ not found on class %@ use origin key %@", keyPath, NSStringFromClass(clazz), key);
                    keyPath = key;
                } else {
                    NSLog(@"neither keyPath %@ nor key %@ was found on class %@", keyPath, key, clazz);
                    continue;
                }
            }
            
            if ([value isKindOfClass:[NSDictionary class]]) {
            
                Class nestedClass = classesForKeyPaths[keyPath];
                if (!nestedClass ||
                    [nestedClass isSubclassOfClass:[NSDictionary class]] ||
                    [nestedClass isSubclassOfClass:[NSArray class]]) {
                    [ID(object) setValue:value forKey:keyPath];
                } else {
                    [ID(object) setValue:[self objectFromJSONObject:value forClass:nestedClass]
                                                         forKey:keyPath];
                }
                
            } else if ([value isKindOfClass:[NSArray class]]) {
                
                Class nestedClass = classesForKeyPaths[keyPath];
                if (nestedClass) {
                    // 如果是对象数组的话，继续递归地解析
                    [ID(object) setValue:[self objectFromJSONObject:value forClass:nestedClass] forKey:keyPath];
                } else {
                    // 如果是基本类型数组的话，或者不需要解析成对象，直接把这个数组设置到 object 上
                    [ID(object) setValue:value forKey:keyPath];
                }
                
            } else {
                // 既不是字典又不是数组 JSONObject 里除了字典、数组就是可以直接设置的类型了
                [ID(object) setValue:value forKey:keyPath];
            }
        }
        return object;
        
    } else if ([JSONObject isKindOfClass:[NSArray class]]) {
        
        return [self objectsFromJSONObject:JSONObject forClass:clazz];
    } else {
        NSAssert(NO, @"JSONObject either a dictionary or an array");
        return nil;
    }
}

- (NSArray *)objectsFromJSONObject:(id)JSONObject forClass:(Class)aClass {
    
    if (![JSONObject isKindOfClass:[NSArray class]]) {
        NSAssert(NO, @"JSONObject %@ is not a NSArray object, cannot convert to a JSON array.", JSONObject);
        return nil;
    }
    
    NSMutableArray *mutableValues = [NSMutableArray arrayWithCapacity:((NSArray *)JSONObject).count];
    for (id nestObjectInArray in ((NSArray *)JSONObject)) {
        [mutableValues addObject:[self objectFromJSONObject:nestObjectInArray forClass:aClass]];
    }
    return [NSArray arrayWithArray:mutableValues];
}

- (id)JSONObjectFromJSONString:(NSString *)JSONString {
    
    if ([JSONString isEqualToString:@""]) {
        return [NSDictionary dictionary];
    }
    
    NSData *JSONData = [JSONString dataUsingEncoding:self.stringEncoding];
    NSError *serializationError;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData
                                                    options:self.readingOptions
                                                      error:&serializationError];
    
    return JSONObject;
}

- (id)JSONObjectFromJSONData:(NSData *)JSONData error:(NSError **)error {
    if (JSONData == nil || JSONData.length <= 0) {
        return [NSDictionary dictionary];
    }
    id JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData
                                                    options:self.readingOptions
                                                      error:error];
    
    return JSONObject;
}

@end
