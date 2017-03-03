//
//  ImageDownloadOperationTests.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZCYImageDownloaderOperation.h"

@interface ImageDownloader : XCTestCase

@property (nonatomic, strong) ZCYImageDownloader *downloader;

@end

@implementation ImageDownloader

- (void)setUp {
    [super setUp];
    self.downloader = [ZCYImageDownloader sharedDownloader];
}


- (void)testSharedDownloader {
    ZCYImageDownloader *sharedInstance = [ZCYImageDownloader sharedDownloader];
    XCTAssertNotNil(sharedInstance);
}

- (void)testSharedDownloaderDoesntEqualToDownloader {
    ZCYImageDownloader *downloader = [[ZCYImageDownloader alloc] init];
    XCTAssertNotEqual(downloader, [ZCYImageDownloader sharedDownloader]);
}

- (void)testSetAndGetHeader {
    NSString *header = @"Header";
    NSString *field = @"Field";
    
    [self.downloader setValue:header forHTTPHeaderField:field];
    XCTAssertTrue([[self.downloader valueForHTTPHeaderField:field] isEqualToString:header]);
    
    [self.downloader setValue:nil forHTTPHeaderField:field];
    
    XCTAssertNil([self.downloader valueForHTTPHeaderField:field]);
}

- (void)testSimpleDownload {
    XCTestExpectation *e = [self expectationWithDescription:@"Simple download"];
    
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage004.jpg"];
    [self.downloader downloadImageWithURL:url
                                  options:0
                                 progress:nil
                                completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
                                    if (image && imageData && !error && finished) {
                                        [e fulfill];
                                    } else {
                                        XCTFail(@"download failed");
                                    }
                                }];
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

- (void)testSetMaxConcurrent {
    NSInteger maxConcurrent = self.downloader.maxConcurrentDownloads;
    [self.downloader setMaxConcurrentDownloads:3];
    XCTAssertEqual(self.downloader.maxConcurrentDownloads, 3);
    [self.downloader setMaxConcurrentDownloads:maxConcurrent];
}

- (void)testAddProgressCallback {
    
//    XCTestExpectation *e = [self expectationWithDescription:@"Add progressCallback"];
//    
//    [self.downloader addProgressCallback:nil
//                          completedBlock:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
//                              XCTAssertTrue(!image && !imageData && !error && !finished);
//                              [e fulfill];
//                          }
//                                  forURL:nil
//                          createCallback:nil];
//    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testAuthDownload {
    XCTestExpectation *e = [self expectationWithDescription:@"Auth Download"];
    
    self.downloader.username = @"httpwatch";
    self.downloader.password = @"httpwatch01";
    
    NSURL *url = [NSURL URLWithString:@"http://www.httpwatch.com/httpgallery/authentication/authenticatedimage/default.aspx?0.35786508303135633"];
    [self.downloader downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (image && imageData && !error && finished) {
            [e fulfill];
        } else {
            XCTFail(@"Auth failed");
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
}

- (void)testProgressiveDownload {
    XCTestExpectation *e = [self expectationWithDescription:@"progressive download"];
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage009.jpg"];
    [self.downloader downloadImageWithURL:url options:ZCYImageDownloaderProgressiveDownload progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (image && imageData && finished) {
            [e fulfill];
        } else if (finished) {
            XCTFail(@"failed");
        } else {
            
        }
    }];
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

- (void)test404NotFound {
    XCTestExpectation *e = [self expectationWithDescription:@"404"];
    
    [self.downloader downloadImageWithURL:[NSURL URLWithString:@"http://static2.dmcdn.net/static/video/656/177/44771656:jpeg_preview_small.jpg?20120509154705"] options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (!image && !image && error && finished) {
            NSLog(@"%@", error);
            [e fulfill];
        } else {
            XCTFail(@"failed");
        }
    }];
    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testCancel {
    XCTestExpectation *e = [self expectationWithDescription:@"Cancel"];
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage009.jpg"];
    ZCYImageDownloadToken *token = [self.downloader downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        XCTFail(@"failed");
    }];
    XCTAssertEqual(1, self.downloader.currentDownloadCount);
    [self.downloader cancel:token];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger count = self.downloader.currentDownloadCount;
        XCTAssertEqual(0, count);
        [e fulfill];
    });
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testAnotherSession {
    XCTestExpectation *e = [self expectationWithDescription:@"another session"];
    
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage009.jpg"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    request.HTTPShouldUsePipelining = YES;
    request.allHTTPHeaderFields = @{@"Accept" : @"image/*;q=0.8"};
    
    ZCYImageDownloaderOperation *operation = [[ZCYImageDownloaderOperation alloc] initWithRequest:request inSession:nil options:0];
    [operation addHandlersForProgress:^(NSUInteger receivedSize, NSUInteger expectedSize, NSURL *targetURL) {
        
        
    }
                       completedBlock:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
                           
                           if (image && imageData && !error && finished) {
                               [e fulfill];
                           } else {
                               XCTFail(@"failed");
                           }
                       }];
    [operation start];
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

- (void)testEnterBackground {
    XCTestExpectation *e = [self expectationWithDescription:@"enter background"];
    NSURL *url = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage009.jpg"];
    [self.downloader downloadImageWithURL:url options:ZCYImageDownloaderContinueInBackground progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (image && imageData && !error && finished) {
            [e fulfill];
        } else {
            XCTFail(@"failed");
        }
    }];
    XCTAssertEqual(self.downloader.currentDownloadCount, 1);
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testDownloadPNG {
    XCTestExpectation *e = [self expectationWithDescription:@"download png"];
    NSURL *url = [NSURL URLWithString:@"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png"];
    [self.downloader downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (imageData && image && !error && finished) {
            [e fulfill];
        } else {
            XCTFail(@"failed");
        }
    }];
    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}
/*
- (void)testWebP {
    XCTestExpectation *e = [self expectationWithDescription:@"download webp"];
    NSURL *url = [NSURL URLWithString:@"http:www.ioncannon.net/wp-content/uploads/2011/06/test2.webp"];
    [self.downloader downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (imageData && image && !error && finished) {
            [e fulfill];
        } else {
            XCTFail(@"failed");
        }
    }];
    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}
 */
- (void)testDownloadTwiceCancelFirst {
    XCTestExpectation *e = [self expectationWithDescription:@"download twice"];
    NSURL *imageURL = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage020.jpg"];
    ZCYImageDownloadToken *token1 = [self.downloader downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        XCTFail(@"failed");
    }];
    XCTAssertNotNil(token1);
    ZCYImageDownloadToken *token2 = [self.downloader downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (image && imageData && !error && finished) {
            [e fulfill];
        } else {
            XCTFail(@"failed 2");
        }
    }];
    XCTAssertNotNil(token2);
    [self.downloader cancel:token1];
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

- (void)testCancelAndRedownload{
    XCTestExpectation *e = [self expectationWithDescription:@"download twice"];
    NSURL *imageURL = [NSURL URLWithString:@"http://s3.amazonaws.com/fast-image-cache/demo-images/FICDDemoImage020.jpg"];
    ZCYImageDownloadToken *token1 = [self.downloader downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        XCTFail(@"failed");
    }];
    XCTAssertNotNil(token1);
    [self.downloader cancel:token1];
    
    ZCYImageDownloadToken *token2 = [self.downloader downloadImageWithURL:imageURL options:0 progress:nil completed:^(UIImage *image, NSData *imageData, NSError *error, BOOL finished) {
        if (image && imageData && !error && finished) {
            [e fulfill];
        } else {
            XCTFail(@"failed 2 image=%@, data=%@, error=%@",image, imageData, error);
        }
    }];
    XCTAssertNotNil(token2);
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
