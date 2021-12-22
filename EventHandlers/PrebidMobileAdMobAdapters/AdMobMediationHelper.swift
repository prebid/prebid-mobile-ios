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

class AdMobMediationHelper {
    
    static func removeHBKeywordsFrom(_ keywords: [String]) -> [String]  {
        return keywords
            .filter { !$0.hasPrefix(Constants.HBKeywordPrefix) }
    }
    
    static func getExtras(configId: String,
                          configIdKey: String,
                          extrasObject: Any?,
                          extrasObjectKey: String) -> [AnyHashable: Any] {
        var extras = [AnyHashable: Any]()
        extras[configIdKey] = configId
        extras[extrasObjectKey] = extrasObject
        return extras
    }
    
    static func getKeywords(targetingInfo: [String: String]) -> [String] {
        if targetingInfo.count > 0 {
            return targetingInfo
                .map { $0 + ":" + $1 }
        }
        return []
    }
}
