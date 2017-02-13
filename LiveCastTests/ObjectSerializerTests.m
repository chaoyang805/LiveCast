//
//  ObjectSerializerTests.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCYHTTPSessionManager.h"
#import "DYLiveItemInfo.h"

@interface DYResult : NSObject <ZCYJSONMappable>

@property (nonatomic, assign) NSInteger error;
@property (nonatomic, copy) NSArray *data;

@end

@implementation DYResult

- (NSDictionary<NSString *,Class> *)mappableClassesForKeyPaths {
    return @{@"data" : NSClassFromString(@"DYLiveItemInfo")};
}

- (NSDictionary<NSString *,NSString *> *)customKeyPathsForJSONKeys {
    return nil;
}

@end

@interface ObjectSerializerTests : XCTestCase

@property (nonatomic, strong) ZCYHTTPSessionManager *manager;

@end

@implementation ObjectSerializerTests

- (void)setUp {
    self.manager = [ZCYHTTPSessionManager manager];
    ZCYObjectResponseSerializer *serializer = [ZCYObjectResponseSerializer serializer];
    [serializer registerClass:[DYResult class] forURL:@"http://capi.douyucdn.cn/api/v1/slide/6"];
    self.manager.responseSerializer = serializer;
}

- (void)testObjectSerializer {
    XCTAssertNotNil(self.manager);
    XCTAssertNotNil(self.manager.responseSerializer);
    XCTestExpectation *expectation = [self expectationWithDescription:@"NetworkFailed"];
    [self.manager GET:@"http://capi.douyucdn.cn/api/v1/slide/6"
           parameters:@{@"version" : @"2.421", @"client_sys" : @"ios"}
              success:^(NSURLSessionDataTask *dataTask, id responseObject) {
                  XCTAssertNotNil(responseObject);
                  
                  [expectation fulfill];
              }
              failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
                  
                  [expectation fulfill];
              }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)tearDown {
    
}

@end
