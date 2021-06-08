//
//  RewardedEventInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol RewardedEventInteractionDelegate: InterstitialEventInteractionDelegate {

    /*!
     @abstract Call this when the ad server SDK decides the use has earned reward
     */
    func userDidEarnReward(_ reward: NSObject?)
}

