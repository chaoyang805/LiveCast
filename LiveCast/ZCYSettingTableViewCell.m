//
//  ZCYSettingTableViewCell.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYSettingTableViewCell.h"
#import "UIButton+BadgeDot.h"
NSString * const ZCYSettingTableViewCellIdentifier = @"ZCYSettingCell";
@implementation ZCYSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.extraInfoLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-34];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.extraInfoLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    self.extraInfoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:@[trailing, centerY]];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.hasUnreadItem = NO;
    }
}
- (void)setHasUnreadItem:(BOOL)hasUnreadItem {
    _hasUnreadItem = hasUnreadItem;
    hasUnreadItem ? [self.extraInfoLabel zcy_showBadgeDot] : [self.extraInfoLabel zcy_hideBadgeDot];
}

@end
