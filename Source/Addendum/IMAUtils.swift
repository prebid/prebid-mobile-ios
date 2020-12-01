/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

@objc public enum IMAAdSlotSize: Int {
    
    case Size400x300
    
    case Size640x480
    
    func size () -> String {
        switch self {
        case .Size400x300: return "400x300"
        case .Size640x480: return "640x480"
        }
    }
}

public final class IMAUtils: NSObject {
    
    @objc
    public static let shared = IMAUtils()
    
    private override init() {}
    
    public func generateInstreamUriForGAM (adUnitID:String, adSlotSizes:[IMAAdSlotSize], customKeywords: [String:String]) throws -> String {
        let adServerURL = "https://pubads.g.doubleclick.net/gampad/ads?output=xml_vast4&unviewed_position_start=1&gdfp_req=1&env=vp"
        
        if (adSlotSizes.count <= 0) {
            throw ErrorCode.invalidSize("adslot size not provided")
        }
        var adSlotSize = "sz="
        for adSlot in adSlotSizes {
            adSlotSize = String(format: "%@%@|", adSlotSize,adSlot.size())
        }
        
        adSlotSize = String(adSlotSize.dropLast())
        let adUnit = String(format: "iu=%@", adUnitID)
        
        let andString: String = "&"
        var targetingKeywordsString: String = ""
        for (key, value) in customKeywords {
            if ( targetingKeywordsString == "") {
                targetingKeywordsString = key + "=" + value
            } else {
                targetingKeywordsString += andString + key + "=" + value
            }
        }
        let customAllowedSet =  NSCharacterSet(charactersIn:"&=\"#%/<>?@\\^`{|}").inverted
        let escapedString:String = targetingKeywordsString.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!
        
        let queryStringKeywords = String(format: "cust_params=%@", escapedString)
        print(queryStringKeywords)
        
        let adTagUrl = String(format: "%@&%@&%@&%@", adServerURL, adSlotSize, adUnit, queryStringKeywords)
        
        return adTagUrl
    }
}
