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

import PrebidMobile
import GoogleMobileAds

@objc(PrebidAdMobRewardedAdapter)
public class PrebidAdMobRewardedAdapter:
    PrebidAdMobMediationBaseAdapter,
    GADMediationRewardedAd,
    InterstitialControllerLoadingDelegate,
    InterstitialControllerInteractionDelegate  {
    
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var adAvailable = false
    
    weak var delegate: GADMediationRewardedAdEventDelegate?
    var completionHandler: GADMediationRewardedLoadCompletionHandler?
    
    // MARK: - GADMediationAdapter
    
    public func loadRewardedAd(for adConfiguration: GADMediationRewardedAdConfiguration,
                               completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        self.completionHandler = completionHandler
        
        switch createInterstitialController(with: adConfiguration) {
        case .success(let controller):
            self.interstitialController = controller
            interstitialController?.loadAd()
        case .failure(let error):
            delegate = completionHandler(nil, error)
        }
    }
    
    // MARK: - Helpers
    
    func createInterstitialController(
        with adConfiguration: GADMediationRewardedAdConfiguration
    ) -> Result<InterstitialController, Error> {
        
        guard let serverParameter = adConfiguration.credentials.settings["parameter"] as? String else {
            return .failure(AdMobAdaptersError.noServerParameter)
        }
        
        guard let eventExtras = adConfiguration.extras as? GADCustomEventExtras,
              let eventExtrasDictionary = eventExtras.extras(forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel),
              !eventExtrasDictionary.isEmpty else {
            return .failure(AdMobAdaptersError.emptyCustomEventExtras)
        }
        
        guard let targetingInfo = eventExtrasDictionary[PBMMediationTargetingInfoKey] as? [String: String] else {
            return .failure(AdMobAdaptersError.noTargetingInfoInEventExtras)
        }
        
        guard MediationUtils.isServerParameterInTargetingInfoDict(serverParameter, targetingInfo) else {
            return .failure(AdMobAdaptersError.wrongServerParameter)
        }
        
        guard let bid = eventExtrasDictionary[PBMMediationAdUnitBidKey] as? Bid else {
            return .failure(AdMobAdaptersError.noBidInEventExtras)
        }
        
        guard let configId = eventExtrasDictionary[PBMMediationConfigIdKey] as? String else {
            return .failure(AdMobAdaptersError.noConfigIDInEventExtras)
        }
        
        let interstitialController = InterstitialController(bid: bid, configId: configId)
        interstitialController.loadingDelegate = self
        interstitialController.interactionDelegate = self
        interstitialController.isRewarded = true
        
        if let videoAdConfig = eventExtrasDictionary[PBMMediationVideoAdConfiguration] as? VideoControlsConfiguration {
            interstitialController.videoControlsConfig = videoAdConfig
        }
        
        if let videoParameters = eventExtrasDictionary[PBMMediationVideoParameters] as? VideoParameters {
            interstitialController.videoParameters = videoParameters
        }
        
        return .success(interstitialController)
    }
    
    // MARK: - GADMediationRewardedAd
    
    public func present(from viewController: UIViewController) {
        if adAvailable {
            rootViewController = viewController
            interstitialController?.show()
        } else {
            let error = AdMobAdaptersError.noAd
            delegate?.didFailToPresentWithError(error)
            
            if let handler = completionHandler {
                delegate = handler(nil, error)
            }
        }
    }
    
    // MARK: - InterstitialControllerLoadingDelegate
    
    public func interstitialControllerDidLoadAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        adAvailable = true
        
        if let handler = completionHandler {
            delegate = handler(self, nil)
        }
    }
    
    public func interstitialController(_ interstitialController: PrebidMobileInterstitialControllerProtocol, didFailWithError error: Error) {
        adAvailable = false
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    public func trackImpression(forInterstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.reportImpression()
    }
    
    public func trackUserReward(_ interstitialController: PrebidMobileInterstitialControllerProtocol, _ reward: PrebidReward) {
        delegate?.didRewardUser()
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.reportClick()
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        adAvailable = false
        delegate?.willDismissFullScreenView()
        delegate?.didDismissFullScreenView()
    }
        
    public func interstitialControllerDidDisplay(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.willPresentFullScreenView()
        delegate?.didStartVideo()
        delegate?.didEndVideo()
    }
    
    public func interstitialControllerDidComplete(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        adAvailable = false
        rootViewController = nil
        
        delegate?.didRewardUser()
    }
    
    public func viewControllerForModalPresentation(fromInterstitialController: PrebidMobileInterstitialControllerProtocol) -> UIViewController? {
        rootViewController
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
}
