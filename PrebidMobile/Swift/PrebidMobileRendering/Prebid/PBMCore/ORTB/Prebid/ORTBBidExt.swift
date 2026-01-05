//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

class ORTBBidExt: PBMJsonCodable {
    
    var prebid: ORTBBidExtPrebid?
    var bidder: [String : Any]?
    var skadn: ORTBBidExtSkadn?
    var nativo: ORTBBidExtNativo?
    
    // This part is dedicating to test server-side ad configurations.
    // Need to be removed when ext.prebid.passthrough will be available.
#if DEBUG
    var passthrough: [ORTBExtPrebidPassthrough]?
#endif

    private enum KeySet: String {
        case prebid
        case bidder
        case skadn
        case nativo
        case passthrough
    }
    
    init() {
    }
    
    required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        prebid  = json[.prebid]
        bidder  = json[.bidder]
        skadn   = json[.skadn]
        nativo  = json[.nativo]
#if DEBUG
        passthrough = json.backwardsCompatiblePassthrough(key: .passthrough)
#endif
    }
    
    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.prebid]   = prebid
        json[.bidder]   = bidder
        json[.skadn]    = skadn
        json[.nativo]   = nativo
#if DEBUG
        json[.passthrough] = passthrough
#endif
        
        return json.dict
    }
}
