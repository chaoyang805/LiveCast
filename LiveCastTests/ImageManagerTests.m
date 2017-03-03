//
//  ImageManagerTests.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCYImageManager.h"
NSString *workingImageURL = @"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage001.jpg";

@interface ImageManagerTests : XCTestCase

@end

@implementation ImageManagerTests

- (void)setUp {
    [super setUp];
}

- (void)testSharedManager {
    ZCYImageManager *manager = [ZCYImageManager sharedManager];
    XCTAssertNotNil(manager);
}

- (void)testInit {
    ZCYImageManager *manager = [[ZCYImageManager alloc] init];
    XCTAssertNotNil(manager);
    XCTAssertNotEqual(manager, [ZCYImageManager sharedManager]);
}

- (void)testDownloadWithCorrectURL {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    NSURL *url = [NSURL URLWithString:workingImageURL];
    [[ZCYImageManager sharedManager] loadImageWithURL:url options:ZCYImageRefreshCached progress:nil completed:^(UIImage *image, NSData *data, NSError *error, ZCYImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image && !error) {
            XCTAssertEqual(imageURL, url);
            [e fulfill];
        } else {
            XCTFail(@"failed");
        }
    }];
    XCTAssertTrue([ZCYImageManager sharedManager].isRunning);
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testIncorrectURL {
    XCTestExpectation *e = [self expectationWithDescription:@"download incorrect url"];
    NSURL *originImageURL = [NSURL URLWithString:@"http://static2.dmcdn.net/static/video/656/177/44771656:jpeg_preview_small.png"];
    
    [[ZCYImageManager sharedManager] loadImageWithURL:originImageURL options:ZCYImageRefreshCached progress:^(NSUInteger receivedSize, NSUInteger expectedSize, NSURL *targetURL) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, ZCYImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image && error) {
            [e fulfill];
        } else {
            XCTFail(@"failed");
        }
    }];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testCachedImageExistsForURL {
    XCTestExpectation *e = [self expectationWithDescription:@"image exists in cache"];
    [[ZCYImageManager sharedManager] cacheImageExistsForURL:[NSURL URLWithString:workingImageURL] completion:^(BOOL isInCache) {
        XCTAssertTrue(isInCache);
        [e fulfill];
    }];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testDiskImageExistsForURL {
    XCTestExpectation *e = [self expectationWithDescription:@"image exists in disk cache"];
    [[ZCYImageManager sharedManager] diskImageExistsWithURL:[NSURL URLWithString:workingImageURL] completion:^(BOOL isInCache) {
        XCTAssertTrue(isInCache);
        [e fulfill];
    }];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testCancelAll {
    XCTestExpectation *e = [self expectationWithDescription:@""];
    
    NSURL *url = [NSURL URLWithString:workingImageURL];
    [[ZCYImageManager sharedManager] loadImageWithURL:url options:ZCYImageRefreshCached progress:nil completed:^(UIImage *image, NSData *data, NSError *error, ZCYImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        XCTFail(@"failed");
    }];
    
    [[ZCYImageManager sharedManager] cancelAll];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(NO, [ZCYImageManager sharedManager].isRunning);
        [e fulfill];
    });

    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}
@end
