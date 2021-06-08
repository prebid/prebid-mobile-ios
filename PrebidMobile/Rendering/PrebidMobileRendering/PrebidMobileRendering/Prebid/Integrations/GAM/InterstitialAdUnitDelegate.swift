//
//  InterstitialAdUnitDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

/*!
 * Protocol for interaction with the InterstitialAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@objc public protocol InterstitialAdUnitDelegate where Self: NSObject {

    /// Called when an ad is loaded and ready for display
    @objc optional func interstitialDidReceiveAd(_ interstitial: InterstitialAdUnit)

    /// Called when the load process fails to produce a viable ad
    @objc optional func interstitial(_ interstitial: InterstitialAdUnit,
                                     didFailToReceiveAdWithError error:Error? )

    /// Called when the interstitial view will be launched,  as a result of show() method.
    @objc optional func interstitialWillPresentAd(_ interstitial: InterstitialAdUnit)

    /// Called when the interstitial is dismissed by the user
    @objc optional func interstitialDidDismissAd(_ interstitial: InterstitialAdUnit)

    /// Called when an ad causes the sdk to leave the app
    @objc optional func interstitialWillLeaveApplication(_ interstitial: InterstitialAdUnit)

    /// Called when user clicked the ad
    @objc optional func interstitialDidClickAd(_ interstitial: InterstitialAdUnit)
}
