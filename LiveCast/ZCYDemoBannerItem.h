//
//  ZCYDemoBannerItem.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYBannerView.h"

@interface ZCYDemoBannerItem : NSObject <ZCYBannerItemType>

- (instancetype)initWithImageName:(NSString *)imageName;
- (UIImage *)bannerImage;
@end
