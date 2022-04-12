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
import PrebidMobile
import GoogleMobileAds

@objc(PrebidAdMobRewardedVideoAdapter)
public class PrebidAdMobRewardedVideoAdapter:
    PrebidAdMobMediationBaseAdapter,
    GADMediationRewardedAd,
    InterstitialControllerLoadingDelegate,
    InterstitialControllerInteractionDelegate  {
    
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var adAvailable = false
    
    weak var delegate: GADMediationRewardedAdEventDelegate?
    
    // MARK: - GADMediationAdapter
    public func loadRewardedAd(for adConfiguration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        guard let prebidExtras = adConfiguration.extras as? PrebidAdMobEventExtras else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate?.didFailToPresentWithError(error)
            return
        }
        
        guard let bid = prebidExtras.additionalParameters[PBMMediationAdUnitBidKey] as? Bid else {
            let error = AdMobAdaptersError.noBidInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let keywords = bid.targetingInfo else {
            let error = AdMobAdaptersError.emptyUserKeywords
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let serverParameter = adConfiguration.credentials.settings["parameter"] as? String else {
            let error = AdMobAdaptersError.noServerParameter
            delegate?.didFailToPresentWithError(error)
            return
        }
        
        guard MediationUtils.isServerParameterInTargetingInfoDict(serverParameter, keywords) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let configId = prebidExtras.additionalParameters[PBMMediationConfigIdKey] as? String else {
            let error = AdMobAdaptersError.noConfigIDInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        delegate = completionHandler(self, nil)
        
        interstitialController = InterstitialController(bid: bid, configId: configId)
        interstitialController?.loadingDelegate = self
        interstitialController?.interactionDelegate = self
        interstitialController?.adFormats = [.video]
        interstitialController?.isOptIn = true
        
        interstitialController?.loadAd()
    }
    
    // MARK: - GADMediationRewardedAd
    public func present(from viewController: UIViewController) {
        if adAvailable {
            rootViewController = viewController
            interstitialController?.show()
        } else {
            let error = AdMobAdaptersError.noAd
            delegate?.didFailToPresentWithError(error)
        }
    }
    
    // MARK: - InterstitialControllerLoadingDelegate
    public func interstitialControllerDidLoadAd(_ interstitialController: InterstitialController) {
        adAvailable = true
    }
    
    public func interstitialController(_ interstitialController: InterstitialController, didFailWithError error: Error) {
        adAvailable = false
        delegate?.didFailToPresentWithError(error)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    public func trackImpression(forInterstitialController: InterstitialController) {
        //Impressions will be tracked automatically
        //unless enableAutomaticImpressionAndClickTracking = NO
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: InterstitialController) {
        delegate?.reportClick()
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        adAvailable = false
        delegate?.willDismissFullScreenView()
        delegate?.didDismissFullScreenView()
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController) {
        
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: InterstitialController) {
        delegate?.willPresentFullScreenView()
        delegate?.didStartVideo()
        delegate?.didEndVideo()
    }
    
    public func interstitialControllerDidComplete(_ interstitialController: InterstitialController) {
        adAvailable = false
        self.rootViewController = nil
        
        let reward = GADAdReward()
        delegate?.didRewardUser(with: reward)
    }
    
    public func viewControllerForModalPresentation(fromInterstitialController: InterstitialController) -> UIViewController? {
        return rootViewController
    }
}
