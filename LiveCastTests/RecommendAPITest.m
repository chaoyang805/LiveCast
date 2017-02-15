//
//  RecommendAPITest.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/14.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
@interface RecommendAPITest : XCTestCase

@property (nonatomic, strong) DYRecommendAPI *api;

@end

@implementation RecommendAPITest

- (void)setUp {
    self.api = [DYRecommendAPI new];
}

- (void)tearDown {
    
}

- (void)testRecommendGetSlideData {
    
    XCTAssertNotNil(self.api);
    XCTestExpectation *expectation = [self expectationWithDescription:@"getSlideData failed"];
    
    [self.api getHeaderSlideData:^(NSArray<DYLiveItemInfo *> *slideData, NSError *error) {
        XCTAssertNotNil(slideData);
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRecommendGetVerticalData {
    Expectation_Begin(@"VerticalData");
    NSUInteger limit = 4;
    [self.api getVerticalRoomListWithLimit:limit
                                fromOffset:0
                         completionHandler:^(id responseObject, NSError *error) {
                             
                             XCTAssertNotNil(responseObject);
                             Expectation_Fulfill;
                         }];
    ExpectationWait_End(5);
}

- (void)testRecommendGetHotCate {
    Expectation_Begin(@"VerticalData");
    [self.api getHotCategoryWithCompletionHandler:^(id responseObject, NSError *error) {
        
        XCTAssertNotNil(responseObject);
        Expectation_Fulfill;
    }];
    ExpectationWait_End(5);
}

- (void)testRecommendAPIGetBigData {
    Expectation_Begin(@"BigData");

    [self.api getBigDataRoomWithCompletionHandler:^(id responseObject, NSError *error) {
        
        XCTAssertNotNil(responseObject);
        Expectation_Fulfill;
    }];
    ExpectationWait_End(5);
}


@end
