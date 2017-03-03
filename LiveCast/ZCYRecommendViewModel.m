//
//  ZCYRecommendViewModel.m
//  LiveCast
//
//  Created by chaoyang805 on 2017/2/13.
//  Copyright © 2017年 jikexueyuan. All rights reserved.
//

#import "ZCYRecommendViewModel.h"
#import "ZCYImageLoader.h"
#import "UIImageView+RoundedCorner.h"


static dispatch_queue_t image_background_download_queue() {
    static dispatch_queue_t _image_background_download_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _image_background_download_queue = dispatch_queue_create("me.chaoyang805.recommend.viewmodel.processing", DISPATCH_QUEUE_SERIAL);
    });
    return _image_background_download_queue;
}

static dispatch_group_t image_download_group() {
    static dispatch_group_t _image_download_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _image_download_group = dispatch_group_create();
    });
    return _image_download_group;
}

static dispatch_group_t data_load_group() {
    static dispatch_group_t _data_load_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _data_load_group = dispatch_group_create();
    });
    return _data_load_group;
}

static const NSUInteger sectionIndexTopHeader = 0;
static const NSUInteger sectionIndexPopularRooms = 1;
static const NSUInteger sectionIndexVerticalRooms = 2;

static NSString * const sectionYanzhiTitle = @"颜值";
static NSString * const sectionHotTitle = @"热门";

@interface ZCYRecommendViewModel ()

@property (nonatomic, strong) NSArray<DYLiveItemInfo *> *slideData;
@property (nonatomic, strong) NSArray<DYLiveRoom *> *verticalRoomList;
@property (nonatomic, strong) NSArray<DYLiveRoomSection *> *roomListOfSection;
@property (nonatomic, strong) NSArray<DYLiveRoom *> *popularRooms;
@property (readwrite, nonatomic, assign) NSUInteger numberOfSections;

@end

@implementation ZCYRecommendViewModel

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (DYRecommendAPI *)recommendAPI {
    if (!_recommendAPI) {
        _recommendAPI = [[DYRecommendAPI alloc] init];
    }
    return _recommendAPI;
}

- (void)fetchRecommendPageData {
    
    // fetchSlideData
    weakify(self);
    dispatch_group_t dataLoadGroup = data_load_group();
    
    dispatch_group_enter(dataLoadGroup);
    [self.recommendAPI getHeaderSlideData:^(NSArray<DYLiveItemInfo *> *slideData, NSError *error) {
        if (slideData) {
            strongify(self);
            self.slideData = slideData;
        }
        NSLog(@"%@", NSStringFromSelector(_cmd));
        dispatch_group_leave(dataLoadGroup);
    }];
    
    dispatch_group_enter(dataLoadGroup);
    [self.recommendAPI getHotCategoryWithCompletionHandler:^(id responseObject, NSError *error) {
        if (responseObject) {
            strongify(self);
            self.roomListOfSection = [[responseObject valueForKey:@"data"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"roomList.@count > %d", 0]];
        }
        NSLog(@"%@", NSStringFromSelector(_cmd));
        dispatch_group_leave(dataLoadGroup);
    }];
    
    dispatch_group_enter(dataLoadGroup);
    [self.recommendAPI getVerticalRoomListWithLimit:4 fromOffset:0 completionHandler:^(id responseObject, NSError *error) {
        if (responseObject) {
            strongify(self);
            self.verticalRoomList = [responseObject valueForKey:@"data"];
        }
        NSLog(@"%@", NSStringFromSelector(_cmd));
        dispatch_group_leave(dataLoadGroup);
    }];
    
    dispatch_group_enter(dataLoadGroup);
    [self.recommendAPI getBigDataRoomWithCompletionHandler:^(id responseObject, NSError *error) {
        
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            strongify(self);
            self.popularRooms = responseObject[@"data"];
        }
        dispatch_group_leave(dataLoadGroup);
    }];
    
    
    dispatch_group_notify(dataLoadGroup, dispatch_get_main_queue(), ^{
        safelyCallBlock(self.dataLoadedCallback);
    });
}

- (void)showSlideData:(NSArray *)slideData {
    
    if (!slideData || slideData.count <= 0) {
        return;
    }
    self.slideUpdateBlock(slideData);
}

// dataSource
- (NSUInteger)numberOfSections {
    NSUInteger roomListOfSection = 0;
    if (self.roomListOfSection) {
        roomListOfSection = self.roomListOfSection.count;
    }
    if (self.verticalRoomList.count > 0) {
        roomListOfSection += 1;
    }
    if (self.popularRooms.count > 0) {
        roomListOfSection += 1;
    }
    if (self.slideData) {
        roomListOfSection += 1;
    }
    return roomListOfSection;
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section {
    // popular section index
    switch (section) {
        case sectionIndexTopHeader:
            return 0;
        case sectionIndexPopularRooms:
            return self.popularRooms.count;
        case sectionIndexVerticalRooms:
            return self.verticalRoomList.count;
        default:
            return self.roomListOfSection[section - 3].roomList.count;
    }
}

#pragma mark - BindCell

- (void)bindCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case sectionIndexTopHeader: {
            NSLog(@"TopHeader has none cells to bind.");
            break;
        }
        case sectionIndexPopularRooms: {
            if ([cell isKindOfClass:[ZCYLiveItemCell class]]) {
                [self bindPopularCell:(ZCYLiveItemCell *)cell forItem:indexPath.item];
            } else {
                NSLog(@"wrong cell for indexPath:%@", indexPath);
            }
            break;
        }
        case sectionIndexVerticalRooms: {
            if ([cell isKindOfClass:[ZCYLiveItemLargeCell class]]) {
                [self bindVerticalCell:(ZCYLiveItemLargeCell *)cell forItem:indexPath.item];
            } else {
                NSLog(@"wrong cell for indexPath:%@", indexPath);
            }
            break;
        }
        default: {
            if ([cell isKindOfClass:[ZCYLiveItemCell class]]) {
                [self bindListRoomsCell:(ZCYLiveItemCell *)cell forIndexPath:indexPath];
            } else {
                NSLog(@"wrong cell for indexPath:%@", indexPath);
            }
            break;
        }
    }
}

- (void)bindPopularCell:(ZCYLiveItemCell *)cell forItem:(NSUInteger)item {
    DYLiveRoom *roomInfo = self.popularRooms[item];
    if (!roomInfo) {
        NSAssert(NO, @"not found roomInfo for item %lu", item);
    }
    [self bindNormalCell:cell withRoomInfo:roomInfo];
}

- (void)bindVerticalCell:(ZCYLiveItemLargeCell *)cell forItem:(NSUInteger)item {
    DYLiveRoom *roomInfo = self.verticalRoomList[item];
    if (!roomInfo) {
        NSAssert(NO, @"not found roomInfo for item %lu", item);
    }
    cell.hostNickName.text =  roomInfo.nickname;
    cell.hostCity.text = roomInfo.anchorCity;
    cell.onlineCount.text = [self formattedOnlineText:roomInfo.online];
    [cell.liveCoverImage zcy_setImageWithURL:[NSURL URLWithString:roomInfo.verticalSrc]];
}

- (void)bindListRoomsCell:(ZCYLiveItemCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    DYLiveRoomSection *sectionData = self.roomListOfSection[indexPath.section - 3];
    DYLiveRoom *roomInfo = sectionData.roomList[indexPath.item];
    [self bindNormalCell:cell withRoomInfo:roomInfo];
}

- (void)bindNormalCell:(ZCYLiveItemCell *)cell withRoomInfo:(DYLiveRoom *)roomInfo {
    cell.liveTitle.text = roomInfo.roomName;
    cell.onlineCount.text = [self formattedOnlineText:roomInfo.online];
    cell.hostNickName.text = roomInfo.nickname;
    [cell.liveCoverImage zcy_setImageWithURL:[NSURL URLWithString:roomInfo.verticalSrc]];
}

- (NSString *)formattedOnlineText:(NSUInteger)onlineCount {
    if (onlineCount < 10000) {
        return [NSString stringWithFormat:@"%lu", (unsigned long)onlineCount];
    } else {
        CGFloat count = onlineCount / 10000.0f;
        return [NSString stringWithFormat:@"%.1f万", count];
    }
}

#pragma mark - BindHeader

- (void)bindTopHeader:(ZCYRecommendTopHeader *)headerView {
    NSMutableArray *mutableSlideImages = [NSMutableArray arrayWithCapacity:self.slideData.count];
    
    for (DYLiveItemInfo *liveItem in self.slideData) {
        dispatch_group_async(image_download_group(), image_background_download_queue(), ^{
            
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:liveItem.picUrl]]];
            [mutableSlideImages addObject:image];
        });
    }
    dispatch_group_notify(image_download_group(), dispatch_get_main_queue(), ^{
        headerView.bannerView.bannerItems = [NSArray arrayWithArray:mutableSlideImages];
    });
}

- (void)bindSectionHeader:(ZCYLiveItemSectionHeader *)sectionHeader
                atSection:(NSUInteger)section {
    switch (section) {
        case sectionIndexTopHeader:
            break;
        case sectionIndexPopularRooms: {
            sectionHeader.sectionTitle.text = sectionHotTitle;
            sectionHeader.sectionIcon.image = [UIImage imageNamed:@"columnHotIcon"];
            break;
        }
        case sectionIndexVerticalRooms: {
            sectionHeader.sectionTitle.text = sectionYanzhiTitle;
            sectionHeader.sectionIcon.image = [UIImage imageNamed:@"columnYanzhiIcon"];
            break;
        }
        default: {
            sectionHeader.sectionTitle.text = self.roomListOfSection[section - 3].tagName;
            sectionHeader.sectionIcon.image = [UIImage imageNamed:@"home_header_normal"];
            break;
        }
    }
    
}

#pragma mark - ZCYBannerViewDelegate

- (void)bannerView:(ZCYBannerView *)bannerView tappedAtIndex:(NSUInteger)index {
    if (index > self.slideData.count) {
        return;
    }
    safelyCallBlock(self.slideSelectedBlock, self.slideData[index]);
}

#pragma mark - ZCYRecommendTopHeaderDelegate

- (void)topHeader:(ZCYRecommendTopHeader *)topHeader buttonTappedWithButtonType:(ZCYTopHeaderButtonType)buttonType {
    safelyCallBlock(self.topHeaderClickCallback, buttonType);
}



@end
