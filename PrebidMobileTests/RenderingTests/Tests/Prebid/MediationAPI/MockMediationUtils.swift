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
import UIKit
import PrebidMobile

public let MockMediationAdUnitBidKey           = "PBM_BID"
public let MockMediationConfigIdKey            = "PBM_CONFIG_ID"
public let MockMediationAdNativeResponseKey    = "PBM_NATIVE_RESPONSE"
public let MockMediationTargetingInfoKey       = "PBM_TARGETING_INFO"

fileprivate let keywordsSeparator              = ","
fileprivate let HBKeywordPrefix                = "hb_"

@objc class MockAdObject: UIView {
    @objc var keywords: String?
    @objc var localExtras: [AnyHashable : Any]?
}

class MockEmptyPrebidMediationDelegate: PrebidMediationDelegate {
    func setUpAdObject(with values: [String : Any]) -> Bool { true }
    func cleanUpAdObject() {}
    func getAdView() -> UIView? { UIView(frame: .zero)}
}

class MockMediationUtils: PrebidMediationDelegate {
    
    let adObject: MockAdObject
    
    public init(adObject: MockAdObject) {
        self.adObject = adObject
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = adObject.localExtras,
              let adKeywords = adObject.keywords else {
                  return
              }
        
        let keywords = removeHBKeywordsFrom(adKeywords)
        adObject.keywords = keywords
        
        let HBKeys = [MockMediationAdUnitBidKey, MockMediationConfigIdKey, MockMediationAdNativeResponseKey, MockMediationTargetingInfoKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        adObject.localExtras = extras
    }
    
    public func setUpAdObject(with values: [String: Any]) -> Bool {
    
        let extras = adObject.localExtras ?? [:]
        let adKeywords = adObject.keywords ?? ""
        
        //Pass our objects via the localExtra property
        adObject.localExtras = extras.merging(values, uniquingKeysWith: { $1})
        
        //Setup bid targeting keyword
        if let targetingInfo = values[MockMediationTargetingInfoKey] as? [String: String], targetingInfo.count > 0 {
            let bidKeywords = keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ? bidKeywords : adKeywords + "," + bidKeywords
            adObject.keywords = keywords
        }
        
        return true
    }
    
    func getAdView() -> UIView? {
        return adObject
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
