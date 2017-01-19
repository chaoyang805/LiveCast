//
//  ZCYLiveItemSectionHeader.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYLiveItemSectionHeader.h"

NSString * const ZCYLiveItemSectionHeaderIdentifier = @"ZCYLiveItemSectionHeader";
NSString * const ZCYLiveItemSectionHeaderNibName = @"ZCYLiveItemSectionHeader";

@interface ZCYLiveItemSectionHeader ()

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation ZCYLiveItemSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderClicked:)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)sectionHeaderClicked:(UITapGestureRecognizer *)sender {
    if (self.clickCallback) {
        self.clickCallback(self);
    }
}

@end
