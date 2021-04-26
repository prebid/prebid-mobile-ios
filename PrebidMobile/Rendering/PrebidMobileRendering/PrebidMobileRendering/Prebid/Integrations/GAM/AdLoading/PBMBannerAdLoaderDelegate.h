//
//  PBMBannerAdLoaderDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PBMBannerAdLoader;
@class PBMDisplayView;
@protocol PBMBannerEventHandler;

NS_ASSUME_NONNULL_BEGIN

@protocol PBMBannerAdLoaderDelegate <NSObject>

@property (nonatomic, strong, nullable, readonly) id<PBMBannerEventHandler> eventHandler;

// Loading callbacks
- (void)bannerAdLoader:(PBMBannerAdLoader *)bannerAdLoader loadedAdView:(UIView *)adView adSize:(CGSize)adSize;

// Hook to insert interaction delegate
- (void)bannerAdLoader:(PBMBannerAdLoader *)bannerAdLoader createdDisplayView:(PBMDisplayView *)displayView;

@end

NS_ASSUME_NONNULL_END
