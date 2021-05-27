//
//  PBMBannerEventHandler.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PBMPrimaryAdRequesterProtocol.h"

#import "PBMBannerEventLoadingDelegate.h"
#import "PBMBannerEventInteractionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PBMBannerEventHandler <PBMPrimaryAdRequesterProtocol>

@required

/// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
@property (nonatomic, weak, readwrite, nullable) id<PBMBannerEventLoadingDelegate> loadingDelegate;

/// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
@property (nonatomic, weak, readwrite, nullable) id<PBMBannerEventInteractionDelegate> interactionDelegate;

/// The array of the CGRect entries for each valid ad sizes.
/// The first size is treated as a frame for related ad unit.
// TODO: make me CGSize on migration to Swift
@property (nonatomic, strong, readonly, nonnull) NSArray<NSValue *> *adSizes;

@property (nonatomic, assign, readonly) BOOL isCreativeRequiredForNativeAds;

@optional

/*!
  @abstract Called by PBM SDK to notify primary ad server.
 */
- (void)trackImpression;

@end

NS_ASSUME_NONNULL_END
