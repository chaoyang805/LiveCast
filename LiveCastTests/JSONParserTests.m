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
@property (nonatomic, strong) NSData *JSONData;
@end

@implementation JSONParserTests

- (void)setUp {
    
    self.JSONData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"live" withExtension:@"json"]];
    self.JSONString = [[NSString alloc] initWithData:self.JSONData encoding:NSUTF8StringEncoding];
    self.JSONObject = [NSJSONSerialization JSONObjectWithData:self.JSONData options:NSJSONReadingAllowFragments error:nil];
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

- (void)testJSONParserData {
    XCTAssertNotNil(self.JSONData);
    ZCYJSONMapper *mapper = [ZCYJSONMapper mapper];
    id JSONObject = [mapper objectFromJSONObject:self.JSONData forClass:NSClassFromString(@"DYLiveItemInfo")];
    
    XCTAssertNotNil(JSONObject);
    
}

- (void)testJSONParserString {
    XCTAssertNotNil(self.JSONString);
    ZCYJSONMapper *mapper = [ZCYJSONMapper mapper];
    id JSONObject = [mapper objectFromJSONObject:self.JSONString forClass:NSClassFromString(@"DYLiveItemInfo")];
    
    XCTAssertNotNil(JSONObject);
    
}

- (void)testParserPerformance {
    [self measureBlock:^{
        ZCYJSONMapper *mapper = [[ZCYJSONMapper alloc] init];
        mapper.mappingPolicy = [[ZCYJSONKeyMappingLowerCaseWithUnderScores alloc] init];
        __unused id parsedObject = [mapper objectFromJSONObject:self.JSONArray forClass:NSClassFromString(@"DYLiveItemInfo")];
    }];
}

@end
