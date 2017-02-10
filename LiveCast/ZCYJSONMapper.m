//
//  ZCYJSONMapper.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYJSONMapper.h"

@implementation ZCYJSONMapper

+ (id)objectFromJSONObject:(id)JSONObject forClass:(Class)clazz {
    
    NSParameterAssert(JSONObject);
    NSParameterAssert(clazz);
    
    id<JSONMappable> object = [[clazz alloc] init];
    
    if (![object conformsToProtocol:@protocol(JSONMappable)]) {
        return nil;
    }
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        
        for (NSString *key in [((NSDictionary<NSString *, id> *)JSONObject) allKeys]) {
    
            id value = [JSONObject valueForKey:key];
            NSString *keyPath = [object keyPathForJSONKey:key];
            if (!keyPath) {
                NSLog(@"%@ not found", key);
                continue;
            }
            NSParameterAssert(keyPath);
            if ([value isKindOfClass:[NSDictionary class]]) {
                
                if ([object shouldParseToObjectForJSONKey:key]) {
                    Class nestedClass = [object mappableClassForJSONKey:key];
                    [((id)object) setValue:[ZCYJSONMapper objectFromJSONObject:value forClass:nestedClass]
                                    forKey:keyPath];
                } else {
                    [((id)object) setValue:value forKey:keyPath];
                }
                
            } else if ([value isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *mutableNestedValue = [NSMutableArray arrayWithCapacity:((NSArray *)value).count];
                for (id nestedValue in ((NSArray *)value)) {
                    // 如果有一个 NSArray<Room *> *rooms 则 @"rooms" -> [Room class]
                    // TODO 如果数组中元素是非 mappable 类型， 如 { "strs": [ "1", "2", "4", "3" ] }
                    if (/*shouleParse*/[object shouldParseToObjectForJSONKey:key]) {
                        Class nestedClass = [object mappableClassInArrayForJSONKey:key];
                        [mutableNestedValue addObject:[ZCYJSONMapper objectFromJSONObject:nestedValue forClass:nestedClass]];
                    } else {
                        [mutableNestedValue addObject:nestedValue];
                    }
                }
                
                [((id)object) setValue:[NSArray arrayWithArray:mutableNestedValue]
                                forKey:keyPath];
            } else {
                // 既不是字典又不是数组 JSONObject 里除了字典、数组就是可以直接设置的类型了
                
                [((id)object) setValue:value forKey:keyPath];
            }
            
        }
        
        return object;
        
    } else if ([JSONObject isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *mutableValues = [NSMutableArray arrayWithCapacity:((NSArray *)JSONObject).count];
        
        for (id nestObjectInArray in ((NSArray *)JSONObject)) {
            
            [mutableValues addObject:[ZCYJSONMapper objectFromJSONObject:nestObjectInArray forClass:clazz]];
        }
        
        return [NSArray arrayWithArray:mutableValues];
    } else {
        NSAssert(NO, @"JSONObject either a dictionary or an array");
        return nil;
    }
}

@end
