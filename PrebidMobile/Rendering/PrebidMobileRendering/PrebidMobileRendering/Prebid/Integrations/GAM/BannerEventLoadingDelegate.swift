//
//  BannerEventLoadingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

/*!
 The banner custom event delegate. It is used to inform the ad server SDK events back to the PBM SDK.
 */
@objc public protocol BannerEventLoadingDelegate where Self: NSObject {

    /*!
     @abstract Call this when the ad server SDK signals about partner bid win
     */
    func prebidDidWin()

    /*!
     @abstract Call this when the ad server SDK renders its own ad
     @param view rendered ad view from the ad server SDK
     */
    func adServerDidWin(_ view: UIView, adSize:CGSize)

    /*!
     @abstract Call this when the ad server SDK fails to load the ad
     @param error detailed error object describing the cause of ad failure
    */
    func failedWithError(_ error: Error?)
}
