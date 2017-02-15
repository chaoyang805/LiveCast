//
//  ZCYObjectResponseSerializer.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYObjectResponseSerializer.h"

@interface NSString (URLStringByRemovingQuery)

- (NSString *)zcy_URLStringByRemovingQuery;

@end

@implementation NSString (URLStringByRemovingQuery)

- (NSString *)zcy_URLStringByRemovingQuery {
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return self;
    }
    return [self substringToIndex:range.location];
}

@end

@interface ZCYObjectResponseSerializer ()
@property (readwrite, nonatomic, strong) NSMutableDictionary<NSString *, Class> *mutableClassesKeyedByURLs;
@property (readwrite, nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<ZCYNestedClassPair *> *> *mutableNestedClassesKeyedByURLs;
@end

@implementation ZCYObjectResponseSerializer

+ (instancetype)serializer {
    return [ZCYObjectResponseSerializer serializerWithJSONReadingOptions:(NSJSONReadingOptions)0];
}

+ (instancetype)serializerWithJSONReadingOptions:(NSJSONReadingOptions)options {
    ZCYObjectResponseSerializer *serializer = [[self alloc] init];
    serializer.readingOptions = options;
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.mapper = [ZCYJSONMapper mapper];
    self.mutableClassesKeyedByURLs = [NSMutableDictionary dictionary];
    self.mutableNestedClassesKeyedByURLs = [NSMutableDictionary dictionary];
    return self;
}

- (void)registerClass:(Class)aClass forURL:(NSString *)URLString {
    [self.mutableClassesKeyedByURLs setObject:aClass forKey:[URLString zcy_URLStringByRemovingQuery]];
}

- (void)removeClassWithURL:(NSString *)URLString {
    [self.mutableClassesKeyedByURLs removeObjectForKey:[URLString zcy_URLStringByRemovingQuery]];
}

- (void)clearAllClasses {
    [self.mutableClassesKeyedByURLs removeAllObjects];
}

- (void)registerNestedClass:(ZCYNestedClassPair *)classPair forURLString:(NSString *)URLString {
    
    NSString *absoluteURL = [URLString zcy_URLStringByRemovingQuery];
    NSMutableArray *nestedClasses = self.mutableNestedClassesKeyedByURLs[absoluteURL];
    if (!nestedClasses) {
        nestedClasses = [NSMutableArray array];
        self.mutableNestedClassesKeyedByURLs[absoluteURL] = nestedClasses;
    }
    [nestedClasses addObject:classPair];
}

- (void)removeNestedClass:(ZCYNestedClassPair *)classPair forURLString:(NSString *) URLString {
    NSString *absoluteURL = [URLString zcy_URLStringByRemovingQuery];
    [self.mutableNestedClassesKeyedByURLs[absoluteURL] removeObject:classPair];
}

- (void)clearAllNestedClassesForURLString:(NSString *)URLString {
    NSString *absoluteURL = [URLString zcy_URLStringByRemovingQuery];
    [self.mutableNestedClassesKeyedByURLs removeObjectForKey:absoluteURL];
}

- (NSArray<ZCYNestedClassPair *>*)nestedClassPairsForURLString:(NSString *)URLString {
    NSString *absoluteURL = [URLString zcy_URLStringByRemovingQuery];
    return self.mutableNestedClassesKeyedByURLs[absoluteURL];
}

#pragma mark - ZCYURLResponseSerialization
- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    id responseObject = [super responseObjectForResponse:response data:data error:error];
    
    NSString *absoluteURL = [response.URL.absoluteString zcy_URLStringByRemovingQuery];
    Class clazz = self.mutableClassesKeyedByURLs[absoluteURL];
    if (clazz) {
        id result = [self.mapper objectFromJSONObject:responseObject forClass:clazz];;
        return result;
    } else {
        
        NSArray *nestedClassPairs = [self nestedClassPairsForURLString:absoluteURL];
        id result = [self.mapper objectInDictionaryFromJSONDictionary:responseObject
                                                    withNestedClasses:nestedClassPairs];
        return result;
    }
}

@end
