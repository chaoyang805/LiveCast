//
//  JKBannerView.h
//  Banner
//
//  Created by chaoyang805 on 2016/12/21.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

@class ZCYBannerView;

@protocol ZCYBannerItemType <NSObject>

@property (nonatomic, readonly) UIImage *bannerImage;

@end

@protocol ZCYBannerViewDelegate <NSObject>

- (void)bannerView:(ZCYBannerView *)bannerView tappedAtIndex:(NSUInteger)index;

@end

@interface ZCYBannerView : UIView <UIScrollViewDelegate>

@property (nonatomic, readwrite, copy) NSArray<UIImage *> *bannerItems;
@property (nonatomic, readonly, assign) NSUInteger count;
@property (nonatomic, readonly, assign) NSUInteger currentPage;
@property (nonatomic, readwrite, assign) BOOL pageControlEnabled;
@property (nonatomic, readwrite, assign) BOOL autoScrollEnabled;
@property (nonatomic, assign) NSTimeInterval autoScrollTimeInterval;
@property (nonatomic, weak) id<ZCYBannerViewDelegate> delegate;

//- (instancetype)initWithImagesNamed:(NSArray<NSString *> *)names frame:(CGRect)frame;
- (instancetype)initWithBannerItems:(NSArray<UIImage *> *)bannerItems frame:(CGRect)frame;

@end
