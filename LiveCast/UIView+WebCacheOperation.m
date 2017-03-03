//
//  UIView+WebCacheOperation.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIView+WebCacheOperation.h"
#import <objc/runtime.h>

static char loadOperationKey;
@implementation UIView (WebCacheOperation)

- (NSMutableDictionary<NSString *, id> *)operationDictionary {
    NSMutableDictionary *operationDictionary = objc_getAssociatedObject(self, &loadOperationKey);
    if (operationDictionary) {
        return operationDictionary;
    }
    operationDictionary = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operationDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operationDictionary;
}

- (void)zcy_setImageLoadOperation:(id)operation forKey:(NSString *)key {
    if (key) {
        [self zcy_cancelImageLoadOperationWithKey:key];
        if (operation) {
            [self operationDictionary][key] = operation;
        }
    }
    
}

- (void)zcy_cancelImageLoadOperationWithKey:(NSString *)key {
    NSMutableDictionary<NSString *, id> *operationsDictionary = [self operationDictionary];
    id operations = operationsDictionary[key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id<ZCYImageOperation> operation in operations) {
                [operation cancel];
            }
        } else if ([operations conformsToProtocol:@protocol(ZCYImageOperation)]) {
            [(id<ZCYImageOperation>)operations cancel];
        }
        [operationsDictionary removeObjectForKey:key];
    }
}

- (void)zcy_removeImageLoadOperationWithKey:(NSString *)key {
    if (key) {
        [[self operationDictionary] removeObjectForKey:key];
    }
}

@end
