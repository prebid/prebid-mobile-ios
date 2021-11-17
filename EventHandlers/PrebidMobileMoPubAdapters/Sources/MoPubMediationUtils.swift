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

public let PBMMoPubAdUnitBidKey                 = "PBM_BID"
public let PBMMoPubConfigIdKey                  = "PBM_CONFIG_ID"
public let PBMMoPubAdNativeResponseKey          = "PBM_NATIVE_RESPONSE"

fileprivate let keywordsSeparator               = ","
fileprivate let HBKeywordPrefix                 = "hb_"

fileprivate let MoPubSelector_localExtras       = "localExtras"
fileprivate let MoPubSelector_setLocalExtras    = "setLocalExtras:"

fileprivate let MoPubSelector_keywords          = "keywords"
fileprivate let MoPubSelector_setKeywords       = "setKeywords:"

public class MoPubMediationUtils: PrebidMediationDelegate {
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
    
    public init() {
        
    }
    /**
     Checks that a passed object confirms to the PBMMoPubAdObjectProtocol
     @return YES if the passed object is correct, FALSE otherwise
     */
    public func isCorrectAdObject(_ adObject: NSObject) -> Bool {
        return adObject.responds(to: Selector((MoPubSelector_localExtras))) &&
        adObject.responds(to: Selector((MoPubSelector_setLocalExtras))) &&
        adObject.responds(to: Selector((MoPubSelector_setKeywords))) &&
        adObject.responds(to: Selector((MoPubSelector_keywords)))
    }
    
    /**
     Removes an bid info from ad object's localExtra
     and prebid-specific keywords from ad object's keywords
     */
    public func cleanUpAdObject(_ adObject: NSObject) {
        guard isCorrectAdObject(adObject),
              let adExtras = adObject.value(forKey: MoPubSelector_localExtras) as? [AnyHashable : Any],
              let adKeywords = adObject.value(forKey: MoPubSelector_keywords) as? String else {
                  return
              }
        
        let keywords = removeHBKeywordsFrom(adKeywords)
        adObject.setValue(keywords, forKey: MoPubSelector_keywords)
        
        let HBKeys = [PBMMoPubAdUnitBidKey, PBMMoPubConfigIdKey, PBMMoPubAdNativeResponseKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        adObject.setValue(extras, forKey: MoPubSelector_localExtras)
    }
    
    /**
     Puts to ad object's localExtra the ad object (winning bid or native ad) and configId
     and populates adObject's keywords by targeting info
     @return YES on success and NO otherwise (when the passed ad has wrong type)
     */
    public func setUpAdObject(_ adObject: NSObject,
                              configID:String,
                              targetingInfo: [String : String],
                              extraObject:Any?) -> Bool {
        guard isCorrectAdObject(adObject) else {
            return false
        }
        
        let extras = adObject.value(forKey: MoPubSelector_localExtras) as? [AnyHashable : Any]
        let adKeywords = (adObject.value(forKey: MoPubSelector_keywords) as? String) ?? ""
        
        //Pass our objects via the localExtra property
        var mutableExtras = extras ?? [:]
        mutableExtras[PBMMoPubAdUnitBidKey] = extraObject
        mutableExtras[PBMMoPubConfigIdKey] = configID
        
        adObject.setValue(mutableExtras, forKey: MoPubSelector_localExtras)
        
        //Setup bid targeting keyword
        if targetingInfo.count > 0 {
            let bidKeywords = keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ?
            bidKeywords :
            adKeywords + "," + bidKeywords
            
            adObject.setValue(keywords, forKey: MoPubSelector_keywords)
        }
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func keywordsFrom(_ targetingInfo: [String : String]) -> String {
        return targetingInfo
            .map { $0 + ":" + $1 }
            .joined(separator: keywordsSeparator)
    }
    
    private func removeHBKeywordsFrom(_ keywords: String) -> String  {
        return keywords
            .components(separatedBy: keywordsSeparator)
            .filter { !$0.hasPrefix(HBKeywordPrefix) }
            .joined(separator: keywordsSeparator)
    }
}
