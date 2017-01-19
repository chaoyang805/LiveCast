//
//  ZCYLabel.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/26.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYLabel.h"

@interface ZCYLabel ()

@end

@implementation ZCYLabel

@synthesize tintColor = _tintColor;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _alpha = 0;
    }
    return self;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _alpha = 1;
    } else {
        _alpha = 0;
    }
    [self setNeedsDisplay];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self setNeedsDisplay];
}

- (void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    _tintColor = [_tintColor colorWithAlphaComponent:alpha];
    [self setNeedsDisplay];
}

- (UIColor *)tintColor {
    return [_tintColor colorWithAlphaComponent:_alpha];
}

- (void)drawRect:(CGRect)rect {
    NSDictionary *attrs = @{
                            NSFontAttributeName : [UIFont systemFontOfSize:16]
                            };
    CGSize size = [self textSizeWithAttributes:attrs];
    CGFloat x = (rect.size.width - size.width) / 2;
    CGFloat y = (rect.size.height - size.height) / 2;
    
    CGRect frame = CGRectMake(x, y, size.width, size.height);
    
    [self.text drawInRect:frame
           withAttributes:@{
                            NSFontAttributeName : [UIFont systemFontOfSize:16]
                            }];
    
    if (self.selected || self.alpha > 0) {
        
        [self.text drawInRect:frame
               withAttributes:@{
                                NSForegroundColorAttributeName : self.tintColor,
                                NSFontAttributeName : [UIFont systemFontOfSize:16]
                                }
         ];
    }

}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize textSize = [self textSizeWithAttributes:@{
                                                     NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                     }];
    CGSize realSize = CGSizeMake(textSize.width + 16, size.height);
    return realSize;
}

- (CGSize)textSizeWithAttributes:(NSDictionary<NSString *, id> *)attrs {
    return [self.text sizeWithAttributes:attrs];
}

@end
