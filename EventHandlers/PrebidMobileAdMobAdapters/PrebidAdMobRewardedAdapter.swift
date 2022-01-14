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

@objc(PrebidAdMobRewardedAdapter)
public class PrebidAdMobRewardedAdapter:
    NSObject,
    GADMediationAdapter,
    GADMediationRewardedAd {
    
    // MARK: - Private Properties
    
    var interstitialController: InterstitialController?
    weak var rootViewController: UIViewController?
    var configID: String?
    var adAvailable = false
    
    public var delegate: GADMediationRewardedAdEventDelegate?
    
    required public override init() {
        super.init()
    }
    
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
    
    
    public func present(from viewController: UIViewController) {
        
    }
    
    public func loadRewardedAd(for adConfiguration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        guard let serverParameter = adConfiguration.credentials.settings["parameter"] else {
            let error = AdMobAdaptersError.noServerParameter
            delegate?.didFailToPresentWithError(error)
            return
        }
        
        print(adConfiguration.bidResponse)
//        guard let keywords = adConfiguration.credentials.user as? [String] else {
//            let error = AdMobAdaptersError.emptyCustomEventExtras
//            delegate?.didFailToPresentWithError(error)
//            return
//        }
        
//        guard AdMobUtils.isServerParameterInKeywords(serverParameter, keywords) else {
//            let error = AdMobAdaptersError.wrongServerParameter
//            delegate?.customEventBanner(self, didFailAd: error)
//            return
//        }
//
//        guard let eventExtras = request.additionalParameters, !eventExtras.isEmpty else {
//            let error = AdMobAdaptersError.emptyCustomEventExtras
//            delegate?.customEventBanner(self, didFailAd: error)
//            return
//        }
//
//        guard let bid = eventExtras[PBMMediationAdUnitBidKey] as? Bid else {
//            let error = AdMobAdaptersError.noBidInEventExtras
//            delegate?.customEventBanner(self, didFailAd: error)
//            return
//        }
//
//        guard let configId = eventExtras[PBMMediationConfigIdKey] as? String else {
//            let error = AdMobAdaptersError.noConfigIDInEventExtras
//            delegate?.customEventBanner(self, didFailAd: error)
//            return
//        }
    }
    
}
