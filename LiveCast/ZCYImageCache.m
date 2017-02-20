//
//  ZCYImageCache.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/16.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYImageCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+ImageContentType.h"
#import "UIImage+MultiFormat.h"
#import "UIImage+Decode.h"
#import "UIImage+GIF.h"

static NSUInteger ZCYCacheCostForImage(UIImage *image) {
    return image.size.height * image.size.width * image.scale * image.scale;
}

static UIImage *ZCYScaledImageForKey(NSString *key, UIImage *image) {
    if (!image) {
        return nil;
    }
    if (image.images.count > 0) {
        
        NSMutableArray *scaledImages = [NSMutableArray array];
        
        for (UIImage *tempImage in image.images) {
            [scaledImages addObject:ZCYScaledImageForKey(key, tempImage)];
        }
        return [UIImage animatedImageWithImages:scaledImages duration:image.duration];
    } else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            CGFloat scale = 1;
            if (key.length >= 8) {
                NSRange range = [key rangeOfString:@"@2x."];
                if (range.location != NSNotFound) {
                    scale = 2.0;
                }
                range = [key rangeOfString:@"@3x."];
                if (range.location != NSNotFound) {
                    scale = 3.0;
                }
            }
            image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
            ;
            
        }
        return image;
    }
}

@interface ZCYAutoPurgeCache : NSCache

@end

@implementation ZCYAutoPurgeCache

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end

static const NSUInteger kDefaultCacheMaxCacheAge = 7 * 24 * 3600;

@implementation ZCYImageCacheConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldDisableiCloud = YES;
        _shouldDecompressImage = YES;
        _shouldCacheImagesInMemory = YES;
        
        _maxCacheAge = kDefaultCacheMaxCacheAge;
        _maxCacheSize = 0;
    }
    return self;
}
@end

@interface ZCYImageCache ()

@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, copy) NSString *diskCachePath;
@property (nonatomic, strong) ZCYImageCacheConfig *cacheConfig;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@property (nonatomic, strong) NSMutableArray<NSString *> *customPaths;
@end

@implementation ZCYImageCache {
    NSFileManager *_fileManager;
}

+ (instancetype)sharedImageCache {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    return [self initWithNamespace:@"default"];
}

- (instancetype)initWithNamespace:(NSString *)ns {
    NSString *path = [self makeDiskCachePath:ns];
    return [self initWithNamespace:ns diskCacheDirectory:path];
}

- (instancetype)initWithNamespace:(NSString *)ns
               diskCacheDirectory:(NSString *)directory {
    self = [super init];
    if (!self) {
        return nil;
    }
    NSString *fullNamespace = [@"me.chaoyang805.LiveCast.ImageCache." stringByAppendingString:ns];
    
    if (directory) {
        _diskCachePath = [directory stringByAppendingPathComponent:fullNamespace];
    } else {
        _diskCachePath = [self makeDiskCachePath:ns];
    }
    
    _cacheConfig = [ZCYImageCacheConfig new];
    
    _memCache = [ZCYAutoPurgeCache new];
    _memCache.name = fullNamespace;
    
    // io 操作都放到 ioQueue 里去
    _ioQueue = dispatch_queue_create("me.chaoyang805.LiveCast.ImageCache", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(_ioQueue, ^{
        _fileManager = [NSFileManager new];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemory)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteOldFiles)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backgroundDeleteOldFiles)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkIQueueIsIOQueue {
    if (strcmp(dispatch_queue_get_label(nil), dispatch_queue_get_label(self.ioQueue)) != 0) {
        NSLog(@"This method should be called from ioQueue");
    }
    
}

#pragma mark - Cache image

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
      onCompletion:(void (^)())completionBlock {
    [self storeImage:image forKey:key toDisk:YES onCompletion:completionBlock];
}

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
      onCompletion:(void (^)())completionBlock {
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk onCompletion:completionBlock];
}

- (void)storeImage:(UIImage *)image
         imageData:(NSData *)imageData
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
      onCompletion:(void (^)())completionBlock {

    if (!image || !key) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    if (self.cacheConfig.shouldCacheImagesInMemory) {
        NSUInteger cost = ZCYCacheCostForImage(image);
        [self.memCache setObject:image forKey:key cost:cost];
    }
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            NSData *data = imageData;
            if (!data && image) {
                ZCYImageFormat imageFormat = [NSData zcy_imageFormatFromImageData:data];
                data = [image zcy_imageDataAsFormat:imageFormat];
            }
            
            [self storeImageDataToDisk:data forKey:key];
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), completionBlock);
            }
            
        });
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)storeImageDataToDisk:(NSData *)imageData forKey:(NSString *)key {
    if (!imageData || !key) {
        return;
    }
    [self checkIQueueIsIOQueue];
    
    if (![_fileManager fileExistsAtPath:_diskCachePath]) {
        [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [self defaultCachePathForKey:key];
    
    [_fileManager createFileAtPath:filePath contents:imageData attributes:nil];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    if (_cacheConfig.shouldDisableiCloud) {
        [fileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];
    }
}

#pragma mark - query and retrieve

- (void)diskImageExistsWithKey:(NSString *)key completion:(void (^)(BOOL))completionBlock {
    dispatch_async(_ioQueue, ^{
        
        BOOL exists = [_fileManager fileExistsAtPath:[self defaultCachePathForKey:key]];
        if (!exists) {
            exists = [_fileManager fileExistsAtPath:[self defaultCachePathForKey:[key stringByDeletingPathExtension]]];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(exists);
            });
        }
    });
}

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key {
    return [self.memCache objectForKey:key];
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key {
    UIImage *diskImage = [self diskImageForKey:key];
    if (diskImage && self.cacheConfig.shouldCacheImagesInMemory) {
        NSUInteger cost = ZCYCacheCostForImage(diskImage);
        [self.memCache setObject:diskImage forKey:key cost:cost];
    }
    return diskImage;
}

- (UIImage *)imageFromCacheForKey:(NSString *)key {
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    if (image) {
        return image;
    }
    image = [self imageFromDiskCacheForKey:key];
    return image;
}


- (UIImage *)diskImageForKey:(NSString *)key {
    NSData *data = [self diskImageDataBySearchingAllPathsForKey:key];
    if (data) {
        UIImage *image = [UIImage zcy_imageWithData:data];
        image = [self scaledImageForKey:key image:image];
        if (self.cacheConfig.shouldDecompressImage) {
            image = [UIImage decodeImageWithImage:image];
        }
        return image;
    } else {
        return nil;
    }
}

- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image {
    return ZCYScaledImageForKey(key, image);
}

- (NSData *)diskImageDataBySearchingAllPathsForKey:(NSString *)key {
    NSString *defaultPath = [self defaultCachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:defaultPath];
    if (data) {
        return data;
    }
    data = [NSData dataWithContentsOfFile:[defaultPath stringByDeletingPathExtension]];
    if (data) {
        return data;
    }
    NSArray<NSString *> *customPaths = [self.customPaths copy];
    for (NSString *customPath in customPaths) {
        NSString *filePath = [self cachePathForKey:key inPath:customPath];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        if (imageData) {
            return imageData;
        }
        imageData = [NSData dataWithContentsOfFile:[filePath stringByDeletingPathExtension]];
        if (imageData) {
            return imageData;
        }
    }
    return nil;
}

- (NSOperation *)queryCacheOperationForKey:(NSString *)key done:(void (^)(UIImage *image, NSData *data, ZCYImageCacheType cacheType))doneBlock {
    if (!key) {
        if (doneBlock) {
            doneBlock(nil, nil, ZCYImageCacheTypeNone);
        }
        return nil;
    }
    UIImage *image = [self imageFromMemoryCacheForKey:key];
    
    if (image) {
        NSData *diskData = nil;
        if ([image isGIF]) {
            diskData = [self diskImageDataBySearchingAllPathsForKey:key];
        }
        if (doneBlock) {
            doneBlock(image, diskData, ZCYImageCacheTypeMemory);
        }
        return nil;
    }
    
    NSOperation *operation = [NSOperation new];
    
    dispatch_async(_ioQueue, ^{
        if (operation.isCancelled) {
            return;
        }
        @autoreleasepool {
            NSData *diskData = [self diskImageDataBySearchingAllPathsForKey:key];
            UIImage *diskImage = [self diskImageForKey:key];
            
            if (self.cacheConfig.shouldCacheImagesInMemory) {
                NSUInteger cost =  ZCYCacheCostForImage(image);
                [self.memCache setObject:diskImage forKey:key cost:cost];
            }
            if (doneBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    doneBlock(diskImage, diskData, ZCYImageCacheTypeDisk);
                });
            }
        }
    });
    return operation;
};

#pragma mark - cache paths
- (NSString *)makeDiskCachePath:(NSString *)path {
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths[0] stringByAppendingPathComponent:path];
}

- (NSString *)cacheFileNameForKey:(NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@", r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15], key.pathExtension ? @"" : [NSString stringWithFormat:@".%@", key.pathExtension]];
    
    return filename;
}

- (void)addReadOnlyCachePath:(NSString *)path {
    if (self.customPaths == nil) {
        self.customPaths = [NSMutableArray array];
    }
    [self.customPaths addObject:path];
}

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cacheFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}

- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}

#pragma mark - Remove options

- (void)removeImageForKey:(NSString *)key withCompletion:(void (^)(void))completionBlock {
    [self removeImageForKey:key fromDisk:YES withCompletion:completionBlock];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(void (^)(void))completionBlock {
    if (!key) {
        return;
    }
    if (self.cacheConfig.shouldCacheImagesInMemory) {
        [self.memCache removeObjectForKey:key];
    }
    if (fromDisk) {
        dispatch_async(_ioQueue, ^{
            [_fileManager removeItemAtPath:[self defaultCachePathForKey:key] error:NULL];
            if (completionBlock) {
                completionBlock();
            }
        });
    } else if (completionBlock) {
        completionBlock();
    }
}

#pragma mark Mem Cache setting

- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost {
    self.memCache.totalCostLimit = maxMemoryCost;
}

- (NSUInteger)maxMemoryCost {
    return self.memCache.totalCostLimit;
}

- (void)setMaxMemoryCountLimit:(NSUInteger)maxMemoryCountLimit {
    self.memCache.countLimit = maxMemoryCountLimit;
}

- (NSUInteger)maxMemoryCountLimit {
    return self.memCache.countLimit;
}

#pragma mark - Cache clean

- (void)clearMemory {
    [self.memCache removeAllObjects];
}

- (void)clearDiskOnCompletion:(void (^)(void))completionBlock {
    dispatch_async(_ioQueue, ^{
        [_fileManager removeItemAtPath:self.diskCachePath error:NULL];
        [_fileManager createDirectoryAtPath:self.diskCachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    });
}

- (void)deleteOldFiles {
    [self deleteOldFilesWithCompletionBlock:nil];
}

- (void)deleteOldFilesWithCompletionBlock:(void (^)(void))completionBlock {
    dispatch_async(_ioQueue, ^{
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray<NSURLResourceKey> *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:resourceKeys
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.cacheConfig.maxCacheAge];
        NSMutableDictionary<NSURL *, NSDictionary<NSString *, id> *> *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        NSMutableArray<NSURL *> *URLsToDelete = [NSMutableArray array];
        
        for(NSURL *fileURL in fileEnumerator) {
            NSError *error;
            NSDictionary<NSString *, id> *resourcesValues = [fileURL resourceValuesForKeys:resourceKeys error:&error];
            if (error || [resourcesValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            NSDate *modificationDate = resourcesValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [URLsToDelete addObject:fileURL];
                continue;
            }
            
            NSNumber *totalAllocatedSize = resourcesValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += totalAllocatedSize.unsignedIntegerValue;
            cacheFiles[fileURL] = resourcesValues;
        }
        
        for (NSURL *fileURL in URLsToDelete) {
            [_fileManager removeItemAtURL:fileURL error:NULL];
        }
        
        if (self.cacheConfig.maxCacheSize > 0 && currentCacheSize > self.cacheConfig.maxCacheSize) {
            const NSUInteger disiredCacheSize = self.cacheConfig.maxCacheSize / 2;
            
            NSArray<NSURL *> *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                                     usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                                                         return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                                     }];
            for (NSURL *fileURL in sortedFiles) {
                NSDictionary<NSString *, id> *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= totalAllocatedSize.unsignedIntegerValue;
                if (currentCacheSize < disiredCacheSize) {
                    break;
                }
            }
            
        }
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
        
    });
}

- (void)backgroundDeleteOldFiles {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (!UIApplicationClass && ![UIApplicationClass respondsToSelector:(@selector(sharedApplication))]) {
        return;
    }
    
    UIApplication *sharedApplication = [UIApplicationClass performSelector: @selector(sharedApplication)];
    if (sharedApplication) {
        __block UIBackgroundTaskIdentifier bgTaskId = [sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            [sharedApplication endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;
        }];
        [self deleteOldFilesWithCompletionBlock:^{
            [sharedApplication endBackgroundTask:bgTaskId];
            bgTaskId = UIBackgroundTaskInvalid;
        }];
    }
    
}

#pragma mark - Cache info

- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    dispatch_sync(_ioQueue, ^{
        
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary<NSFileAttributeKey, id> *attr = [_fileManager attributesOfItemAtPath:filePath error:NULL];
            size += [attr fileSize];
        }
        
    });
    return size;
}

- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(_ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        count = fileEnumerator.allObjects.count;
    });
    return count;
}

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completionBlock {
    
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    __block NSUInteger fileCount = 0;
    __block NSUInteger totalSize = 0;
    dispatch_async(_ioQueue, ^{

        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtURL:diskCacheURL
                                                   includingPropertiesForKeys:@[NSFileSize]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                 errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            fileCount += 1;
            totalSize += fileSize.unsignedIntegerValue;
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(fileCount, totalSize);
            });
        }
    });
}
@end
