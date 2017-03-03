//
//  ZCYDotWrapper.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/17.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

@interface ZCYDotWrapper : NSObject

@property (nonatomic, strong, readonly) UIView* dotView;
@property (nonatomic, assign, readwrite) NSUInteger index;
@property (nonatomic, readonly) CGPoint origin;

- (instancetype)initWithDotView:(UIView *)view atIndex:(NSUInteger)index;
- (void)animateWithOffset:(NSValue *)offsetValue;
@end
