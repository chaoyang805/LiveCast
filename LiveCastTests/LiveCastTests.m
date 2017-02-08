//
//  LiveCastTests.m
//  LiveCastTests
//
//  Created by chaoyang805 on 2017/2/8.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCYHTTPSessionManager.h"

@interface LiveCastTests : XCTestCase
@property (nonatomic, strong) NSURLRequest *request;
@end

@implementation LiveCastTests

- (void)setUp {
    [super setUp];
    ZCYHTTPRequestSerializer *serializer = [ZCYHTTPRequestSerializer serializer];
    
    NSError *serializationError;
   self.request = [serializer requestWithMethod:@"GET" URLString:@"https://www.baidu.com" parameters:nil error:&serializationError];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRequestSerialization {
    ZCYHTTPRequestSerializer *serializer = [ZCYHTTPRequestSerializer serializer];
    XCTAssertNotNil(serializer, @"serializer init failed");
    NSError *serializationError;
    NSURLRequest *request = [serializer requestWithMethod:@"GET" URLString:@"https://www.baidu.com" parameters:nil error:&serializationError];
    
    XCTAssertNotNil(request, @"request generate failed");
    
    XCTAssertTrue([request.HTTPMethod isEqualToString:@"GET"]);
}

- (void)testURLSessionManager {
    ZCYSessionManager *manager = [[ZCYSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.session);
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:self.request completionHandler:nil];
    XCTAssertNotNil(dataTask);

}

- (void)testHTTPSessionManager {
    ZCYHTTPSessionManager *manager = [[ZCYHTTPSessionManager alloc] init];
    XCTAssertNotNil(manager);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"network failed"];
    NSDictionary *parameters = @{
                                 @"alt" : @"json",
                                 @"city" : @"北京"
                                 };
    NSURLSessionDataTask *dataTask = [manager GET:@"https://api.douban.com/v2/movie/subject/25894431" parameters:parameters
         success:^(NSURLSessionDataTask *dataTask, id responseObject) {
             NSLog(@"%@", ((NSHTTPURLResponse *)responseObject));
             [expectation fulfill];
         }
         failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
             NSLog(@"%@", error);
         }];
    XCTAssertNotNil(dataTask);
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testJSONSerialization {
    XCTestExpectation *expectation = [self expectationWithDescription:@"serialize failed"];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://api.douban.com/v2/movie/subject/25894431?alt=json&city=%E5%8C%97%E4%BA%AC"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                    
                        
        ZCYJSONResponseSerializer *serializer = [ZCYJSONResponseSerializer serializer];
        serializer.removesKeysWithNullValues = YES;
        
        XCTAssertNotNil(serializer);
        
        NSError *serializationError = nil;
                                    
                                
        id JSONObject = [serializer responseObjectForResponse:response data:data error:&serializationError];
        
        XCTAssertNotNil(JSONObject);
        XCTAssertNil(serializationError);
        XCTAssertTrue([JSONObject isKindOfClass:[NSDictionary class]]);
        
        [expectation fulfill];
    }];
    [dataTask resume];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHTTPGETJSON {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"network failed"];
    ZCYHTTPSessionManager *manager = [ZCYHTTPSessionManager manager];
    
    [manager GET:@"https://api.douban.com/v2/movie/subject/25894431"
      parameters:@{@"alt" : @"json", @"city" : @"北京"}
         success:^(NSURLSessionDataTask *dataTask, id responseObject) {
             
             XCTAssertTrue([responseObject isKindOfClass:[NSDictionary class]]);
             [expectation fulfill];
         }
         failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
             XCTAssertNotNil(error);
             [expectation fulfill];
         }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testHTTPPOSTJSON {
    XCTestExpectation *expectation = [self expectationWithDescription:@"network failed"];
    ZCYHTTPSessionManager *manager = [ZCYHTTPSessionManager manager];
    
    [manager POST:@"http://localhost/Form/create.php"
      parameters:@{@"fname" : @"小明"}
         success:^(NSURLSessionDataTask *dataTask, id responseObject) {
             
             XCTAssertTrue([responseObject isKindOfClass:[NSDictionary class]]);
             NSString *name = [responseObject valueForKey:@"fname"];
             XCTAssertTrue([name isEqualToString:@"小明"]);
             [expectation fulfill];
         }
         failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
             XCTAssertNotNil(error);
             [expectation fulfill];
         }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end
