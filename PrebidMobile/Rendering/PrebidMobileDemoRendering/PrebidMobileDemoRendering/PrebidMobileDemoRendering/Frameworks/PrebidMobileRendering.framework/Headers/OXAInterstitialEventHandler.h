//
//  OXAInterstitialEventHandler.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "OXABidResponse.h"
#import "OXAInterstitialEventLoadingDelegate.h"
#import "OXAInterstitialEventInteractionDelegate.h"
#import "OXAPrimaryAdRequesterProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OXAInterstitialEventHandler <OXAPrimaryAdRequesterProtocol>

@required

/// Delegate for custom event handler to inform the OXA SDK about the events related to the ad server communication.
@property (nonatomic, weak, nullable) id<OXAInterstitialEventLoadingDelegate> loadingDelegate;

/// Delegate for custom event handler to inform the OXA SDK about the events related to the user's interaction with the ad.
@property (nonatomic, weak, nullable) id<OXAInterstitialEventInteractionDelegate> interactionDelegate;

/*!
 @abstract Return whether an interstitial is ready for display
 */
@property (nonatomic, readonly) BOOL isReady;

/*!
 @abstract OXA SDK calls this method to show the interstitial ad from the ad server SDK
 @param controller view controller to be used for presenting the interstitial ad
*/
- (void)showFromViewController:(nullable UIViewController *)controller;

@optional

/*!
  @abstract Called by OXA SDK to notify primary ad server.
 */
- (void)trackImpression;

@end

NS_ASSUME_NONNULL_END
