//
//  ZCYLiveItemCell.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/11.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ZCYLiveItemCellIdentifier;
extern NSString * const ZCYLiveItemCellNibName;

@interface ZCYLiveItemCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *liveCoverImage;
@property (nonatomic, weak) IBOutlet UIView *liveCountBgView;
@property (nonatomic, weak) IBOutlet UILabel *onlineCount;
@property (nonatomic, weak) IBOutlet UILabel *hostNickName;
@property (nonatomic, weak) IBOutlet UILabel *liveTitle;


@end
