//
//  IMAUtils.swift
//  PrebidMobile
//
//  Created by Punnaghai Puviarasu on 10/29/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

import Foundation

public final class IMAUtils: NSObject {
    
    @objc
    public static let shared = IMAUtils()
    
    private override init() {}
    
    @objc
    public func constructAdTagURLForIMAWithPrebidKeys (adUnitID:String, customKeywords: [String:String]) -> String{
        let adServerURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&output=vast&unviewed_position_start=1&gdfp_req=1&env=vp"
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
