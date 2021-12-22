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
public class AdMobMediationBannerUtils: NSObject, PrebidMediationDelegate {
    
    public let gadRequest: GADRequest
    
    public let bannerView: GADBannerView
    
    private var eventExtras: [AnyHashable: Any]?
    
    public init(gadRequest: GADRequest, bannerView: GADBannerView) {
        self.gadRequest = gadRequest
        self.bannerView = bannerView
        super.init()
    }
    
    public func setUpAdObject(configId: String,
                              configIdKey: String,
                              targetingInfo: [String : String],
                              extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
        
        eventExtras = AdMobMediationHelper.getExtras(configId: configId,
                                                     configIdKey: configIdKey,
                                                     extrasObject: extrasObject,
                                                     extrasObjectKey: extrasObjectKey)
        
        let adKeywords = gadRequest.keywords ?? [String]()
        let newKeywords = AdMobMediationHelper.getKeywords(targetingInfo: targetingInfo)
        gadRequest.keywords = adKeywords.isEmpty ? newKeywords: adKeywords + newKeywords
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let gadKeywords = gadRequest.keywords as? [String] else {
            return
        }
        gadRequest.keywords = AdMobMediationHelper.removeHBKeywordsFrom(gadKeywords)
    }
    
    public func getAdView() -> UIView? {
        return bannerView
    }
    
    public func getEventExtras() -> [AnyHashable: Any]? {
        return eventExtras
    }
}
