//
//  ZCYImageDownloaderOperation.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/21.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYImageDownloaderOperation.h"
#import "ZCYImageDownloader.h"
#import <ImageIO/ImageIO.h>
#import "UIImage+Decode.h"
#import "UIImage+MultiFormat.h"

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";
typedef NSDictionary<NSString *, id> * ZCYCallbackDictionary ;

@interface ZCYImageDownloaderOperation ()

@property (nonatomic, strong) NSMutableArray<ZCYCallbackDictionary> *callbackBlocks;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, strong) NSMutableData *imageData;
@property (nonatomic, weak) NSURLSession *unownedSession;
@property (nonatomic, strong) NSURLSession *ownedSession;
@property (nonatomic, strong, readwrite) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation ZCYImageDownloaderOperation {
    BOOL responseFromCached;
    size_t width, height;
    UIImageOrientation orientation;
}

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithRequest:(NSURLRequest *)request
                      inSession:(NSURLSession *)session
                        options:(ZCYImageDownloaderOptions)options {
    self = [super init];
    if (!self) {
        return nil;
    }
    _request = [request copy];
    _options = options;
    _shouldDecompressImages = YES;
    _expectedSize = 0;
    _executing = NO;
    _finished = NO;
    _callbackBlocks = [NSMutableArray array];
    _unownedSession = session;
    _barrierQueue = dispatch_queue_create("me.chaoyang805.ImageDownloader.Operation.BarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    
    return self;
}

- (id)addHandlersForProgress:(void (^)(NSUInteger, NSUInteger, NSURL *))progressBlock
              completedBlock:(void (^)(UIImage *, NSData *, NSError *))completedBlock {
    NSMutableDictionary *callbacks = [NSMutableDictionary new];
    
    if (progressBlock) callbacks[kProgressCallbackKey] = progressBlock;
    if (completedBlock) callbacks[kCompletedCallbackKey] = completedBlock;
    
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks addObject:[callbacks copy]];
    });
    return callbacks;
}

- (NSArray *)callbacksForKey:(NSString *)key {
    __block NSMutableArray *callbacks = [NSMutableArray array];
    dispatch_barrier_sync(self.barrierQueue, ^{
        callbacks = [[self.callbackBlocks valueForKey:key] mutableCopy];
        [callbacks removeObjectIdenticalTo:[NSNull null]];
    });
    return callbacks;
}

- (BOOL)cancel:(id)token {
    __block BOOL shouldCancel = NO;
    dispatch_barrier_sync(self.barrierQueue, ^{
        [self.callbackBlocks removeObjectIdenticalTo:token];
        if (self.callbackBlocks.count == 0) {
            shouldCancel = YES;
        }
    });
    if (shouldCancel) {
        [self cancel];
    }
    return shouldCancel;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)start {
    @synchronized (self) {
        if (self.cancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        
        // if enter bg self cancel
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        if ((UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)]) &&
            [self shouldContinueWhenEnterBackground]) {
        
            __weak typeof(self) weakSelf = self;
            UIApplication *app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                
                __strong typeof(weakSelf) strongSelf = self;
                if (strongSelf) {
                    [strongSelf cancel];
                    [app endBackgroundTask:strongSelf.backgroundTaskId];
                    strongSelf.backgroundTaskId = UIBackgroundTaskInvalid;
                }
                
            }];
            
        }
        // create session and dataTask executing
        NSURLSession *session = self.unownedSession;
        if (!session) {
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            sessionConfig.timeoutIntervalForRequest = 15;
            self.ownedSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                              delegate:self
                                                         delegateQueue:nil];
            session = self.ownedSession;
        }
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:self.request];
        self.dataTask = dataTask;
        self.executing = YES;
    }
    // resume task
    [self.dataTask resume];
    // notify progress block and post start notification else completionBlockWithError
    if (self.dataTask) {
        // call progress block
        for (ZCYImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, NSURLResponseUnknownLength, self.request.URL);
        }
        // post task start notification
    } else {
        // call completionBlockWithError
        [self callCompletionBlockWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}]];
    }
    // end background task
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication *app = [UIApplicationClass performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}
- (void)reset {
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbackBlocks removeAllObjects];
    });
    self.dataTask = nil;
    self.imageData = nil;
    if (self.ownedSession) {
        [self.ownedSession invalidateAndCancel];
        self.ownedSession = nil;
    }
}

- (void)cancel {
    @synchronized (self) {
        [self cancelInternal];
    }
}

- (void)cancelInternal {
    if (self.isFinished) {
        return;
    }
    [super cancel];
    if (self.dataTask) {
        [self.dataTask cancel];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [NSNotificationCenter defaultCenter] postNotificationName:<#(nonnull NSNotificationName)#> object:<#(nullable id)#>
        });
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)callCompletionBlockWithError:(NSError *)error {
    [self callCompletionBlockWithImage:nil imageData:nil error:error finished:YES];
}

- (void)callCompletionBlockWithImage:(UIImage *)image
                           imageData:(NSData *)data
                               error:(NSError *)error
                            finished:(BOOL)finished {
    NSArray *callbacks = [self callbacksForKey:kCompletedCallbackKey];
    dispatch_main_safe(^{
        for (ZCYImageDownloaderCompletedBlock completedBlock in callbacks) {
            completedBlock(image, data, error, finished);
        }
    });
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)shouldContinueWhenEnterBackground {
    return self.options & ZCYImageDownloaderContinueInBackground;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
 
    // statusCode < 400 && != 304 initialize imageData , call progressBlock, setResponse postReceiveResponseNotification
    if (response && [response respondsToSelector:@selector(statusCode)] && ((NSHTTPURLResponse *)response).statusCode < 400 && ((NSHTTPURLResponse *)response).statusCode != 304) {
        NSUInteger expectedLength = response.expectedContentLength > 0 ? response.expectedContentLength : 0;
        self.expectedSize = expectedLength;
        for (ZCYImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
            progressBlock(0, expectedLength, self.request.URL);
        }
        self.imageData = [[NSMutableData alloc] initWithCapacity:expectedLength];
        self.response = response;
        dispatch_async(dispatch_get_main_queue(), ^{
            // post notification
        });
    } else {
        // statusCode == 304 Not Modified
        NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (statusCode == 304) {
            [self cancelInternal];
        } else {
            [self.dataTask cancel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // post stop notification
        });
        [self callCompletionBlockWithError:[NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:nil]];
        [self done];
        
    }
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.imageData appendData:data];
    
    if (self.options & ZCYImageDownloaderProgressiveDownload && self.expectedSize > 0) {
        const NSInteger totalSize = self.imageData.length;
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
        
        if (width + height == 0) {
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
            
            if (properties) {
                NSInteger orientationValue = -1;
                CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
                if (val) CFNumberGetValue(val, kCFNumberLongType, &height);
                val = CFDictionaryGetValue(properties, kCGImagePropertyDPIWidth);
                if (val) CFNumberGetValue(val, kCFNumberLongType, &width);
                val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
                if (val) CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
                
                CFRelease(properties);
                orientation = [[self class] orientationFromPropertyValue:orientationValue == -1 ? 1 : orientationValue];
            }
        }
        
        if (width + height > 0 && totalSize < self.expectedSize) {
            
            CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
            if (partialImageRef) {
                const size_t partialHeight = CGImageGetHeight(partialImageRef);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
                CGColorSpaceRelease(colorSpace);
                if (bmContext) {
                    CGContextDrawImage(bmContext, CGRectMake(0, 0, width, partialHeight), partialImageRef);
                    CGImageRelease(partialImageRef);
                    partialImageRef = CGBitmapContextCreateImage(bmContext);
                    CGContextRelease(bmContext);
                } else {
                    CGImageRelease(partialImageRef);
                    partialImageRef = nil;
                }
            }
            
            if (partialImageRef) {
                UIImage *image = [UIImage imageWithCGImage:partialImageRef scale:1.0f orientation:orientation];
                NSString *key;// Manager cacheKeyForURL
                UIImage *scaledImage = [self scaledImageForKey:key image:image];
                if (self.shouldDecompressImages) {
                    image = [UIImage decodeImageWithImage:scaledImage];
                } else {
                    image = scaledImage;
                }
                
                CGImageRelease(partialImageRef);
                [self callCompletionBlockWithImage:image imageData:nil error:nil finished:NO];
            }
        }
        CFRelease(imageSource);
    }
    
    for (ZCYImageDownloaderProgressBlock progressBlock in [self callbacksForKey:kProgressCallbackKey]) {
        progressBlock(self.imageData.length, self.expectedSize, self.request.URL);
    }
    
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler {
    // change cache flag to NO
    responseFromCached = NO;
    NSCachedURLResponse *cachedResponse = proposedResponse;
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringCacheData) {
        cachedResponse = nil;
    }
    completionHandler(cachedResponse);
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    @synchronized (self) {
        self.dataTask = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
// post stop notification [[NSNotificationCenter defaultCenter] postNotificationName:<#(nonnull NSNotificationName)#> object:<#(nullable id)#>]
            if (!error) {
                // post finish noti
            }
        });
    }
    
    if (error) {
        [self callCompletionBlockWithError:error];
    } else {
        if ([self callbacksForKey:kCompletedCallbackKey].count > 0) {
            if (self.options & ZCYImageDownloaderIgnoreCachedRespose && responseFromCached && [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request]) {
                [self callCompletionBlockWithImage:nil imageData:nil error:nil finished:YES];
            } else if (self.imageData) {
                UIImage *image = [UIImage zcy_imageWithData:self.imageData];
                NSString *key; // = [manager cacheKeyForURL];
                image = [self scaledImageForKey:key image:image];
                if (!image.images) {
                    if (self.shouldDecompressImages) {
                        if (self.options & ZCYImageDownloaderScaleDownLargeImages) {
                            image = [UIImage decodeAndScaleDownImageWithImage:image];
                            [self.imageData setData:UIImagePNGRepresentation(image)];
                        } else {
                            image = [UIImage decodeImageWithImage:image];
                        }
                    }
                }
                if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                    [self callCompletionBlockWithError:[NSError errorWithDomain:ZCYImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}]];
                } else {
                    [self callCompletionBlockWithImage:image imageData:self.imageData error:nil finished:YES];
                }
            } else {
                [self callCompletionBlockWithError:[NSError errorWithDomain:ZCYImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}]];
            }
        }
    }
    [self done];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & ZCYImageDownloaderAllowInvalidSSLCertificates)) {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        } else {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            disposition = NSURLSessionAuthChallengeUseCredential;
        }
    } else {
        if (challenge.previousFailureCount == 0) {
            if (self.credential) {
                credential = self.credential;
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark - Helper
- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image {
    return ZCYScaledImageForKey(key, image);
}

+ (UIImageOrientation)orientationFromPropertyValue:(NSUInteger)value {
    UIImageOrientation orientation;
    switch (value) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
        case 3:
            orientation = UIImageOrientationDown;
            break;
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
        case 6:
            orientation = UIImageOrientationRight;
            break;
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
        case 8:
            orientation = UIImageOrientationLeft;
            break;
        default:
            orientation = UIImageOrientationUp;
            break;
    }
    return orientation;
}
@end
