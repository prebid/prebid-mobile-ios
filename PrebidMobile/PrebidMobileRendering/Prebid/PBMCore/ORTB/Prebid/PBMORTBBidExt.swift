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

class PBMORTBBidExt: PBMJsonCodable {
    
    var prebid: PBMORTBBidExtPrebid?
    var bidder: [String : Any]?
    var skadn: PBMORTBBidExtSkadn?
    
    // This part is dedicating to test server-side ad configurations.
    // Need to be removed when ext.prebid.passthrough will be available.
#if DEBUG
    var passthrough: [PBMORTBExtPrebidPassthrough]?
#endif
    
    private enum KeySet: String {
        case prebid
        case bidder
        case skadn
        case passthrough
    }
    
    init() {
    }
    
    required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        prebid      = json[.prebid]
        bidder      = json[.bidder]
        skadn       = json[.skadn]
#if DEBUG
        passthrough = json.backwardsCompatiblePassthrough(key: .passthrough)
#endif
    }
    
    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.prebid] = prebid
        json[.bidder] = bidder
        json[.skadn] = skadn
#if DEBUG
        json[.passthrough] = passthrough
#endif
        
        return json.dict
    }
}
