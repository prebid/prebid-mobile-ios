//
//  RewardedAdUnitDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

/*!
 * Protocol for interaction with the PBMRewardedAdUnit .
 *
 * All messages will be invoked on the main thread.
 */
@objc public protocol RewardedAdUnitDelegate where Self: NSObject {

    /// Called when an ad is loaded and ready for display
    @objc optional func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit)

    /// Called when user is able to receive a reward from the app
    @objc optional func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit)
    
    /// Called when the load process fails to produce a viable ad
    @objc optional func rewardedAd(_ rewardedAd: RewardedAdUnit,
                                   didFailToReceiveAdWithError error: Error?)

    /// Called when the interstitial view will be launched,  as a result of show() method.
    @objc optional func rewardedAdWillPresentAd(_ rewardedAd: RewardedAdUnit)

    /// Called when the interstial is dismissed by the user
    @objc optional func rewardedAdDidDismissAd(_ rewardedAd: RewardedAdUnit)

    /// Called when an ad causes the sdk to leave the app
    @objc optional func rewardedAdWillLeaveApplication(_ rewardedAd: RewardedAdUnit)

    /// Called when user clicked the ad
    @objc optional func rewardedAdDidClickAd(_ rewardedAd: RewardedAdUnit)
}
