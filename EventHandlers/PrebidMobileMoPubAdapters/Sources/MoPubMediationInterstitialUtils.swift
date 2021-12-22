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
    
    public func setUpAdObject(configId: String,
                              configIdKey: String,
                              targetingInfo: [String : String],
                              extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
        
        let extras = mopubController.localExtras ?? [AnyHashable: Any]()
        var newExtras = MoPubMediationHelper.getExtras(configId: configId,
                                                       configIdKey: configIdKey,
                                                       extrasObject: extrasObject,
                                                       extrasObjectKey: extrasObjectKey)
        extras.forEach { (key, value) in newExtras[key] = value }
        mopubController.localExtras = newExtras
        
        let adKeywords = mopubController.keywords ?? ""
        let newKeywords = MoPubMediationHelper.getKeywords(targetingInfo: targetingInfo)
        mopubController.keywords = adKeywords.isEmpty ? newKeywords: adKeywords + "," + newKeywords
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = mopubController.localExtras,
              let adKeywords = mopubController.keywords else {
                  return
              }
        
        let keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        mopubController.keywords = keywords
        
        let filteredExtras = MoPubMediationHelper
            .removeHBFromExtras(adExtras,
                                hbKeys: [PBMMediationAdUnitBidKey, PBMMediationConfigIdKey, PBMMediationAdNativeResponseKey])
        mopubController.localExtras = filteredExtras
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
}
