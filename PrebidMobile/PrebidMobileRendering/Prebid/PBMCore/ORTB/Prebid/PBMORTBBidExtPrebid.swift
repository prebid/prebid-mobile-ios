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
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        cache = jsonDictionary.entity(key: "cache")
        targeting = jsonDictionary[key: "targeting"]
        meta = jsonDictionary[key: "meta"]
        type = jsonDictionary[key: "type"]
        passthrough = jsonDictionary.passthroughObjects(key: "passthrough")
        events = jsonDictionary.entity(key: "events")
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["cache"] = cache?.toJsonDictionary().nilIfEmpty
        ret["targeting"] = targeting?.nilIfEmpty
        ret["meta"] = meta?.nilIfEmpty
        ret["type"] = type
        ret["passthrough"] = passthrough?.compactMap { $0.toJsonDictionary().nilIfEmpty }.nilIfEmpty
        ret["events"] = events?.toJsonDictionary()
        
        return ret
    }
}
