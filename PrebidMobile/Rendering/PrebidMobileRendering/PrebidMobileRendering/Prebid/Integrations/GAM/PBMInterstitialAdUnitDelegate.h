//
//  PBMInterstitialAdUnitDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

@class PBMInterstitialAdUnit;

NS_ASSUME_NONNULL_BEGIN

/*!
 * Protocol for interaction with the PBMInterstitialAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@protocol PBMInterstitialAdUnitDelegate <NSObject>

@optional

/// Called when an ad is loaded and ready for display
- (void)interstitialDidReceiveAd:(PBMInterstitialAdUnit *)interstitial;

/// Called when the load process fails to produce a viable ad
- (void)interstitial:(PBMInterstitialAdUnit *)interstitial
didFailToReceiveAdWithError:(nullable NSError *)error;

/// Called when the interstitial view will be launched,  as a result of show() method.
- (void)interstitialWillPresentAd:(PBMInterstitialAdUnit *)interstitial;

/// Called when the interstial is dismissed by the user
- (void)interstitialDidDismissAd:(PBMInterstitialAdUnit *)interstitial;

/// Called when an ad causes the sdk to leave the app
- (void)interstitialWillLeaveApplication:(PBMInterstitialAdUnit *)interstitial;

/// Called when user clicked the ad
- (void)interstitialDidClickAd:(PBMInterstitialAdUnit *)interstitial;

@end

NS_ASSUME_NONNULL_END
