//
//  UIView+WebCacheOperation.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/28.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCYImageManager.h"
@interface UIView (WebCacheOperation)

- (void)zcy_setImageLoadOperation:(id)operation forKey:(NSString *)key;

- (void)zcy_cancelImageLoadOperationWithKey:(NSString *)key;

- (void)zcy_removeImageLoadOperationWithKey:(NSString *)key;
@end
