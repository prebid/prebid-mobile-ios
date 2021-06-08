//
//  InterstitialControllerInteractionDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol InterstitialControllerInteractionDelegate where Self : NSObject {

    func trackImpression(for interstitialController:InterstitialController)

    func interstitialControllerDidClickAd(_ interstitialController: InterstitialController)
    func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController)
    func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController)
    func interstitialControllerDidDisplay(_ interstitialController: InterstitialController)
    func interstitialControllerDidComplete(_ interstitialController: InterstitialController)

    func viewControllerForModalPresentation(from interstitialController: InterstitialController) -> UIViewController?
}
