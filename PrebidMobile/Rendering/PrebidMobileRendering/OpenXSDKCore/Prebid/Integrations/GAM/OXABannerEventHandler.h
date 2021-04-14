//
//  OXABannerEventHandler.h
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OXAPrimaryAdRequesterProtocol.h"

#import "OXABannerEventLoadingDelegate.h"
#import "OXABannerEventInteractionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OXABannerEventHandler <OXAPrimaryAdRequesterProtocol>

@required

/// Delegate for custom event handler to inform the OXA SDK about the events related to the ad server communication.
@property (nonatomic, weak, readwrite, nullable) id<OXABannerEventLoadingDelegate> loadingDelegate;

/// Delegate for custom event handler to inform the OXA SDK about the events related to the user's interaction with the ad.
@property (nonatomic, weak, readwrite, nullable) id<OXABannerEventInteractionDelegate> interactionDelegate;

/// The array of the CGRect entries for each valid ad sizes.
/// The first size is treated as a frame for related ad unit.
@property (nonatomic, strong, readonly, nonnull) NSArray<NSValue *> *adSizes;

@property (nonatomic, assign, readonly) BOOL isCreativeRequiredForNativeAds;

@optional

/*!
  @abstract Called by OXA SDK to notify primary ad server.
 */
- (void)trackImpression;

@end

NS_ASSUME_NONNULL_END
