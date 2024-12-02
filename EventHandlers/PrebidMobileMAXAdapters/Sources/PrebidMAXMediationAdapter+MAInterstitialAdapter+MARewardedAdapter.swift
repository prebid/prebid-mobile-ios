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
import AppLovinSDK

extension PrebidMAXMediationAdapter: MAInterstitialAdapter,
                                     MARewardedAdapter,
                                     InterstitialControllerLoadingDelegate,
                                     InterstitialControllerInteractionDelegate {
    
    // MARK: - MAInterstitialAdapter
    
    public func loadInterstitialAd(
        for parameters: MAAdapterResponseParameters,
        andNotify delegate: MAInterstitialAdapterDelegate
    ) {
        interstitialDelegate = delegate
        
        switch createInterstitialController(with: parameters) {
        case .success(let controller):
            self.interstitialController = controller
            interstitialController?.loadAd()
        case .failure(let error):
            let maError = MAAdapterError(nsError: error)
            interstitialDelegate?.didFailToLoadInterstitialAdWithError(maError)
        }
    }
    
    public func showInterstitialAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MAInterstitialAdapterDelegate) {
        if interstitialAdAvailable {
            interstitialController?.show()
        } else {
            interstitialDelegate?.didFailToLoadInterstitialAdWithError(MAAdapterError.adNotReady)
        }
    }
    
    // MARK: - MARewardedAdapter
    
    public func loadRewardedAd(for parameters: MAAdapterResponseParameters, andNotify delegate: MARewardedAdapterDelegate) {
        rewardedDelegate = delegate
        
        switch createInterstitialController(with: parameters) {
        case .success(let controller):
            interstitialController = controller
            interstitialController?.isRewarded = true
            interstitialController?.loadAd()
        case .failure(let error):
            let maError = MAAdapterError(nsError: error)
            rewardedDelegate?.didFailToLoadRewardedAdWithError(maError)
        }
    }
    
    public func showRewardedAd(
        for parameters: MAAdapterResponseParameters,
        andNotify delegate: MARewardedAdapterDelegate
    ) {
        if interstitialAdAvailable {
            interstitialController?.show()
        } else {
            interstitialDelegate?.didFailToLoadInterstitialAdWithError(MAAdapterError.adNotReady)
        }
    }
    
    private func createInterstitialController(
        with parameters: MAAdapterResponseParameters
    ) -> Result<InterstitialController, Error> {
        
        guard let serverParameter = parameters
            .serverParameters[MAXCustomParametersKey] as? [String: String] else {
            return .failure(MAXAdaptersError.noServerParameter)
        }
        
        guard let bid = parameters
            .localExtraParameters[PBMMediationAdUnitBidKey] as? Bid else {
            return .failure(MAXAdaptersError.noBidInLocalExtraParameters)
        }
        
        guard let targetingInfo = bid.targetingInfo else {
            return .failure(MAXAdaptersError.noTargetingInfoInBid)
        }
        
        guard MediationUtils
            .isServerParameterDictInTargetingInfoDict(serverParameter, targetingInfo) else {
            return .failure(MAXAdaptersError.wrongServerParameter)
        }
        
        guard let configId = parameters
            .localExtraParameters[PBMMediationConfigIdKey] as? String else {
            return .failure(MAXAdaptersError.noConfigIdInLocalExtraParameters)
        }
        
        let interstitialController = InterstitialController(bid: bid, configId: configId)
        interstitialController.loadingDelegate = self
        interstitialController.interactionDelegate = self
        
        if let videoAdConfig = parameters
            .localExtraParameters[PBMMediationVideoAdConfiguration] as? VideoControlsConfiguration {
            interstitialController.videoControlsConfig = videoAdConfig
        }
        
        if let videoParameters = parameters
            .localExtraParameters[PBMMediationVideoParameters] as? VideoParameters {
            interstitialController.videoParameters = videoParameters
        }
        
        return .success(interstitialController)
    }
    
    // MARK: - InterstitialControllerLoadingDelegate
    
    public func interstitialControllerDidLoadAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        interstitialAdAvailable = true
        interstitialDelegate?.didLoadInterstitialAd()
        rewardedDelegate?.didLoadRewardedAd()
    }
    
    public func interstitialController(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        didFailWithError error: Error
    ) {
        interstitialAdAvailable = false
        let maError = MAAdapterError(nsError: error)
        interstitialDelegate?.didFailToLoadInterstitialAdWithError(maError)
        rewardedDelegate?.didFailToLoadRewardedAdWithError(maError)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    public func interstitialControllerDidClickAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        interstitialDelegate?.didClickInterstitialAd()
        rewardedDelegate?.didClickRewardedAd()
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        interstitialDelegate?.didHideInterstitialAd()
        rewardedDelegate?.didHideRewardedAd()
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        interstitialDelegate?.didDisplayInterstitialAd()
        rewardedDelegate?.didDisplayRewardedAd()
    }
    
    public func interstitialControllerDidComplete(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        interstitialAdAvailable = false
        rewardedDelegate?.didRewardUser(with: MAReward())
    }
    
    public func viewControllerForModalPresentation(
        fromInterstitialController: PrebidMobileInterstitialControllerProtocol
    ) -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController
    }
    
    public func trackImpression(forInterstitialController: PrebidMobileInterstitialControllerProtocol) {}
    public func interstitialControllerDidLeaveApp(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
}
