//
//  ZCYLiveItemLargeCell.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/11.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

extern NSString * const ZCYLiveItemLargeCellIdentifier;
extern NSString * const ZCYLiveItemLargeCellNibName;
@interface ZCYLiveItemLargeCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *liveCoverImage;
@property (weak, nonatomic) IBOutlet UILabel *onlineCount;
@property (weak, nonatomic) IBOutlet UILabel *hostNickName;
@property (weak, nonatomic) IBOutlet UILabel *hostCity;

@end
