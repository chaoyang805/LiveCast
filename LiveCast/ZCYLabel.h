//
//  ZCYLabel.h
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/26.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCYLabel : UIControl

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, copy) NSString *text;
// the alpha component of tint color
@property (nonatomic, assign) CGFloat alpha;


- (instancetype)initWithFrame:(CGRect)frame;

@end
