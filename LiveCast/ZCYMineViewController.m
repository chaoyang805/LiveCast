//
//  ZCYMineViewController.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYMineViewController.h"
#import "ZCYDetailViewController.h"
#import "ZCYSettingItem.h"
#import "ZCYSettingTableViewCell.h"
#import "ZCYUserLevelInfoView.h"
#import "ZCYUserBalanceInfoView.h"

@interface ZCYMineViewController ()

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet ZCYUserLevelInfoView *levelInfoView;
@property (weak, nonatomic) IBOutlet ZCYUserBalanceInfoView *balanceInfoView;
@property (nonatomic, copy) NSArray<NSArray<ZCYSettingItem *> *> *sectionInfo;

@end

@implementation ZCYMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    [self.tableView registerNib:[UINib nibWithNibName:@"ZCYSettingTableViewCell" bundle:nil] forCellReuseIdentifier:ZCYSettingTableViewCellIdentifier];
    
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.tableHeaderView = self.headerView;
    
    self.levelInfoView.levelupProgress = 0.5;
    self.levelInfoView.currentLevel = 2;
    self.balanceInfoView.yuchiCount = 102.1;
    self.balanceInfoView.yuwanCount = 222;
    
    [self loadSectionInfo];
}

- (void)loadSectionInfo {
    ZCYSettingItem *item1 = [[ZCYSettingItem alloc] initWithTitle:@"主播招募" type:ZCYSettingItemTypeRecruitment];
    ZCYSettingItem *item2 = [[ZCYSettingItem alloc] initWithTitle:@"排行榜" type:ZCYSettingItemTypeRank];
    ZCYSettingItem *item3 = [[ZCYSettingItem alloc] initWithTitle:@"我的视频" type:ZCYSettingItemTypeMyVideo];
    ZCYSettingItem *item4 = [[ZCYSettingItem alloc] initWithTitle:@"视频收藏" type:ZCYSettingItemTypeVideoCollection];
    ZCYSettingItem *item5 = [[ZCYSettingItem alloc] initWithTitle:@"我的账户" type:ZCYSettingItemTypeMyAccount];
    ZCYSettingItem *item6 = [[ZCYSettingItem alloc] initWithTitle:@"游戏中心" type:ZCYSettingItemTypeGameCenter];
    item6.extraInfo = @"玩游戏领鱼丸";
    ZCYSettingItem *item7 = [[ZCYSettingItem alloc] initWithTitle:@"开播提醒" type:ZCYSettingItemTypeRemind];
    
    self.sectionInfo = @[
                         @[item1, item2],
                         @[item3, item4],
                         @[item5, item6],
                         @[item7]
                         ];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (IBAction)clickSetting:(id)sender {
    UIStoryboard *settingStoryBoard = [UIStoryboard storyboardWithName:@"ZCYSetting" bundle:nil];
    UITableViewController *settingTableVC = [settingStoryBoard instantiateInitialViewController];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingTableVC animated:YES];
    settingTableVC.navigationController.navigationBarHidden = NO;
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark UITableViewControllerDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionInfo ? self.sectionInfo.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *settingItemsForSection = self.sectionInfo[section];
    return settingItemsForSection ? settingItemsForSection.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZCYSettingTableViewCell *cell = (ZCYSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ZCYSettingTableViewCellIdentifier forIndexPath:indexPath];
    
    if (cell) {
        
        ZCYSettingItem *item = self.sectionInfo[indexPath.section][indexPath.row];
        cell.textLabel.text = item.settingTitle;
        cell.imageView.image = item.settingIcon;
        if (item.extraInfo) {
            cell.extraInfoLabel.hidden = NO;
            cell.extraInfoLabel.text = item.extraInfo;
        } else {
            cell.extraInfoLabel.hidden = YES;
        }
    } else {
        NSAssert(false, @"cell wrong");
    }
    return cell;
}

#pragma mark UITableViewControllerDelegate

@end
