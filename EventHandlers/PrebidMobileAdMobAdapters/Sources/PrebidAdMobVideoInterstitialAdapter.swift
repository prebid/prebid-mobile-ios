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
import GoogleMobileAds
import PrebidMobile

@objc(PrebidAdMobVideoInterstitialAdapter)
public class PrebidAdMobVideoInterstitialAdapter:
    NSObject,
    GADCustomEventInterstitial,
    InterstitialControllerLoadingDelegate,
    InterstitialControllerInteractionDelegate {
 
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var adAvailable = false
    
    public weak var delegate: GADCustomEventInterstitialDelegate?
    
    required public override init() {
        super.init()
    }
    
    // MARK: - GADCustomEventInterstitial
    public func requestAd(withParameter serverParameter: String?, label serverLabel: String?, request: GADCustomEventRequest) {
        guard let keywords = request.userKeywords as? [String] else {
            let error = AdMobAdaptersError.emptyUserKeywords
            delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        guard let serverParameter = serverParameter else {
            let error = AdMobAdaptersError.noServerParameter
            delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        guard MediationUtils.isServerParameterInTargetingInfo(serverParameter, keywords) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        guard let eventExtras = request.additionalParameters, !eventExtras.isEmpty else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        guard let bid = eventExtras[PBMMediationAdUnitBidKey] as? Bid else {
            let error = AdMobAdaptersError.noBidInEventExtras
            delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        guard let configId = eventExtras[PBMMediationConfigIdKey] as? String else {
            let error = AdMobAdaptersError.noConfigIDInEventExtras
            delegate?.customEventInterstitial(self, didFailAd: error)
            return
        }
        
        interstitialController = InterstitialController(bid: bid, configId: configId)
        interstitialController?.loadingDelegate = self
        interstitialController?.interactionDelegate = self
        interstitialController?.adFormats = [.video]
        interstitialController?.loadAd()
    }
    
    public func present(fromRootViewController rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        
        if adAvailable {
            self.rootViewController = rootViewController
            interstitialController?.show()
        } else {
            let error = AdMobAdaptersError.noAd
            delegate?.customEventInterstitial(self, didFailAd: error)
        }
    }
    
    // MARK: - InterstitialControllerLoadingDelegate
    
    public func interstitialControllerDidLoadAd(_ interstitialController: InterstitialController) {
        adAvailable = true
        delegate?.customEventInterstitialDidReceiveAd(self)
    }
    
    public func interstitialController(_ interstitialController: InterstitialController, didFailWithError error: Error) {
        adAvailable = false
        delegate?.customEventInterstitial(self, didFailAd: error)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    public func trackImpression(forInterstitialController: InterstitialController) {
        //Impressions will be tracked automatically
        //unless enableAutomaticImpressionAndClickTracking = NO
    }
    
    public func viewControllerForModalPresentation(fromInterstitialController: InterstitialController) -> UIViewController? {
        return rootViewController
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: InterstitialController) {
        delegate?.customEventInterstitialWasClicked(self)
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        delegate?.customEventInterstitialWillDismiss(self)
        delegate?.customEventInterstitialDidDismiss(self)
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController) {
        delegate?.customEventInterstitialWillLeaveApplication(self)
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: InterstitialController) {
        delegate?.customEventInterstitialWillPresent(self)
    }
    
    public func interstitialControllerDidComplete(_ interstitialController: InterstitialController) {
        
    }
}
