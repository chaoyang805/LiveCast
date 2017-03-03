//
//  ZCYRecommendViewController.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/1/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYRecommendViewController.h"
#import "ZCYLiveItemLargeCell.h"
#import "ZCYLiveItemCell.h"
#import "ZCYLiveItemSectionHeader.h"
#import "UIColor+HexStringColor.h"
#import "UITabBar+BadgeDot.h"
#import "ZCYRecommendViewModel.h"
#import "DYLiveItemInfo.h"

static NSString * const kSectionFooterIdentifier = @"ZCYLiveItemSectionFooter";
@interface ZCYRecommendViewController ()

@property (nonatomic, strong) ZCYRecommendViewModel *viewModel;
@property (nonatomic, strong) ZCYRecommendTopHeader *topHeaderView;

@end

@implementation ZCYRecommendViewController {
    UIColor * _footerBgColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _footerBgColor = [UIColor colorWithHexString:@"0xEAEAEA"];
    [self setupCollectionView];
    [self.tabBarController.tabBar showBadgeDotAtIndex:0];
    [self.viewModel fetchRecommendPageData];  
}

- (ZCYRecommendViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [ZCYRecommendViewModel new];

        weakify(self);
        _viewModel.slideSelectedBlock = ^(DYLiveItemInfo *liveItem) {
            strongify(self);
            if (self) {
                // TODO detailVC
            }
        };
        
        _viewModel.dataLoadedCallback = ^{
            strongify(self);
            [self reloadData];
        };
        
        _viewModel.topHeaderClickCallback = ^(ZCYTopHeaderButtonType buttonType) {
        };
    }
    return _viewModel;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)setupCollectionView {
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(104, 0, 49, 0);
    UINib *nib = [UINib nibWithNibName:ZCYLiveItemLargeCellNibName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:ZCYLiveItemLargeCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:ZCYLiveItemCellNibName bundle:nil] forCellWithReuseIdentifier:ZCYLiveItemCellIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:ZCYLiveItemSectionHeaderNibName bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ZCYLiveItemSectionHeaderIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kSectionFooterIdentifier];
    
    [self.collectionView registerNib:[UINib nibWithNibName:ZCYRecommendTopHeaderNibName bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ZCYRecommendTopHeaderIdentifier];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.viewModel.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel numberOfItemsInSection:section];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        
        if (indexPath.section == 0) {
            [self.viewModel bindTopHeader:self.topHeaderView];
            return self.topHeaderView;
        } else {
            return [self initializeSectionHeaderForCollection:collectionView atIndexPath:indexPath];
        }
    } else  {
        
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kSectionFooterIdentifier forIndexPath:indexPath];
        footer.backgroundColor = _footerBgColor;
        return footer;
    }
}

- (ZCYRecommendTopHeader *)topHeaderView {
    if (!_topHeaderView) {
        _topHeaderView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ZCYRecommendTopHeaderIdentifier forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    return _topHeaderView;
}

- (ZCYLiveItemSectionHeader *)initializeSectionHeaderForCollection:(UICollectionView *)cv
                                                       atIndexPath:(NSIndexPath *)ip {
    ZCYLiveItemSectionHeader *sectionHeader =
    [cv dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                           withReuseIdentifier:ZCYLiveItemSectionHeaderIdentifier
                                  forIndexPath:ip];
    [self.viewModel bindSectionHeader:sectionHeader atSection:ip.section];
    
    sectionHeader.clickCallback = ^(ZCYLiveItemSectionHeader *header) {
        NSLog(@"clicked sectionHeader %@", header);
    };
    return sectionHeader;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == self.collectionView.numberOfSections - 1) {
        return CGSizeZero;
    }
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        CGFloat width = CGRectGetWidth(self.collectionView.bounds);
        CGFloat height = width / 375.f * 237.f;
        return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), height);
    }
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), 38);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.section == 2) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZCYLiveItemLargeCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZCYLiveItemCellIdentifier forIndexPath:indexPath];
    }
    [self.viewModel bindCell:cell atIndexPath:indexPath];
    return cell;
    
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat cellWidth = (width - 15) / 2;
    CGFloat cellHeight = 0;
    if (indexPath.section == 2) {
        cellHeight = cellWidth / 180.0f * 216.0f;
    } else {
        cellHeight = cellWidth / 180.0f * 145.0f;
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select:%@", indexPath);
}

@end
