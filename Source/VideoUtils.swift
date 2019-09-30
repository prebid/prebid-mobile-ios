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

@objcMembers
public final class VideoUtils: NSObject {
    
    private override init() {}
    
    public static func buildAdTagUrl(adUnitId: String, adSlotSize:String?, targeting: Dictionary<String, String>) -> String {
        
        let targetingString = (targeting as [AnyHashable: Any]).toString(entrySeparator: "&", keyValueSeparator: "=")
        let allowedCharacterSet = (CharacterSet(charactersIn: "=&").inverted)
        let customParamsString = targetingString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        
        let adTagUrl = buildAdTagUrl(adUnitId: adUnitId, adSlotSize: adSlotSize, customParams: customParamsString!)
        
        return adTagUrl
    }
    
    //https://support.google.com/admanager/answer/1068325?hl=en
    static func buildAdTagUrl(adUnitId: String, adSlotSize:String?, customParams: String?) -> String {
        let currentMillis = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        var adTagUrl =
            "https://pubads.g.doubleclick.net/gampad/ads?" +
                //Required parameters
                "env=vp" + //vp Indicates that the request is from a video player.
                "&gdfp_req=1" + //Indicates that the user is on the Ad Manager schema.
                "&unviewed_position_start=1" + //    Setting this to 1 turns on delayed impressions for video.
                //Required parameters with variable values
                "&output=xml_vast4" + //Output format of ad
                "&vpmute=1" + //Indicates whether the ad playback starts while the video player is muted.
        "&iu=\(adUnitId)";
        
        if let adSlotSize = adSlotSize {
            adTagUrl += "&sz=\(adSlotSize)" //Size of master video ad slot. Multiple sizes should be separated by the pipe (|) character.
        }
        
        if let customParams = customParams {
            adTagUrl += "&cust_params=\(customParams)"
        }
        
        adTagUrl += "&correlator=\(currentMillis)"
        
        return adTagUrl
    }

}
