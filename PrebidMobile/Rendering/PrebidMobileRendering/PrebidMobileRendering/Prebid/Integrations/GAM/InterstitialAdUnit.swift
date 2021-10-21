/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import UIKit

public class InterstitialAdUnit: BaseInterstitialAdUnit {

    @objc public init(configID: String) {
        super.init(configID: configID,
                   minSizePerc: nil,
                   eventHandler: InterstitialEventHandlerStandalone())
    }

    @objc public init(configID: String, minSizePercentage: CGSize) {
        super.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            eventHandler: InterstitialEventHandlerStandalone())
    }

    @objc public init(configID: String, minSizePercentage:CGSize, eventHandler: AnyObject) {
        super.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            eventHandler: eventHandler)
    }
    
    @objc required init(configID:String, minSizePerc: NSValue?, eventHandler:AnyObject?) {
        super.init(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: eventHandler)
    }
    
    // MARK: - Protected overrides

    @objc public override func callDelegate_didReceiveAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidReceiveAd?(self)
        }
    }
    
    @objc public override func callDelegate_didFailToReceiveAd(with error: Error?) {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitial?(self, didFailToReceiveAdWithError: error)
        }
    }

    @objc public override func callDelegate_willPresentAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialWillPresentAd?(self)
        }
    }

    @objc public override func callDelegate_didDismissAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidDismissAd?(self)
        }
    }

    @objc public override func callDelegate_willLeaveApplication() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialWillLeaveApplication?(self)
        }
    }

    @objc public override func callDelegate_didClickAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidClickAd?(self)
        }
    }
        
    @objc public override func callEventHandler_isReady() -> Bool {
        interstitialEventHandler?.isReady ?? false
    }

    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        interstitialEventHandler?.loadingDelegate = loadingDelegate as? RewardedEventLoadingDelegate
    }

    @objc public override func callEventHandler_setInteractionDelegate() {
        interstitialEventHandler?.interactionDelegate = self
    }

    @objc public override func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        interstitialEventHandler?.requestAd(with: bidResponse)
    }

    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        interstitialEventHandler?.show(from: controller)
    }

    @objc public override func callEventHandler_trackImpression() {
        interstitialEventHandler?.trackImpression?()
    }
    
    private var interstitialEventHandler: InterstitialEventHandlerProtocol?  {
        eventHandler as? InterstitialEventHandlerProtocol
    }
}
