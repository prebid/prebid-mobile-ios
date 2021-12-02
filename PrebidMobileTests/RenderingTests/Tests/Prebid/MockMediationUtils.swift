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

public let MockMediationAdUnitBidKey           = "PBM_BID"
public let MockMediationConfigIdKey            = "PBM_CONFIG_ID"
public let MockMediationAdNativeResponseKey    = "PBM_NATIVE_RESPONSE"

fileprivate let keywordsSeparator              = ","
fileprivate let HBKeywordPrefix                = "hb_"

fileprivate let MockSelector_localExtras       = "localExtras"
fileprivate let MockSelector_setLocalExtras    = "setLocalExtras:"

fileprivate let MockSelector_keywords          = "keywords"
fileprivate let MockSelector_setKeywords       = "setKeywords:"

@objc class MockAdObject: NSObject  {
    @objc var keywords: String?
    @objc var localExtras: [AnyHashable : Any]?
}

class MockMediationUtils: PrebidMediationDelegate {
    public init() {
        
    }
    
    public func isCorrectAdObject(_ adObject: NSObject) -> Bool {
        return adObject.responds(to: Selector((MockSelector_localExtras))) &&
        adObject.responds(to: Selector((MockSelector_setLocalExtras))) &&
        adObject.responds(to: Selector((MockSelector_setKeywords))) &&
        adObject.responds(to: Selector((MockSelector_keywords)))
    }
    
    public func cleanUpAdObject(_ adObject: NSObject) {
        guard isCorrectAdObject(adObject),
              let adExtras = adObject.value(forKey: MockSelector_localExtras) as? [AnyHashable : Any],
              let adKeywords = adObject.value(forKey: MockSelector_keywords) as? String else {
                  return
              }
        
        let keywords = removeHBKeywordsFrom(adKeywords)
        adObject.setValue(keywords, forKey: MockSelector_keywords)
        
        let HBKeys = [MockMediationAdUnitBidKey, MockMediationConfigIdKey, MockMediationAdNativeResponseKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        adObject.setValue(extras, forKey: MockSelector_localExtras)
    }
    
    public func setUpAdObject(_ adObject: NSObject,
                              configID:String,
                              targetingInfo: [String : String],
                              extraObject:Any?,
                              forKey: String) -> Bool {
        guard isCorrectAdObject(adObject) else {
            return false
        }
        
        let extras = adObject.value(forKey: MockSelector_localExtras) as? [AnyHashable : Any]
        let adKeywords = (adObject.value(forKey: MockSelector_keywords) as? String) ?? ""
        
        //Pass our objects via the localExtra property
        var mutableExtras = extras ?? [:]
        mutableExtras[forKey] = extraObject
        mutableExtras[MockMediationConfigIdKey] = configID
        
        adObject.setValue(mutableExtras, forKey: MockSelector_localExtras)
        
        //Setup bid targeting keyword
        if targetingInfo.count > 0 {
            let bidKeywords = keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ?
            bidKeywords :
            adKeywords + "," + bidKeywords
            
            adObject.setValue(keywords, forKey: MockSelector_keywords)
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
