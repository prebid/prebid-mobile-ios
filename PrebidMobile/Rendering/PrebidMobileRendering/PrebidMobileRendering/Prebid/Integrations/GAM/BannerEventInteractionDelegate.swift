//
//  BannerEventInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

/*!
 The banner custom event delegate. It is used to inform the ad server SDK events back to the PBM SDK.
 */
@objc public protocol BannerEventInteractionDelegate where Self : NSObject {

    /*!
     @abstract Call this when the ad server SDK is about to present a modal
     */
    func willPresentModal()

    /*!
     @abstract Call this when the ad server SDK dissmisses a modal
     */
    func didDismissModal()

    /*!
     @abstract Call this when the ad server SDK informs about app leave event as a result of user interaction.
     */
    func willLeaveApp()

    /*!
     @abstract Returns a view controller instance to be used by ad server SDK for showing modals
     @result a UIViewController instance for showing modals
     */
    var viewControllerForPresentingModal: UIViewController? { get }
}
