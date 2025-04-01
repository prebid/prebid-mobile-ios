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
    
    private enum KeySet: String {
        case bidder
        case prebid
        case skadn
        case passthrough
    }
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        bidder = json[.bidder]
        prebid = json[.prebid]
        skadn = json[.skadn]
#if DEBUG
        passthrough = json.backwardsCompatiblePassthrough(key: .passthrough)
#endif
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.bidder] = bidder
        json[.prebid] = prebid
        json[.skadn] = skadn
#if DEBUG
        json[.passthrough] = passthrough
#endif
        
        return json.dict
    }
}
