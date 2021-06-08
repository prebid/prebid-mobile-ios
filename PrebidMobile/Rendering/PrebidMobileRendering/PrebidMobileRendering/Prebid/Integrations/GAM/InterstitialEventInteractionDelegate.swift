//
//  InterstitialEventInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol InterstitialEventInteractionDelegate where Self: NSObject {
    
    /*!
     @abstract Call this when the ad server SDK is about to present a modal
     */
    @objc func willPresentAd()

    /*!
     @abstract Call this when the ad server SDK dissmisses a modal
     */
    @objc func didDismissAd()

    /*!
     @abstract Call this when the ad server SDK informs about app leave event as a result of user interaction.
     */
    @objc func willLeaveApp()

    /*!
     @abstract Call this when the ad server SDK informs about click event as a result of user interaction.
     */
    @objc func didClickAd()
}
