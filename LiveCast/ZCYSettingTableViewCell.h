//
//  ZCYSettingTableViewCell.h
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/9.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ZCYSettingTableViewCellIdentifier;

@interface ZCYSettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *extraInfoLabel;
@property (assign, nonatomic) BOOL hasUnreadItem;

@end
