//
//  OXANativeAd.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "OXANativeAdTrackingDelegate.h"
#import "OXANativeAdUIDelegate.h"

#import "OXANativeAdData.h"
#import "OXANativeAdEventTracker.h"
#import "OXANativeAdImage.h"
#import "OXANativeAdTitle.h"
#import "OXANativeAdVideo.h"

#import "OXADataAssetType.h"
#import "OXAImageAssetType.h"

#import "OXANativeAdElementType.h"

NS_ASSUME_NONNULL_BEGIN

@interface OXANativeAd : NSObject

@property (atomic, weak, nullable) id<OXANativeAdUIDelegate> uiDelegate;
@property (atomic, weak, nullable) id<OXANativeAdTrackingDelegate> trackingDelegate;

// MARK: - Root properties
@property (nonatomic, strong, readonly) NSString *version;

// MARK: - Convenience getters
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *iconURL;
@property (nonatomic, strong, readonly) NSString *imageURL;
@property (nonatomic, strong, nullable, readonly) OXANativeAdVideo *videoAd;
@property (nonatomic, strong, readonly) NSString *callToAction;

// MARK: - Array getters
@property (nonatomic, strong, readonly) NSArray<OXANativeAdData *> *dataObjects;
@property (nonatomic, strong, readonly) NSArray<OXANativeAdImage *> *images;
@property (nonatomic, strong, readonly) NSArray<OXANativeAdTitle *> *titles;
@property (nonatomic, strong, readonly) NSArray<OXANativeAdVideo *> *videoAds;

@property (nonatomic, strong, readonly) NSArray<NSString *> *imptrackers;

// MARK: - Filtered array getters
- (NSArray<OXANativeAdData *> *)dataObjectsOfType:(OXADataAssetType)dataType;
- (NSArray<OXANativeAdImage *> *)imagesOfType:(OXAImageAssetType)imageType;

// MARK: - Overrides
- (instancetype)init NS_UNAVAILABLE;

// MARK: - View handling
- (void)registerView:(UIView *)adView clickableViews:(nullable NSArray<UIView *> *)clickableViews;
- (void)registerClickView:(UIView *)adView nativeAdElementType:(OXANativeAdElementType)nativeAdElementType;
- (void)registerClickView:(UIView *)adView nativeAdAsset:(OXANativeAdAsset *)nativeAdAsset;

@end

NS_ASSUME_NONNULL_END
