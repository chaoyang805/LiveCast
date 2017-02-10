//
//  JSONParserTests.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCYJSONMapper.h"
#import "DYLiveItemInfo.h"
#import "DYLiveRoom.h"

@interface JSONParserTests : XCTestCase

@property (nonatomic, copy) NSString *JSONString;
@property (nonatomic, strong) id JSONObject;
@property (nonatomic, strong) id JSONArray;

@end

@implementation JSONParserTests

- (void)setUp {

    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"live" withExtension:@"json"]];
    self.JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSData *dataArray = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"lives" withExtension:@"json"]];
    self.JSONArray = [NSJSONSerialization JSONObjectWithData:dataArray options:NSJSONReadingAllowFragments error:nil];
}

- (void)tearDown {
    
}

- (void)testJSONParser {
    
    XCTAssertNotNil(self.JSONObject, @"JSONObject serialization failed.");
    ZCYJSONMapper<DYLiveItemInfo *> *mapper = [[ZCYJSONMapper alloc] init];
    mapper.mappingPolicy = [[ZCYJSONKeyMappingLowerCaseWithUnderScores alloc] init];
    DYLiveItemInfo *parsedObject = [mapper objectFromJSONObject:self.JSONObject forClass:NSClassFromString(@"DYLiveItemInfo")];
    XCTAssertNotNil(parsedObject.title);
    
}
- (void)testJSONParserArray {
    XCTAssertNotNil(self.JSONArray);
    ZCYJSONMapper<NSArray<DYLiveItemInfo *> *> *mapper = [[ZCYJSONMapper alloc] init];
    mapper.mappingPolicy = [[ZCYJSONKeyMappingLowerCaseWithUnderScores alloc] init];
    
    NSArray *parsedObject = [mapper objectFromJSONObject:self.JSONArray forClass:NSClassFromString(@"DYLiveItemInfo")];
    
    XCTAssertNotNil(parsedObject[0]);
}

- (void)testParserPerformance {
    [self measureBlock:^{
        ZCYJSONMapper *mapper = [[ZCYJSONMapper alloc] init];
        mapper.mappingPolicy = [[ZCYJSONKeyMappingLowerCaseWithUnderScores alloc] init];
        __unused id parsedObject = [mapper objectFromJSONObject:self.JSONArray forClass:NSClassFromString(@"DYLiveItemInfo")];
    }];
}

@end
