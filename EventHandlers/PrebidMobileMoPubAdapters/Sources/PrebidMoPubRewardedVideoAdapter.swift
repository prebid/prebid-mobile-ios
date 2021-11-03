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

import Foundation

import MoPubSDK

import PrebidMobile

@objc(PrebidMoPubRewardedVideoAdapter)
public class PrebidMoPubRewardedVideoAdapter :
    MPFullscreenAdAdapter,
    InterstitialControllerLoadingDelegate,
    InterstitialControllerInteractionDelegate {
    
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var configID: String?
    var adAvailable = false
    
    // MARK: - MPFullscreenAdAdapter
    
    override public var hasAdAvailable: Bool {
        get { adAvailable }
        set { adAvailable = newValue }
    }
    
    public override func requestAd(withAdapterInfo info: [AnyHashable : Any], adMarkup: String?) {
        guard !localExtras.isEmpty else {
            let error = MoPubAdaptersError.emptyLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        guard let bid = localExtras[PBMMoPubAdUnitBidKey] as? Bid else {
            let error = MoPubAdaptersError.noBidInLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        guard let configID = localExtras[PBMMoPubConfigIdKey] as? String else {
            let error = MoPubAdaptersError.noConfigIDInLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        interstitialController = InterstitialController(bid: bid, configId: configID)
        interstitialController?.loadingDelegate = self
        interstitialController?.interactionDelegate = self
        interstitialController?.adFormat = .video
        interstitialController?.isOptIn = true
        
        interstitialController?.loadAd()
        
        MPLogging.logEvent(MPLogEvent.adLoadAttempt(forAdapter: Self.className(), dspCreativeId: nil, dspName: nil), source: adUnitId, from: nil)
    }
    
    public override func presentAd(from viewController: UIViewController) {
        MPLogging.logEvent(MPLogEvent.adShowAttempt(forAdapter: Self.className()), source: adUnitId, from: nil)

        if hasAdAvailable {
            rootViewController = viewController
            interstitialController?.show()
        } else {
            let error = MoPubAdaptersError.noAd
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
        }
    }
    
    public override var isRewardExpected: Bool {
        true
    }
        
    // MARK: - InterstitialControllerLoadingDelegate
    
    public func interstitialControllerDidLoadAd(_ interstitialController: InterstitialController) {
        adAvailable = true
        
        MPLogging.logEvent(MPLogEvent.adLoadSuccess(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapterDidLoadAd(self)
    }
    
    public func interstitialController(_ interstitialController: InterstitialController, didFailWithError error: Error) {
        adAvailable = false
        
        MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapter(self, didFailToLoadAdWithError: error)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    public func trackImpression(for interstitialController: InterstitialController) {
        //Impressions will be tracked automatically
        //unless enableAutomaticImpressionAndClickTracking = NO
        //In this case you have to override the didDisplayAd method
        //and manually call inlineAdAdapterDidTrackImpression
        //in this method to ensure correct metrics
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: InterstitialController) {
        MPLogging.logEvent(MPLogEvent.adTapped(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapterDidReceiveTap(self)
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        adAvailable = false
        
        MPLogging.logEvent(MPLogEvent.adWillDisappear(forAdapter: Self.className()), source: adUnitId, from: nil)
        MPLogging.logEvent(MPLogEvent.adDidDisappear(forAdapter: Self.className()), source: adUnitId, from: nil)

        delegate?.fullscreenAdAdapterAdWillDisappear(self)
        delegate?.fullscreenAdAdapterAdDidDisappear(self)
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController) {
        MPLogging.logEvent(MPLogEvent.adWillLeaveApplication(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.fullscreenAdAdapterWillLeaveApplication(self)
    }
    
    public func viewControllerForModalPresentation(from interstitialController: InterstitialController) -> UIViewController? {
        rootViewController
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: InterstitialController) {
        let className = Self.className()
        
        MPLogging.logEvent(MPLogEvent.adWillAppear(forAdapter: className), source: adUnitId, from: nil)
        MPLogging.logEvent(MPLogEvent.adDidAppear(forAdapter: className), source: adUnitId, from: nil)
        MPLogging.logEvent(MPLogEvent.adShowSuccess(forAdapter: className), source: adUnitId, from: nil)

        delegate?.fullscreenAdAdapterAdWillAppear(self)
        delegate?.fullscreenAdAdapterAdDidAppear(self)
    }
    
    public func interstitialControllerDidComplete(_ interstitialController: InterstitialController) {
        adAvailable = false
        self.interstitialController = nil
        
        let reward = MPReward()
        delegate?.fullscreenAdAdapter(self, willRewardUser: reward)
    }
}
