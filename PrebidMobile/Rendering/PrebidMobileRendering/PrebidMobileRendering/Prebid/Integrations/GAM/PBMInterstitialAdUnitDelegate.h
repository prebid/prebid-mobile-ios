//
//  PBMInterstitialAdUnitDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

@class InterstitialAdUnit;

NS_ASSUME_NONNULL_BEGIN

/*!
 * Protocol for interaction with the InterstitialAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@protocol PBMInterstitialAdUnitDelegate <NSObject>

@optional

/// Called when an ad is loaded and ready for display
- (void)interstitialDidReceiveAd:(InterstitialAdUnit *)interstitial;

/// Called when the load process fails to produce a viable ad
- (void)interstitial:(InterstitialAdUnit *)interstitial
didFailToReceiveAdWithError:(nullable NSError *)error;

/// Called when the interstitial view will be launched,  as a result of show() method.
- (void)interstitialWillPresentAd:(InterstitialAdUnit *)interstitial;

/// Called when the interstial is dismissed by the user
- (void)interstitialDidDismissAd:(InterstitialAdUnit *)interstitial;

/// Called when an ad causes the sdk to leave the app
- (void)interstitialWillLeaveApplication:(InterstitialAdUnit *)interstitial;

/// Called when user clicked the ad
- (void)interstitialDidClickAd:(InterstitialAdUnit *)interstitial;

@end

NS_ASSUME_NONNULL_END
