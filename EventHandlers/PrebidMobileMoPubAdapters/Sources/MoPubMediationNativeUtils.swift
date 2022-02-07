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
public class MoPubMediationNativeUtils: NSObject, PrebidMediationDelegate {
    
    public var targeting: MPNativeAdRequestTargeting
    
    public init(targeting: MPNativeAdRequestTargeting) {
        self.targeting = targeting
    }
    
    public func setUpAdObject(configId: String,
                              configIdKey: String,
                              targetingInfo: [String : String],
                              extrasObject: Any?,
                              extrasObjectKey: String) -> Bool {
        
        targeting.localExtras = MoPubMediationHelper.getExtras(existingExtras: targeting.localExtras,
                                                                     configId: configId,
                                                                     configIdKey: configIdKey,
                                                                     extrasObject: extrasObject,
                                                                     extrasObjectKey: extrasObjectKey)
        
        targeting.keywords = MoPubMediationHelper.getKeywords(existingKeywords: targeting.keywords,
                                                                    targetingInfo: targetingInfo)
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = targeting.localExtras,
              let adKeywords = targeting.keywords else {
                  return
              }
        
        targeting.keywords = MoPubMediationHelper.removeHBKeywordsFrom(adKeywords)
        targeting.localExtras = MoPubMediationHelper.removeHBFromExtras(adExtras)
    }
    
    public func getAdView() -> UIView? {
        return nil
    }
    
    public static func isPrebidAd(nativeAd: MPNativeAd) -> Bool {
        guard nativeAd.responds(to: #selector(getter: MPNativeAd.properties)) else {
            return false
        }
        
        if let isPrebidCreativeFlag = nativeAd.properties?[Constants.creativeDataKeyIsPrebid] as? String,
           isPrebidCreativeFlag == Constants.creativeDataValueIsPrebid {
            
            return true
        }
        
        return false
    }
    
    public static func findNative(_ extras: [AnyHashable : Any],
                                  completion: @escaping (Result<NativeAd, MoPubAdaptersError>) -> Void) {
        guard let response = extras[PBMMediationAdNativeResponseKey] as? [String: AnyObject] else {
            let error = MoPubAdaptersError.noBidInLocalExtras
            completion(.failure(error))
            return
        }
        
        guard let cacheId = response[PrebidLocalCacheIdKey] as? String else {
            let error = MoPubAdaptersError.noLocalCacheID
            completion(.failure(error))
            return
        }
        
        guard CacheManager.shared.isValid(cacheId: cacheId) else {
            let error = MoPubAdaptersError.invalidLocalCacheID
            completion(.failure(error))
            return
        }
        
        guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
            let error = MoPubAdaptersError.noAd
            completion(.failure(error))
            return
        }
        
        completion(.success(nativeAd))
    }
    
    public static func getPrebidNative(from mopubNativeAd: MPNativeAd) -> Result<NativeAd, MoPubAdaptersError> {
        guard isPrebidAd(nativeAd: mopubNativeAd) == true else {
            return .failure(MoPubAdaptersError.nonPrebidAd)
        }
        
        guard let cacheId = mopubNativeAd.properties[PrebidLocalCacheIdKey] as? String else {
            return .failure(MoPubAdaptersError.noLocalCacheID)
        }
        
        guard let nativeAd = NativeAd.create(cacheId: cacheId) else {
            let error = MoPubAdaptersError.noAd
            return .failure(error)
        }
        
        return .success(nativeAd)
    }
}
