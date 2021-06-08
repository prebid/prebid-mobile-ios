//
//  RewardedAdUnit.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import UIKit

public class RewardedAdUnit: BaseInterstitialAdUnit,
                             RewardedEventInteractionDelegate {
   
    @objc public private(set) var reward: NSObject?
    
    // MARK: - Lifecycle
    
    @objc public convenience init(configID: String, eventHandler: AnyObject) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            eventHandler: eventHandler)
    }

    @objc public convenience init(configID: String) {
        self.init(
            configID: configID,
            minSizePerc: nil,
            eventHandler: RewardedEventHandlerStandalone())
    }
    
    @objc required init(configID:String, minSizePerc: NSValue?, eventHandler: AnyObject?) {
        super.init(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: eventHandler)
        
        adUnitConfig.isOptIn = true
        adFormat = .video
    }
    
    // MARK: - PBMRewardedEventDelegate
    @objc public func userDidEarnReward(_ reward: NSObject?) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.reward = reward
            self?.callDelegate_rewardedAdUserDidEarnReward()
        })
        
    }
    
    // MARK: - BaseInterstitialAdUnitProtocol protocol
    
    @objc public override func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        callDelegate_rewardedAdUserDidEarnReward()
        super.interstitialControllerDidCloseAd(interstitialController)
    }

    // MARK: - Protected overrides
    
    @objc public override func callDelegate_didReceiveAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdDidReceiveAd?(self)
        }
    }

    @objc public override func callDelegate_didFailToReceiveAd(with error: Error?) {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAd?(self, didFailToReceiveAdWithError: error)
        }
    }
    
    @objc public override func callDelegate_willPresentAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdWillPresentAd?(self)
        }
    }

    @objc public override func callDelegate_didDismissAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdDidDismissAd?(self)
        }
    }

    @objc public override func callDelegate_willLeaveApplication() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdWillLeaveApplication?(self)
        }
    }

    @objc public override func callDelegate_didClickAd() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdDidClickAd?(self)
        }
    }
    
    @objc public override func callEventHandler_isReady() -> Bool {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            return eventHandler.isReady
        } else {
            return false
        }
    }

    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.loadingDelegate = loadingDelegate as? RewardedEventLoadingDelegate
        }
    }

    @objc public override func callEventHandler_setInteractionDelegate() {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.interactionDelegate = self
        }
    }

    @objc public override func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.requestAd(with: bidResponse)
        }
    }

    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.show(from: controller)
        }
    }

    @objc public override func callEventHandler_trackImpression() {
        if let eventHandler = self.eventHandler as? RewardedEventHandlerProtocol {
            eventHandler.trackImpression?()
        }
    }
    
    // MARK: - Private helpers
    
    func callDelegate_rewardedAdUserDidEarnReward() {
        if let delegate = self.delegate as? RewardedAdUnitDelegate {
            delegate.rewardedAdUserDidEarnReward?(self)
        }
    }
}
