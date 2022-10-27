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
public class AdMobMediationInterstitialUtils: NSObject, PrebidMediationDelegate {
    
    public let gadRequest: GADRequest
    
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
        if let gadKeywords = gadRequest.keywords {
            gadRequest.keywords = AdMobUtils.removeHBKeywordsFrom(gadKeywords)
        }
        
        let extras = GADCustomEventExtras()
        extras.setExtras(nil, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
        gadRequest.register(extras)
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
}
