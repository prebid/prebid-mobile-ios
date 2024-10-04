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

/// Represents an rewarded ad unit. Built for rendering type of integration.
@objc
public class RewardedAdUnit: BaseInterstitialAdUnit,
                             RewardedEventInteractionDelegate {
    // MARK: - Lifecycle
    
    @objc public convenience init(
        configID: String,
        eventHandler: AnyObject
    ) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            eventHandler: eventHandler
        )
    }

    /// Initializes a `RewardedAdUnit` with the given configuration ID and a default event handler.
    ///
    /// - Parameter configID: The configuration ID for the ad unit.
    @objc public convenience init(configID: String) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            eventHandler: RewardedEventHandlerStandalone()
        )
    }
    
    @objc required init(
        configID: String,
        minSizePerc: NSValue?,
        eventHandler: AnyObject?
    ) {
        super.init(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: eventHandler
        )
        
        adUnitConfig.adConfiguration.isRewarded = true
        adFormats = [.banner, .video]
    }
    
    // MARK: - RewardedEventDelegate
    
    @objc public func userDidEarnReward(_ reward: PrebidReward) {
        DispatchQueue.main.async {
            self.callDelegate_rewardedAdUserDidEarnReward(reward: reward)
        }
    }
    
    // MARK: - Protected overrides
    
    /// Called when the ad unit receives an ad.
    @objc public override func callDelegate_didReceiveAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdDidReceiveAd?(self)
        }
    }

    /// Called when the ad unit fails to receive an ad.
    ///
    /// - Parameter error: The error describing the failure.
    @objc public override func callDelegate_didFailToReceiveAd(with error: Error?) {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAd?(self, didFailToReceiveAdWithError: error)
        }
    }
    
    /// Called when the ad unit will present an ad.
    @objc public override func callDelegate_willPresentAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdWillPresentAd?(self)
        }
    }

    /// Called when the ad unit dismisses an ad.
    @objc public override func callDelegate_didDismissAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdDidDismissAd?(self)
        }
    }

    /// Called when the ad unit will leave the application.
    @objc public override func callDelegate_willLeaveApplication() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdWillLeaveApplication?(self)
        }
    }

    /// Called when the ad unit is clicked.
    @objc public override func callDelegate_didClickAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdDidClickAd?(self)
        }
    }
    
    /// Returns whether the event handler is ready.
    ///
    /// - Returns: A boolean indicating if the event handler is ready.
    @objc public override func callEventHandler_isReady() -> Bool {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            return eventHandler.isReady
        } else {
            return false
        }
    }

    /// Sets the loading delegate for the event handler.
    ///
    /// - Parameter loadingDelegate: The loading delegate to set.
    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.loadingDelegate = loadingDelegate as? RewardedEventLoadingDelegate
        }
    }

    /// Sets the interaction delegate for the event handler.
    @objc public override func callEventHandler_setInteractionDelegate() {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.interactionDelegate = self
        }
    }

    /// Requests an ad with the given bid response.
    ///
    /// - Parameter bidResponse: The bid response to use for the ad request.
    @objc public override func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.requestAd(with: bidResponse)
        }
    }

    /// Shows the ad from the specified view controller.
    ///
    /// - Parameter controller: The view controller from which to present the ad.
    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.show(from: controller)
        }
    }

    /// Tracks the impression for the ad.
    @objc public override func callEventHandler_trackImpression() {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.trackImpression?()
        }
    }
    
    // MARK: - Private helpers
    
    func callDelegate_rewardedAdUserDidEarnReward(reward: PrebidReward) {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdUserDidEarnReward?(self, reward: reward)
        }
    }
}
