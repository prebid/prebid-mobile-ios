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

@objcMembers
public class AdMobMediationNativeUtils: NSObject, PrebidMediationDelegate {
    
    public let gadRequest: GADRequest
    
    private var eventExtras: [AnyHashable: Any]?
    
    public init(gadRequest: GADRequest) {
        self.gadRequest = gadRequest
        super.init()
    }
    
    public func setUpAdObject(with values: [String: Any]) -> Bool {
        let extras = GADCustomEventExtras()
        extras.setExtras(values, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
        gadRequest.register(extras)
        gadRequest.keywords = AdMobUtils.buildKeywords(existingKeywords: gadRequest.keywords,
                                                       targetingInfo: values[PBMMediationTargetingInfoKey] as? [String: String])
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let gadKeywords = gadRequest.keywords else {
            return
        }
        gadRequest.keywords = AdMobUtils.removeHBKeywordsFrom(gadKeywords)
        eventExtras = nil
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
    
    #warning("Remove this.")
    public func getEventExtras() -> [AnyHashable: Any]? {
        return eventExtras
    }
    
    #warning("Remove this.")
    public static func findNative(_ extras: [AnyHashable: Any],
                                  completion: @escaping (Result<PrebidMediatedUnifiedNativeAd, Error>) -> Void) {
        switch MediationNativeUtils.findNative(in: extras) {
        case .success(let nativeAd):
            let admobUnifiedAd = PrebidMediatedUnifiedNativeAd(nativeAd: nativeAd)
            completion(.success(admobUnifiedAd))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
