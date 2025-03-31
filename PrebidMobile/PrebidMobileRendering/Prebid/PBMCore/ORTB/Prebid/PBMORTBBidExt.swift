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
public class PBMORTBBidExt: PBMORTBAbstract {
    public var prebid: PBMORTBBidExtPrebid?
    public var bidder: [String : Any]?
    public var skadn: PBMORTBBidExtSkadn?

    // This part is dedicating to test server-side ad configurations.
    // Need to be removed when ext.prebid.passthrough will be available.
#if DEBUG
    public var passthrough: [PBMORTBExtPrebidPassthrough]?
#endif
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        bidder = jsonDictionary[key: "bidder"]
        prebid = jsonDictionary.entity(key: "prebid")
        skadn = jsonDictionary.entity(key: "skadn")
#if DEBUG
        passthrough = jsonDictionary.passthroughObjects(key: "passthrough")
#endif
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["bidder"] = bidder
        ret["prebid"] = prebid?.toJsonDictionary().nilIfEmpty
        ret["skadn"] = skadn?.toJsonDictionary().nilIfEmpty
#if DEBUG
        ret["passthrough"] = passthrough?.compactMap { $0.toJsonDictionary() }.nilIfEmpty
#endif
        
        return ret
    }
}
