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

class MoPubMediationHelper {
    
    private init() {}
    
    static func removeHBKeywordsFrom(_ keywords: String) -> String  {
        return keywords
            .components(separatedBy: Constants.keywordsSeparator)
            .filter { !$0.hasPrefix(Constants.HBKeywordPrefix) }
            .joined(separator: Constants.keywordsSeparator)
    }
    
    static func removeHBFromExtras(_ extras: [AnyHashable: Any]) -> [AnyHashable: Any] {
        let hbKeys = [PBMMediationAdUnitBidKey, PBMMediationConfigIdKey, PBMMediationAdNativeResponseKey]
        return extras.filter {
            guard let key = $0.key as? String else { return true }
            return !hbKeys.contains(key)
        }
    }
    
    static func getExtras(existingExtras: [AnyHashable: Any]?,
                          configId: String,
                          configIdKey: String,
                          extrasObject: Any?,
                          extrasObjectKey: String) -> [AnyHashable: Any]? {
        var extras = existingExtras ?? [AnyHashable: Any]()
        extras[configIdKey] = configId
        extras[extrasObjectKey] = extrasObject
        return !extras.isEmpty ? extras : nil
    }
    
    static func getKeywords(existingKeywords: String?,
                            targetingInfo: [String: String]) -> String? {
        let prebidKeywords = targetingInfo
            .map { $0 + ":" + $1 }
            .joined(separator: Constants.keywordsSeparator)
        
        if let existingKeywords = existingKeywords, !existingKeywords.isEmpty {
            let joinedKeywords = existingKeywords + "," + prebidKeywords
            return !joinedKeywords.isEmpty ? joinedKeywords : nil
        }
       
        return !prebidKeywords.isEmpty ? prebidKeywords : nil
    }
}
