//
//  ZCYJSONKeyMappingPolicy.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/10.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYJSONKeyMappingPolicy.h"


@interface NSString (JSONKeyMapping)

- (NSString *)stringWithFirstLetterLowercased;

@end

@implementation NSString (JSONKeyMapping)

- (NSString *)stringWithFirstLetterLowercased {
    
    NSString *firstLetter = [self substringToIndex:1];
    NSString *remainingString = [self substringWithRange:NSMakeRange(1, self.length - 1)];
    return [NSString stringWithFormat:@"%@%@", [firstLetter lowercaseString], remainingString];
}

- (NSString *)stringWithFirstLetterUppercased {
    NSString *firstLetter = [self substringToIndex:1];
    NSString *remainingString = [self substringWithRange:NSMakeRange(1, self.length - 1)];
    return [NSString stringWithFormat:@"%@%@", [firstLetter uppercaseString], remainingString];
}

@end

@implementation ZCYJSONKeyMappingLowerCaseWithUnderScores

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.ignoredKeyPaths = [NSSet set];
    return self;
}

- (NSString *)serializedKeyFromKeyPath:(NSString *)keyPath {
    return @"";
}

- (NSString *)deserializedKeyPathFromKey:(NSString *)JSONKey {
    // 例如 sample or _sample
    if (![JSONKey containsString:@"_"] ||
        [JSONKey rangeOfString:@"_"].location == 0 ||
        [self.ignoredKeyPaths containsObject:JSONKey]) {
        return JSONKey;
    }
    
    NSArray<NSString *> *components = [JSONKey componentsSeparatedByString:@"_"];
    NSMutableString *mutableKeyPath = [NSMutableString string];
    
    for (NSInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        if (i == 0) {
            [mutableKeyPath appendString:[component stringWithFirstLetterLowercased]];
        } else {
            [mutableKeyPath appendString:[component stringWithFirstLetterUppercased]];
        }
    }
    return [NSString stringWithString:mutableKeyPath];
}
@end
