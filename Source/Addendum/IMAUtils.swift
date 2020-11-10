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

public final class IMAUtils: NSObject {
    
    @objc
    public static let shared = IMAUtils()
    
    private override init() {}
    
    @objc
    public func constructAdTagURLForIMAWithPrebidKeys (adUnitID:String, customKeywords: [String:String]) -> String{
        let adServerURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480|400x300&output=xml_vast4&unviewed_position_start=1&gdfp_req=1&env=vp"
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
        
        let adTagUrl = String(format: "%@&%@&%@", adServerURL,adUnit,queryStringKeywords)
        
        return adTagUrl
    }
}
