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
        
        mopubController.localExtras = MoPubMediationHelper.getExtras(existingExtras: mopubController.localExtras,
                                                                     configId: configId,
                                                                     configIdKey: configIdKey,
                                                                     extrasObject: extrasObject,
                                                                     extrasObjectKey: extrasObjectKey)
        
        mopubController.keywords = MoPubMediationHelper.getKeywords(existingKeywords: mopubController.keywords ?? "",
                                                                    targetingInfo: targetingInfo)
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = mopubController.localExtras,
              let adKeywords = mopubController.keywords else {
                  return
              }
        
        mopubController.keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        mopubController.localExtras = MoPubMediationHelper.removeHBFromExtras(adExtras)
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
}
