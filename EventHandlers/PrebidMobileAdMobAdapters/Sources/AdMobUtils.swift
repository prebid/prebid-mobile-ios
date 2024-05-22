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
import GoogleMobileAds
import PrebidMobile

fileprivate let HBKeywordPrefix = "hb_"

@objcMembers
public class AdMobUtils: NSObject {
    public static func initializeGAD() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    static func removeHBKeywordsFrom(_ keywords: [String]) -> [String]  {
        return keywords
            .filter { !$0.hasPrefix(HBKeywordPrefix) }
    }
    
    static func buildKeywords(existingKeywords: [String]?, targetingInfo: [String: String]?) -> [String]? {
        guard let targetingInfo = targetingInfo else {
            return nil
        }
        
        let prebidKeywords = targetingInfo.map { $0 + ":" + $1 }
        if let existingKeywords = existingKeywords, !existingKeywords.isEmpty {
            let joinedKeywords = existingKeywords + prebidKeywords
            return !joinedKeywords.isEmpty ? joinedKeywords : nil
        }
       
        return !prebidKeywords.isEmpty ? prebidKeywords : nil
    }
}
