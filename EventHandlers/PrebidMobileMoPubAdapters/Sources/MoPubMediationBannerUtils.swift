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
        
        let extras = mopubView.localExtras ?? [AnyHashable: Any]()
        mopubView.localExtras = MoPubMediationHelper.getExtras(existingExtras: extras,
                                                               configId: configId,
                                                               configIdKey: configIdKey,
                                                               extrasObject: extrasObject,
                                                               extrasObjectKey: extrasObjectKey)
        let adKeywords = mopubView.keywords ?? ""
        mopubView.keywords = MoPubMediationHelper.getKeywords(existingKeywords: adKeywords,
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
    
    /**
     Finds an native ad object in the given extra dictionary.
     Calls the provided callback with the finded native ad object or error
     */
    // The feature is not available. Use original Prebid Native API
    // TODO: Merge Native engine from original SDK and rendering codebase
    //    static func findNativeAd(_ extras: [AnyHashable : Any],
    //                             completion: @escaping (PBRNativeAd?, Error?) -> Void) {
    //
    //        guard let response = extras[PBMMoPubAdNativeResponseKey] as? DemandResponseInfo else {
    //            let error = PBMError.error(description: "The Response object is absent in the extras")
    //            completion(nil, error)
    //            return
    //        }
    //
    //        response.getNativeAd { ad in
    //            guard let nativeAd = ad else {
    //                let error = PBMError.error(description: "The Native Ad object is absent in the extras")
    //                completion(nil, error)
    //                return
    //            }
    //
    //            completion(nativeAd, nil)
    //        }
    //    }
    
}
