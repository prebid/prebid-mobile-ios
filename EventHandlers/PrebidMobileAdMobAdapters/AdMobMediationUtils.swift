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
import GoogleMobileAds

public class AdMobMediationUtils: NSObject, PrebidMediationDelegate {
    
    public let gadRequest: GADRequest
    
    public init(gadRequest: GADRequest) {
        self.gadRequest = gadRequest
        super.init()
    }
    
    public func setUpAdObject(configID: String,
                              targetingInfo: [String : String],
                              extraObject: Any?,
                              forKey: String) -> Bool {
        
        let eventExtras = GADCustomEventExtras()
        
        var mutableExtras = [AnyHashable : Any]()
        mutableExtras[forKey] = extraObject
        mutableExtras[PBMMediationConfigIdKey] = configID
        
        eventExtras.setExtras(mutableExtras, forLabel: Constants.customEventLabel)
        
        gadRequest.register(eventExtras)
        
        if targetingInfo.count > 0 {
            let bidKeywords = targetingInfo.map { $0 + ":" + $1 }
            gadRequest.keywords = bidKeywords
        }
        
        
        return true
    }
    
    public func cleanUpAdObject() {
        guard let gadKeywords = gadRequest.keywords else {
                  return
              }
        let keywords = gadKeywords.filter { !$0.hasPrefix(Constants.HBKeywordPrefix) }
        gadRequest.keywords = keywords
    }
}
