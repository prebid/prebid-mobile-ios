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

@objcMembers
public class PBMORTBBidExtPrebid: PBMORTBAbstract {
    public var cache: PBMORTBBidExtPrebidCache?
    public var targeting: [String : Any]?
    public var meta: [String : Any]?
    public var type: String?
    public var passthrough: [PBMORTBExtPrebidPassthrough]?
    public var events: PBMORTBExtPrebidEvents?
    
    private enum KeySet: String {
        case cache
        case targeting
        case meta
        case type
        case passthrough
        case events
    }
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        cache = json[.cache]
        targeting = json[.targeting]
        meta = json[.meta]
        type = json[.type]
        passthrough = json.backwardsCompatiblePassthrough(key: .passthrough)
        events = json[.events]
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.cache] = cache
        json[.targeting] = targeting
        json[.meta] = meta
        json[.type] = type
        json[.passthrough] = passthrough
        json[.events] = events
        
        return json.dict
    }
}
