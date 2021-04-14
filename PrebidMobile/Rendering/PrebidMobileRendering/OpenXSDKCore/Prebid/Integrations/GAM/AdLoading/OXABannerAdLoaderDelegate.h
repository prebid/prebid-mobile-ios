//
//  OXABannerAdLoaderDelegate.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OXABannerAdLoader;
@class OXADisplayView;
@protocol OXABannerEventHandler;

NS_ASSUME_NONNULL_BEGIN

@protocol OXABannerAdLoaderDelegate <NSObject>

@property (nonatomic, strong, nullable, readonly) id<OXABannerEventHandler> eventHandler;

// Loading callbacks
- (void)bannerAdLoader:(OXABannerAdLoader *)bannerAdLoader loadedAdView:(UIView *)adView adSize:(CGSize)adSize;

// Hook to insert interaction delegate
- (void)bannerAdLoader:(OXABannerAdLoader *)bannerAdLoader createdDisplayView:(OXADisplayView *)displayView;

@end

NS_ASSUME_NONNULL_END
