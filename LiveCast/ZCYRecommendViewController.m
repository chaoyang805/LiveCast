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
#import "ZCYTopHeaderEventHandler.h"
#import "ZCYDemoBannerItem.h"
#import "UITabBar+BadgeDot.h"

static NSString * const kSectionFooterIdentifier = @"ZCYLiveItemSectionFooter";
@interface ZCYRecommendViewController ()

@property (nonatomic, strong) ZCYTopHeaderEventHandler *topHeaderHandler;

@end

@implementation ZCYRecommendViewController {
    UIColor * _footerBgColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _footerBgColor = [UIColor colorWithHexString:@"0xEAEAEA"];
    [self setupCollectionView];
    [self.tabBarController.tabBar showBadgeDotAtIndex:0];
    
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

- (ZCYTopHeaderEventHandler *)topHeaderHandler {
    if (!_topHeaderHandler) {
        _topHeaderHandler = [[ZCYTopHeaderEventHandler alloc] init];
    }
    return _topHeaderHandler;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 4;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        
        if (indexPath.section == 0) {
            ZCYRecommendTopHeader *topHeader =
            [self initializeTopHeaderViewForCollection:collectionView
                                        atIndexPath:indexPath];
            
            return topHeader;
        } else {
            return [self initializeSectionHeaderForCollection:collectionView atIndexPath:indexPath];
        }
        
    } else  {
        
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kSectionFooterIdentifier forIndexPath:indexPath];
        footer.backgroundColor = _footerBgColor;
        return footer;
    }
}

- (ZCYRecommendTopHeader *)initializeTopHeaderViewForCollection:(UICollectionView *)cv
                                                    atIndexPath:(NSIndexPath *)ip {
    ZCYRecommendTopHeader *topHeader =
    [cv dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                           withReuseIdentifier:ZCYRecommendTopHeaderIdentifier
                                  forIndexPath:ip];
    topHeader.delegate = self.topHeaderHandler;
    
    NSMutableArray *items = [NSMutableArray array];
    for (NSUInteger i = 0; i < 6; i++) {
        NSString *name = [NSString stringWithFormat:@"banner-%lu", i];
        ZCYDemoBannerItem *item = [[ZCYDemoBannerItem alloc] initWithImageName:name];
        [items addObject:item];
    }
    
    topHeader.bannerView.bannerItems = [items copy];
    topHeader.bannerView.delegate = self.topHeaderHandler;
    return topHeader;
}


- (ZCYLiveItemSectionHeader *)initializeSectionHeaderForCollection:(UICollectionView *)cv
                                                       atIndexPath:(NSIndexPath *)ip {
    ZCYLiveItemSectionHeader *sectionHeader =
    [cv dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                           withReuseIdentifier:ZCYLiveItemSectionHeaderIdentifier
                                  forIndexPath:ip];
    
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
    if (indexPath.section == 2) {
        ZCYLiveItemLargeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZCYLiveItemLargeCellIdentifier forIndexPath:indexPath];
        return cell;
    } else {
        
        ZCYLiveItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ZCYLiveItemCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
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
