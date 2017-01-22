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
#import "ZCYMineHeaderView.h"
#import "UIButton+BadgeDot.h"
#import "ZCYMineViewModel.h"

@interface ZCYMineViewController ()

@property (nonatomic, strong) IBOutlet ZCYMineHeaderView *headerView;
@property (weak, nonatomic) IBOutlet ZCYUserLevelInfoView *levelInfoView;
@property (weak, nonatomic) IBOutlet ZCYUserBalanceInfoView *balanceInfoView;
@property (nonatomic, copy) NSArray<NSArray<ZCYSettingItem *> *> *sectionInfo;
@property (nonatomic, strong) ZCYMineViewModel *viewModel;

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
    
    [self.headerView.myTasksButton zcy_showBadgeDot];
    [self.headerView.payButton zcy_showBadgeDot];
    [self.headerView.siteMessageButton zcy_showBadgeDot];
    [self.headerView.visitHistoryButton zcy_showBadgeDot];
    [self.headerView.visitHistoryButton zcy_hideBadgeDot];
    
    self.levelInfoView.levelupProgress = 0.5;
    self.levelInfoView.currentLevel = 2;
    self.balanceInfoView.yuchiCount = 102.1;
    self.balanceInfoView.yuwanCount = 222;
}

- (ZCYMineViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZCYMineViewModel alloc] init];
    }
    return _viewModel;
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
    return [self.viewModel sectionCount];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel itemsCountInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZCYSettingTableViewCell *cell = (ZCYSettingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ZCYSettingTableViewCellIdentifier forIndexPath:indexPath];
    ZCYMineViewModel *viewModel = self.viewModel;
    if (cell) {
        
        cell.textLabel.text = [viewModel settingTitleAtIndexPath:indexPath];
        cell.imageView.image = [viewModel settingIconAtIndexPath:indexPath];
        cell.extraInfoLabel.hidden = ![viewModel hasUnreadItemAtIndex:indexPath];
        cell.extraInfoLabel.text = [viewModel extraInfoAtIndexPath:indexPath];
        cell.hasUnreadItem = [viewModel hasUnreadItemAtIndex:indexPath];

    }
    return cell;
}
#pragma mark UITableViewControllerDelegate

@end
