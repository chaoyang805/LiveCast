//
//  ImageCacheTests.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/20.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCYImageCache.h"

static NSString * const kTestImageKey = @"TestImage.jpg";

@interface ImageCacheTests : XCTestCase

@property (nonatomic, strong) ZCYImageCache *imageCache;

@end

@implementation ImageCacheTests

- (void)setUp {
    [super setUp];
    self.imageCache = [ZCYImageCache sharedImageCache];
    [self clearAllCaches];
}

- (void)testSingleton {
    XCTAssertEqual(self.imageCache, [ZCYImageCache sharedImageCache]);
}

- (void)testInstantiatedCache {
    XCTAssertNotEqual(self.imageCache, [[ZCYImageCache alloc] init]);
}

- (void)testClearDiskCache {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Clear disk cache."];
    
    [self.imageCache storeImage:[self imageForTesting]
                         forKey:kTestImageKey
                   onCompletion:nil];
    
    [self.imageCache clearDiskOnCompletion:^{
        [self.imageCache diskImageExistsWithKey:kTestImageKey completion:^(BOOL isInCache) {
            if (!isInCache) {
                [expectation fulfill];
            } else {
                XCTFail(@"Clear disk cache failed.");
            }
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testClearMemoryCache {
    
    [self.imageCache storeImage:[self imageForTesting]
                         forKey:kTestImageKey onCompletion:nil];
    
    [self.imageCache clearMemory];
    
    UIImage *image = [self.imageCache imageFromMemoryCacheForKey:kTestImageKey];
    XCTAssertNil(image);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Clear memory"];
    [self.imageCache diskImageExistsWithKey:kTestImageKey
                                 completion:^(BOOL isInCache) {
                                     if (isInCache)
                                         [expectation fulfill];
                                     else
                                         XCTFail(@"Image should in cache");
                                 }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInsertionImage {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Test image insertion"];
    
    
    UIImage *imageForTesting = [self imageForTesting];
    [self.imageCache storeImage:imageForTesting forKey:kTestImageKey onCompletion:nil];
    UIImage *image = [self.imageCache imageFromMemoryCacheForKey:kTestImageKey];
    XCTAssertEqual(imageForTesting, image);
    
    [self.imageCache diskImageExistsWithKey:kTestImageKey completion:^(BOOL isInCache) {
        if (isInCache) {
            [expectation fulfill];
        } else {
            XCTFail(@"image should be in cache");
        }
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
}

- (void)testInsertionMemoryOnly {
    XCTestExpectation *e = [self expectationWithDescription:@"Test image insertion memory only"];
    
    [self.imageCache storeImage:[self imageForTesting]
                         forKey:kTestImageKey
                         toDisk:NO
                   onCompletion:nil];
    XCTAssertNotNil([self.imageCache imageFromMemoryCacheForKey:kTestImageKey]);
    XCTAssertEqual([self imageForTesting], [self.imageCache imageFromMemoryCacheForKey:kTestImageKey]);
    [self.imageCache diskImageExistsWithKey:kTestImageKey completion:^(BOOL isInCache) {
        if (!isInCache) {
            [e fulfill];
        } else {
            XCTFail(@"image should not in cache");
        }
    }];

    [self.imageCache clearMemory];
    XCTAssertNil([self.imageCache imageFromMemoryCacheForKey:kTestImageKey]);
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInsertionForcingDiskCache {
    XCTestExpectation *e = [self expectationWithDescription:@"Test image insertion forcing disk storage"];
    
    [self.imageCache storeImage:[self imageForTesting]
                         forKey:kTestImageKey
                         toDisk:YES
                   onCompletion:nil];
    XCTAssertEqual([self.imageCache imageFromMemoryCacheForKey:kTestImageKey], [self imageForTesting]);
    [self.imageCache diskImageExistsWithKey:kTestImageKey completion:^(BOOL isInCache) {
        if (isInCache) {
            [e fulfill];
        } else {
            XCTFail(@"image should in cache");
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRetrieveImageThroughOperation {
    
    XCTestExpectation *e = [self expectationWithDescription:@"retrieve image through operation"];
    
    UIImage *imageForTesting = [self imageForTesting];
    [self.imageCache storeImage:imageForTesting forKey:kTestImageKey onCompletion:nil];
    
    NSOperation *op = [self.imageCache queryCacheOperationForKey:kTestImageKey done:^(UIImage *image, NSData *data, ZCYImageCacheType cacheType) {
        XCTAssertEqual(image, imageForTesting);
        [e fulfill];
    }];
    
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRemoveCacheWithCompletion {
    XCTestExpectation *e = [self expectationWithDescription:@"retrieve image through operation"];
    
    [self.imageCache storeImage:[self imageForTesting] forKey:kTestImageKey onCompletion:nil];
    
    [self.imageCache removeImageForKey:kTestImageKey withCompletion:^{
        
        UIImage *memoryImage = [self.imageCache imageFromMemoryCacheForKey:kTestImageKey];
        UIImage *diskImage = [self.imageCache imageFromDiskCacheForKey:kTestImageKey];
        
        XCTAssertNil(memoryImage);
        XCTAssertNil(diskImage);
        [e fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRemoveCacheOnlyInMemory {
    XCTestExpectation *e = [self expectationWithDescription:@"retrieve image through operation"];
    
    [self.imageCache storeImage:[self imageForTesting] forKey:kTestImageKey onCompletion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imageCache removeImageForKey:kTestImageKey
                                  fromDisk:NO
                            withCompletion:^{
                                XCTAssertNil([self.imageCache imageFromMemoryCacheForKey:kTestImageKey]);
                                XCTAssertNotNil([self.imageCache imageFromDiskCacheForKey:kTestImageKey]);
                                [e fulfill];
                            }];
        
    });
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInitialCacheSize {
    NSUInteger size = [self.imageCache getSize];
    XCTAssertEqual(size, 0);
}

- (void)testCacheSize {
    XCTestExpectation *e = [self expectationWithDescription:@"Cache size geater than zero"];
    [self.imageCache storeImage:[self imageForTesting] forKey:kTestImageKey onCompletion:^{
        NSUInteger size = [self.imageCache getSize];
        XCTAssertGreaterThan(size, 0);
        [e fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testInitialDiskCount {
    NSUInteger diskCount = [self.imageCache getDiskCount];
    XCTAssertEqual(diskCount, 0);
}

- (void)testDiskCount {
    
    XCTestExpectation *e = [self expectationWithDescription:@"Disk count greater than zero"];
    [self.imageCache storeImage:[self imageForTesting] forKey:kTestImageKey onCompletion:^{
        XCTAssertEqual([self.imageCache getDiskCount], 1);
        [e fulfill];
    }];
  
    [self waitForExpectationsWithTimeout:5 handler:nil];
}
- (void)testCalculateInitialSizeAsync {
    
    XCTestExpectation *e = [self expectationWithDescription:@"Calculate initial size async"];
    [self.imageCache calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        XCTAssertEqual(fileCount, 0);
        XCTAssertEqual(totalSize, 0);
        [e fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testCalculateSizeAsync {
    XCTestExpectation *e = [self expectationWithDescription:@"Calculate size async"];
    [self.imageCache storeImage:[self imageForTesting] forKey:kTestImageKey onCompletion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.imageCache calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
            XCTAssertGreaterThan(totalSize, 0);
            XCTAssertEqual(fileCount, 1);
            [e fulfill];
        }];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

#pragma mark - helper
- (void)clearAllCaches {
    
    [self.imageCache deleteOldFilesWithCompletionBlock:nil];
    
    [self.imageCache clearDiskOnCompletion:nil];
    [self.imageCache clearMemory];
}

- (UIImage *)imageForTesting {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *imagePath = [bundle pathForResource:@"TestImage" ofType:@"jpg"];
    
    static UIImage *reusableImage = nil;
    if (!reusableImage) {
        reusableImage = [UIImage imageWithContentsOfFile:imagePath];
    }
    return reusableImage;
}

@end
