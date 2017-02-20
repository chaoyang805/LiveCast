//
//  ZCYImageCache.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/16.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

typedef NS_ENUM(NSUInteger, ZCYImageCacheType) {
    ZCYImageCacheTypeNone,
    
    ZCYImageCacheTypeDisk,
    
    ZCYImageCacheTypeMemory
};

@interface ZCYImageCacheConfig : NSObject

@property (nonatomic, assign) BOOL shouldDecompressImage;
@property (nonatomic, assign) BOOL shouldDisableiCloud;
@property (nonatomic, assign) BOOL shouldCacheImagesInMemory;
@property (nonatomic, assign) NSUInteger maxCacheAge;
@property (nonatomic, assign) NSUInteger maxCacheSize;

@end

@interface ZCYImageCache : NSObject

@property (nonatomic, assign) NSUInteger maxMemoryCost;

@property (nonatomic, assign) NSUInteger maxMemoryCountLimit;

- (instancetype)initWithNamespace:(NSString *)ns
               diskCacheDirectory:(NSString *)directory;

+ (instancetype)sharedImageCache;
#pragma mark - Cache image

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
      onCompletion:(void (^)())completionBlock;

- (void)storeImage:(UIImage *)image
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
      onCompletion:(void (^)())completionBlock;

- (void)storeImage:(UIImage *)image
         imageData:(NSData *)data
            forKey:(NSString *)key
            toDisk:(BOOL)toDisk
      onCompletion:(void(^)())completion;

- (void)storeImageDataToDisk:(NSData *)imageData forKey:(NSString *)key;

#pragma mark - query and retrieve

- (void)diskImageExistsWithKey:(NSString *)key completion:(void (^)(BOOL isInCache))completionBlock;

- (UIImage *)imageFromMemoryCacheForKey:(NSString *)key;

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key;

- (UIImage *)imageFromCacheForKey:(NSString *)key;

- (NSOperation *)queryCacheOperationForKey:(NSString *)key done:(void (^)(UIImage *image, NSData *data, ZCYImageCacheType cacheType))doneBlock;
#pragma mark - path
- (NSString *)makeDiskCachePath:(NSString *)path;

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path;

- (NSString *)defaultCachePathForKey:(NSString *)key;

- (void)addReadOnlyCachePath:(NSString *)path;

#pragma mark - Remove options

- (void)removeImageForKey:(NSString *)key withCompletion:(void (^)(void))completionBlock;

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk withCompletion:(void (^)(void))completionBlock;

#pragma mark - Cache clean

- (void)clearMemory;

- (void)clearDiskOnCompletion:(void (^)(void))completionBlock;

- (void)deleteOldFilesWithCompletionBlock:(void (^)(void))completionBlock;

#pragma mark Cache Info
- (NSUInteger)getSize;

- (NSUInteger)getDiskCount;

- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completionBlock;
@end
