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
import MoPubSDK

@objcMembers
public class MoPubMediationRewardedUtils: NSObject, PrebidMediationDelegate {
    
    public var bidInfoWrapper: MediationBidInfoWrapper
    
    public init(bidInfoWrapper: MediationBidInfoWrapper) {
        self.bidInfoWrapper = bidInfoWrapper
    }
    
    public func setUpAdObject(configId: String,
                              configIdKey: String,
                              targetingInfo: [String : String],
                              extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
        
        let extras = bidInfoWrapper.localExtras ?? [AnyHashable: Any]()
        var newExtras = MoPubMediationHelper.getExtras(configId: configId,
                                                       configIdKey: configIdKey,
                                                       extrasObject: extrasObject,
                                                       extrasObjectKey: extrasObjectKey)
        extras.forEach { (key, value) in newExtras[key] = value }
        bidInfoWrapper.localExtras = newExtras
        
        let adKeywords = bidInfoWrapper.keywords ?? ""
        let newKeywords = MoPubMediationHelper.getKeywords(targetingInfo: targetingInfo)
        bidInfoWrapper.keywords = adKeywords.isEmpty ? newKeywords: adKeywords + "," + newKeywords
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = bidInfoWrapper.localExtras,
              let adKeywords = bidInfoWrapper.keywords else {
                  return
              }
        
        let keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        bidInfoWrapper.keywords = keywords
        
        let filteredExtras = MoPubMediationHelper
            .removeHBFromExtras(adExtras,
                                hbKeys: [PBMMediationAdUnitBidKey, PBMMediationConfigIdKey, PBMMediationAdNativeResponseKey])
        
        bidInfoWrapper.localExtras = filteredExtras
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
}
