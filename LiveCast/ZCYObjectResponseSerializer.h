//
//  ZCYObjectResponseSerializer.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCYNetwork.h"
#import "ZCYJSONSerialization.h"
#pragma mark - ZCYObjectResponseSerializer

@class ZCYJSONMapper;

@interface ZCYObjectResponseSerializer : ZCYJSONResponseSerializer

@property (nonatomic, strong) ZCYJSONMapper *mapper;

- (void)registerClass:(Class)aClass forURL:(NSString *)URLString;
- (void)removeClassWithURL:(NSString *)URLString;
- (void)clearAllClasses;

- (void)registerNestedClass:(ZCYNestedClassPair *)classPair forURLString:(NSString *)URLString;
- (void)removeNestedClass:(ZCYNestedClassPair *)classPair forURLString:(NSString *) URLString;
- (void)clearAllNestedClassesForURLString:(NSString *)URLString;

- (NSArray<ZCYNestedClassPair *>*)nestedClassPairsForURLString:(NSString *)URLString;
@end
