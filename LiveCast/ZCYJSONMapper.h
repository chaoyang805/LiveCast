//
//  ZCYJSONMapper.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONMappable <NSObject>


/**
 把 JSON 里的 key 映射成对象的 keyPath

 @param key json 键
 @return 返回 json 键对应的对象keyPath
 */
- (NSString *)keyPathForJSONKey:(NSString *)key;


/**
 根据对象属性的 keyPath 返回对象中的嵌套对象的 Class 信息 如 DYLiveItemInfo 中的 room 属性 的类型信息就为 [DYLiveRoom class]
 
 @param key json key
 @return 返回这个key 对应的对象的类型信息 返回的 Class 必须是符合 JSONMappable 协议的类
 */
- (Class)mappableClassForJSONKey:(NSString *)key;


/**
 数组的键所对应的数组元素类型 如 {"students" : [{"name":"小明", "age" : 10 }, {"name" : "小华", "age" : 20 }] } 里 students -> Student 类

 @param key 数组的键
 @return 数组内部元素的类型
 */
- (Class)mappableClassInArrayForJSONKey:(NSString *)key;

- (BOOL)shouldParseToObjectForJSONKey:(NSString *)key;

@end

@interface ZCYJSONMapper : NSObject

+ (id)objectFromJSONObject:(id)JSONObject forClass:(Class)clazz;

@end
