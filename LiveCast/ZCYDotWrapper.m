//
//  ZCYDotWrapper.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYDotWrapper.h"

static const NSTimeInterval kAnimationDuration = 0.3f;

@interface ZCYDotWrapper ()

@property (nonatomic, strong, readwrite) UIView* dotView;

@end

@implementation ZCYDotWrapper

- (instancetype)initWithDotView:(UIView *)view atIndex:(NSUInteger)index {
    self = [super init];
    if (self) {
        _dotView = view;
        _index = index;
    }
    return self;
}

- (void)animateWithOffset:(NSValue *)offsetValue {
    
    CGPoint offset = offsetValue.CGPointValue;
    CGRect destFrame = CGRectOffset(self.dotView.frame, offset.x, offset.y);
    
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         self.dotView.frame = destFrame;
                     }];
}

- (CGPoint)origin {
    return _dotView.frame.origin;
}

@end
