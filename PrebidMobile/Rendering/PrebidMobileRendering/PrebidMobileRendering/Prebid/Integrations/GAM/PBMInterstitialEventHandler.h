//
//  PBMInterstitialEventHandler.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "PBMBidResponse.h"
#import "PBMInterstitialEventLoadingDelegate.h"
#import "PBMInterstitialEventInteractionDelegate.h"
#import "PBMPrimaryAdRequesterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PBMInterstitialAd <PBMPrimaryAdRequesterProtocol>

@required

/*!
 @abstract Return whether an interstitial is ready for display
 */
@property (nonatomic, readonly) BOOL isReady;

/*!
 @abstract PBM SDK calls this method to show the interstitial ad from the ad server SDK
 @param controller view controller to be used for presenting the interstitial ad
*/
- (void)showFromViewController:(nullable UIViewController *)controller;

@optional

/*!
  @abstract Called by PBM SDK to notify primary ad server.
 */
- (void)trackImpression;

@end

@protocol PBMInterstitialEventHandler <PBMInterstitialAd>

@required

/// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
@property (nonatomic, weak, nullable) id<PBMInterstitialEventLoadingDelegate> loadingDelegate;

/// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
@property (nonatomic, weak, nullable) id<PBMInterstitialEventInteractionDelegate> interactionDelegate;

@end

NS_ASSUME_NONNULL_END
