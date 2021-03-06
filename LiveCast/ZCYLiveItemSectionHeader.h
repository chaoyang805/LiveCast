//
//  ZCYLiveItemSectionHeader.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//


extern NSString * const ZCYLiveItemSectionHeaderIdentifier;
extern NSString * const ZCYLiveItemSectionHeaderNibName;
@class ZCYLiveItemSectionHeader;

typedef void (^ZCYSectionHeaderClickCallback)(ZCYLiveItemSectionHeader *header);

@interface ZCYLiveItemSectionHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *sectionTitle;
@property (weak, nonatomic) IBOutlet UIImageView *sectionIcon;
@property (nonatomic, copy) ZCYSectionHeaderClickCallback clickCallback;

@end
