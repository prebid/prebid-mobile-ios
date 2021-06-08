//
//  RewardedEventLoadingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol RewardedEventLoadingDelegate : InterstitialEventLoadingDelegate {

    /*!
     @abstract The reward to be given to the user. May be assigned on successful loading.
     */
    weak var reward: NSObject? { get set }
}
