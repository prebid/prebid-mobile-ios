//
//  OXAInterstitialAdUnitDelegate.h
//  OpenXSDKCore
//
//  Copyright © 2020 OpenX. All rights reserved.
//
#import <Foundation/Foundation.h>

@class OXAInterstitialAdUnit;

NS_ASSUME_NONNULL_BEGIN

/*!
 * Protocol for interaction with the OXAInterstitialAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@protocol OXAInterstitialAdUnitDelegate <NSObject>

@optional

/// Called when an ad is loaded and ready for display
- (void)interstitialDidReceiveAd:(OXAInterstitialAdUnit *)interstitial;

/// Called when the load process fails to produce a viable ad
- (void)interstitial:(OXAInterstitialAdUnit *)interstitial
didFailToReceiveAdWithError:(nullable NSError *)error;

/// Called when the interstitial view will be launched,  as a result of show() method.
- (void)interstitialWillPresentAd:(OXAInterstitialAdUnit *)interstitial;

/// Called when the interstial is dismissed by the user
- (void)interstitialDidDismissAd:(OXAInterstitialAdUnit *)interstitial;

/// Called when an ad causes the sdk to leave the app
- (void)interstitialWillLeaveApplication:(OXAInterstitialAdUnit *)interstitial;

/// Called when user clicked the ad
- (void)interstitialDidClickAd:(OXAInterstitialAdUnit *)interstitial;

@end

NS_ASSUME_NONNULL_END
