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
    PrebidAdMobMediationBaseAdapter,
    GADMediationInterstitialAd,
    InterstitialControllerLoadingDelegate,
    InterstitialControllerInteractionDelegate {
    
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var adAvailable = false
    
    public weak var delegate: GADMediationInterstitialAdEventDelegate?
    var completionHandler: GADMediationInterstitialLoadCompletionHandler?
    
    public func loadInterstitial(for adConfiguration: GADMediationInterstitialAdConfiguration,
                                 completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
        self.completionHandler = completionHandler
        
        guard let serverParameter = adConfiguration.credentials.settings["parameter"] as? String else {
            let error = AdMobAdaptersError.noServerParameter
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let eventExtras = adConfiguration.extras as? GADCustomEventExtras,
              let eventExtrasDictionary = eventExtras.extras(forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel),
              !eventExtrasDictionary.isEmpty else {
            let error = AdMobAdaptersError.emptyCustomEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let targetingInfo = eventExtrasDictionary[PBMMediationTargetingInfoKey] as? [String: String] else {
            let error = AdMobAdaptersError.noTargetingInfoInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard MediationUtils.isServerParameterInTargetingInfoDict(serverParameter, targetingInfo) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let bid = eventExtrasDictionary[PBMMediationAdUnitBidKey] as? Bid else {
            let error = AdMobAdaptersError.noBidInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let configId = eventExtrasDictionary[PBMMediationConfigIdKey] as? String else {
            let error = AdMobAdaptersError.noConfigIDInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        interstitialController = InterstitialController(bid: bid, configId: configId)
        interstitialController?.loadingDelegate = self
        interstitialController?.interactionDelegate = self
        interstitialController?.adFormats = [.video]
        
        if let videoAdConfig = eventExtrasDictionary[PBMMediationVideoAdConfiguration] as? VideoControlsConfiguration {
            interstitialController?.videoControlsConfig = videoAdConfig
        }
        
        if let videoParameters = eventExtrasDictionary[PBMMediationVideoParameters] as? VideoParameters {
            interstitialController?.videoParameters = videoParameters
        }
        
        interstitialController?.loadAd()
    }
    
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
    
    public func interstitialControllerDidLoadAd(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol
    ) {
        adAvailable = true
        
        if let handler = completionHandler {
            delegate = handler(self, nil)
        }
    }
    
    public func interstitialController(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        didFailWithError error: Error
    ) {
        adAvailable = false
        
        if let handler = completionHandler {
            delegate = handler(nil, error)
        }
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    public func trackImpression(forInterstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.reportImpression()
    }
    
    public func viewControllerForModalPresentation(
        fromInterstitialController: PrebidMobileInterstitialControllerProtocol
    ) -> UIViewController? {
        rootViewController
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.reportClick()
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.willDismissFullScreenView()
        delegate?.didDismissFullScreenView()
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        delegate?.willPresentFullScreenView()
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    public func interstitialControllerDidComplete(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
}
