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
public class MoPubMediationBannerUtils: NSObject, PrebidMediationDelegate {
    
    public var mopubView: MPAdView
    
    public init(mopubView: MPAdView) {
        self.mopubView = mopubView
    }
    
    public func setUpAdObject(configId: String,
                              configIdKey: String,
                              targetingInfo: [String : String],
                              extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
    
        mopubView.localExtras = MoPubMediationHelper.getExtras(existingExtras: mopubView.localExtras,
                                                               configId: configId,
                                                               configIdKey: configIdKey,
                                                               extrasObject: extrasObject,
                                                               extrasObjectKey: extrasObjectKey)

        mopubView.keywords = MoPubMediationHelper.getKeywords(existingKeywords: mopubView.keywords,
                                                              targetingInfo: targetingInfo)
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = mopubView.localExtras,
              let adKeywords = mopubView.keywords else {
                  return
              }
        
        mopubView.keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        mopubView.localExtras = MoPubMediationHelper.removeHBFromExtras(adExtras)
    }
    
    public func getAdView() -> UIView? {
        return mopubView
    }
}
