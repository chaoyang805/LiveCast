//
//  ZCYDemoBannerItem.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYDemoBannerItem.h"

@interface ZCYDemoBannerItem ()
@property (nonatomic, copy) NSString *imageName;

@end

@implementation ZCYDemoBannerItem

- (instancetype)initWithImageName:(NSString *)imageName
{
    self = [super init];
    if (self) {
        _imageName = [imageName copy];
    }
    return self;
}

- (UIImage *)bannerImage {
    return [UIImage imageNamed:self.imageName];
}
@end
