//
//  UIImageView+RoundedCorner.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/11.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "UIImageView+RoundedCorner.h"
#import "UIImage+RoundedCorner.h"
@implementation UIImageView (RoundedCorner)
- (void)zcy_addRoundedCorner:(CGFloat)radius {
    if (!self.image) {
        return;
    }
    self.image = [self.image zcy_imageWithRoundedCorner:radius size:self.bounds.size];
}
@end
