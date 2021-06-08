//
//  BaseInterstitialAdUnitProtocol.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol BaseInterstitialAdUnitProtocol where Self : NSObject {

    @objc func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController)

    @objc func callDelegate_didReceiveAd()
    @objc func callDelegate_didFailToReceiveAd(with error: Error?)
    @objc func callDelegate_willPresentAd()
    @objc func callDelegate_didDismissAd()
    @objc func callDelegate_willLeaveApplication()
    @objc func callDelegate_didClickAd()

    @objc func callEventHandler_isReady() -> Bool
    @objc func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?)
    @objc func callEventHandler_setInteractionDelegate()
    @objc func callEventHandler_requestAd(with bidResponse: BidResponse?)
    @objc func callEventHandler_show(from controller: UIViewController?)
    @objc func callEventHandler_trackImpression()
}
