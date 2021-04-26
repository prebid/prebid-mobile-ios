//
//  PBMNativeAd.h
//  OpenXApolloSDK
//
//  Copyright © 2020 OpenX. All rights reserved.
//

@import UIKit;

#import "PBMNativeAdTrackingDelegate.h"
#import "PBMNativeAdUIDelegate.h"

#import "PBMNativeAdData.h"
#import "PBMNativeAdEventTracker.h"
#import "PBMNativeAdImage.h"
#import "PBMNativeAdTitle.h"
#import "PBMNativeAdVideo.h"

#import "PBMDataAssetType.h"
#import "PBMImageAssetType.h"

#import "PBMNativeAdElementType.h"

NS_ASSUME_NONNULL_BEGIN

@interface PBMNativeAd : NSObject

@property (atomic, weak, nullable) id<PBMNativeAdUIDelegate> uiDelegate;
@property (atomic, weak, nullable) id<PBMNativeAdTrackingDelegate> trackingDelegate;

// MARK: - Root properties
@property (nonatomic, strong, readonly) NSString *version;

// MARK: - Convenience getters
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *iconURL;
@property (nonatomic, strong, readonly) NSString *imageURL;
@property (nonatomic, strong, nullable, readonly) PBMNativeAdVideo *videoAd;
@property (nonatomic, strong, readonly) NSString *callToAction;

// MARK: - Array getters
@property (nonatomic, strong, readonly) NSArray<PBMNativeAdData *> *dataObjects;
@property (nonatomic, strong, readonly) NSArray<PBMNativeAdImage *> *images;
@property (nonatomic, strong, readonly) NSArray<PBMNativeAdTitle *> *titles;
@property (nonatomic, strong, readonly) NSArray<PBMNativeAdVideo *> *videoAds;

@property (nonatomic, strong, readonly) NSArray<NSString *> *imptrackers;

// MARK: - Filtered array getters
- (NSArray<PBMNativeAdData *> *)dataObjectsOfType:(PBMDataAssetType)dataType;
- (NSArray<PBMNativeAdImage *> *)imagesOfType:(PBMImageAssetType)imageType;

// MARK: - Overrides
- (instancetype)init NS_UNAVAILABLE;

// MARK: - View handling
- (void)registerView:(UIView *)adView clickableViews:(nullable NSArray<UIView *> *)clickableViews;
- (void)registerClickView:(UIView *)adView nativeAdElementType:(PBMNativeAdElementType)nativeAdElementType;
- (void)registerClickView:(UIView *)adView nativeAdAsset:(PBMNativeAdAsset *)nativeAdAsset;

@end

NS_ASSUME_NONNULL_END
