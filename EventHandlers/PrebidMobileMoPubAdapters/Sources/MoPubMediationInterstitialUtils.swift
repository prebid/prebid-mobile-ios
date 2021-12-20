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
public class MoPubMediationInterstitialUtils: NSObject, PrebidMediationDelegate {
    
    public var mopubController: MPInterstitialAdController
    
    public init(mopubController: MPInterstitialAdController) {
        self.mopubController = mopubController
    }
    
    public func setUpAdObject(configID: String,
                              targetingInfo: [String : String],
                              extraObject: Any?,
                              forKey: String) -> Bool {
        
        let extras = mopubController.localExtras ?? [AnyHashable: Any]()
        let adKeywords = mopubController.keywords ?? ""
        
        //Pass our objects via the localExtra property
        var mutableExtras = extras
        mutableExtras[forKey] = extraObject
        mutableExtras[PBMMediationConfigIdKey] = configID
        
        mopubController.localExtras = mutableExtras
        
        //Setup bid targeting keyword
        if targetingInfo.count > 0 {
            let bidKeywords = MoPubMediationHelper.keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ? bidKeywords : adKeywords + "," + bidKeywords
            
            mopubController.keywords = keywords
        }
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = mopubController.localExtras,
              let adKeywords = mopubController.keywords else {
                  return
              }
        
        let keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        mopubController.keywords = keywords
        
        let HBKeys = [PBMMediationAdUnitBidKey, PBMMediationConfigIdKey, PBMMediationAdNativeResponseKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        mopubController.localExtras = extras
    }
}
