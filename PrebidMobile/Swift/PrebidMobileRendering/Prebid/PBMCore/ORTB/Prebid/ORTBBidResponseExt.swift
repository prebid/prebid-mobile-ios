//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@objc public class ORTBBidResponseExt: NSObject, PBMJsonCodable {
    
    /// [ (bidder: String) -> (millis: Integer) ]
    @objc public var responsetimemillis: [String : NSNumber]?
    
    /// [Integer]
    @objc public var tmaxrequest: NSNumber?
    
    @objc public var extPrebid: ORTBBidResponseExtPrebid?
    
    private enum KeySet: String {
        case responsetimemillis
        case tmaxrequest
        case prebid
    }
    
    override init() {
    }
    
    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        responsetimemillis  = json[.responsetimemillis]
        tmaxrequest         = json[.tmaxrequest]
        extPrebid           = json[.prebid]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.responsetimemillis]   = responsetimemillis
        json[.tmaxrequest]          = tmaxrequest
        json[.prebid]               = extPrebid
        
        return json.dict
    }
}
