//
//  ZCYImageCommon.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define weakify(var) __weak typeof(var) ZCYWeak_##var = var

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ingored \"-Wshadow\"") \
__strong typeof(var) var = ZCYWeak_##var \
_Pragma("clang diagnostic pop")

#define safelyCallBlock(block, ...) if((block)) { block(__VA_ARGS__); }

#define dispatch_main_safe(block) \
if (strcmp(dispatch_queue_get_label(NULL), dispatch_queue_get_label(dispatch_get_main_queue())) != 0) { \
dispatch_async(dispatch_get_main_queue(), block); \
} else { \
block(); \
} \

#define Expectation_Begin(description) XCTestExpectation *expectation = [self expectationWithDescription:description]

#define Expectation_Fulfill [expectation fulfill]

#define ExpectationWait_End(timeout) [self waitForExpectationsWithTimeout:timeout handler:nil]

extern UIImage *ZCYScaledImageForKey(NSString *key, UIImage *image);

static int64_t kAsyncTestTimeout = 20;

extern NSString *const ZCYImageErrorDomain;
