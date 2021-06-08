//
//  InterstitialControllerLoadingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol InterstitialControllerLoadingDelegate where Self: NSObject {

    func interstitialControllerDidLoadAd(_ interstitialController: InterstitialController)
    func interstitialController(_ interstitialController: InterstitialController,
                                didFailWithError error: Error)
}
