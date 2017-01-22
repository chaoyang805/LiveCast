//
//  ZCYMineViewModel.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/22.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCYSettingItem;

@interface ZCYMineViewModel : NSObject



- (void)loadSectionInfo;

- (NSUInteger)sectionCount;

- (NSUInteger)itemsCountInSection:(NSUInteger)section;

- (nonnull ZCYSettingItem *)modelAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (nonnull NSString *)settingTitleAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (nonnull UIImage *)settingIconAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (nullable NSString *)extraInfoAtIndexPath:(nonnull NSIndexPath *)indexPath;

- (BOOL)hasUnreadItemAtIndex:(nonnull NSIndexPath *)indexPath;

@end
