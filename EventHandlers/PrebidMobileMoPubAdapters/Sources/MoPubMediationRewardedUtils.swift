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
    
    public func setUpAdObject(configID: String,
                              targetingInfo: [String : String],
                              extraObject: Any?,
                              forKey: String) -> Bool {
        
        let extras = bidInfoWrapper.localExtras ?? [AnyHashable: Any]()
        let adKeywords = bidInfoWrapper.keywords ?? ""
        
        //Pass our objects via the localExtra property
        var mutableExtras = extras
        mutableExtras[forKey] = extraObject
        mutableExtras[PBMMediationConfigIdKey] = configID
        
        bidInfoWrapper.localExtras = mutableExtras
        
        //Setup bid targeting keyword
        if targetingInfo.count > 0 {
            let bidKeywords = MoPubMediationHelper.keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ? bidKeywords : adKeywords + "," + bidKeywords
            
            bidInfoWrapper.keywords = keywords
        }
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = bidInfoWrapper.localExtras,
              let adKeywords = bidInfoWrapper.keywords else {
                  return
              }
        
        let keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        bidInfoWrapper.keywords = keywords
        
        let HBKeys = [PBMMediationAdUnitBidKey, PBMMediationConfigIdKey, PBMMediationAdNativeResponseKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        bidInfoWrapper.localExtras = extras
    }
}
