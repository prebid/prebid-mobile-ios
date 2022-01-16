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
    NSObject,
    GADMediationAdapter,
    GADMediationRewardedAd,
    InterstitialControllerLoadingDelegate,
    InterstitialControllerInteractionDelegate  {
    
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var adAvailable = false
    
    weak var delegate: GADMediationRewardedAdEventDelegate?
    
    required public override init() {
        super.init()
    }
    
    // MARK: - GADMediationAdapter
    public static func adapterVersion() -> GADVersionNumber {
        let adapterVersionComponents = AdMobConstants.PrebidAdMobRewardedAdapterVersion.components(separatedBy: ".").map( { Int($0) ?? 0})
        
        return adapterVersionComponents.count == 3 ? GADVersionNumber(majorVersion: adapterVersionComponents[0],
                                                                      minorVersion: adapterVersionComponents[1],
                                                                      patchVersion: adapterVersionComponents[2]): GADVersionNumber()
    }
    
    public static func adSDKVersion() -> GADVersionNumber {
        let sdkVersionComponents = PrebidRenderingConfig.shared.version.components(separatedBy: ".").map( { Int($0) ?? 0})
        
        return sdkVersionComponents.count == 3 ? GADVersionNumber(majorVersion: sdkVersionComponents[0],
                                                                  minorVersion: sdkVersionComponents[1],
                                                                  patchVersion: sdkVersionComponents[2]): GADVersionNumber()
    }
    
    public static func networkExtrasClass() -> GADAdNetworkExtras.Type? {
        return nil
    }
        
    public func loadRewardedAd(for adConfiguration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        guard let serverParameter = adConfiguration.credentials.settings["parameter"] as? String else {
            let error = AdMobAdaptersError.noServerParameter
            delegate?.didFailToPresentWithError(error)
            return
        }
        
        let gadTargeting = adConfiguration.value(forKey: "targeting") as? NSObject
        
        guard let keywords = gadTargeting?.value(forKey: "keywords") as? [String] else {
            let error = AdMobAdaptersError.emptyUserKeywords
            delegate = completionHandler(nil, error)
            return
        }
        
        guard AdMobUtils.isServerParameterInKeywords(serverParameter, keywords) else {
            let error = AdMobAdaptersError.wrongServerParameter
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let networkExtrasMap = gadTargeting?.value(forKey: "networkExtrasMap") as? [AnyHashable: Any],
              let customEventExtrasDictionary = networkExtrasMap["GADCustomEventExtras"] as? NSObject,
              let extras = customEventExtrasDictionary.value(forKey: "extras") as? [AnyHashable: Any],
              let prebidExtras = extras[AdMobConstants.PrebidAdMobEventExtrasLabel] as? [AnyHashable: Any] else {
                  let error = AdMobAdaptersError.emptyCustomEventExtras
                  delegate = completionHandler(nil, error)
                  return
              }
        
        guard let bid = prebidExtras[PBMMediationAdUnitBidKey] as? Bid else {
            let error = AdMobAdaptersError.noBidInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        guard let configId = prebidExtras[PBMMediationConfigIdKey] as? String else {
            let error = AdMobAdaptersError.noConfigIDInEventExtras
            delegate = completionHandler(nil, error)
            return
        }
        
        delegate = completionHandler(self, nil)
        
        interstitialController = InterstitialController(bid: bid, configId: configId)
        interstitialController?.loadingDelegate = self
        interstitialController?.interactionDelegate = self
        interstitialController?.adFormat = .video
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
    public func trackImpression(for interstitialController: InterstitialController) {
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
    
    public func viewControllerForModalPresentation(from interstitialController: InterstitialController) -> UIViewController? {
        return rootViewController
    }
}
