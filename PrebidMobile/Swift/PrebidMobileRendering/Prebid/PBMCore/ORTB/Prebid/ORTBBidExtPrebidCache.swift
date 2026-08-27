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

class ORTBBidExtPrebidCache: PBMJsonCodable {
    var key: String?
    var url: String?
    var bids: ORTBBidExtPrebidCacheBids?
    var vastXml: ORTBBidExtPrebidCacheBids?
    
    var hasSuccessfulServerCache: Bool {
        (bids?.hasCacheData ?? false) || (vastXml?.hasCacheData ?? false)
    }

    private enum KeySet: String {
        case url
        case key
        case bids
        case vastXml
        case vastxml
    }
    
    init() {
    }
    
    required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        url     = json[.url]
        key     = json[.key]
        bids    = json[.bids]
        vastXml = json[.vastXml]
        // PBS uses "vastxml" in cache requests and may return it in responses, while older/typed models use "vastXml".
        if vastXml?.hasCacheData != true {
            vastXml = json[.vastxml]
        }
    }
    
    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.key]  = key
        json[.url]  = url
        json[.bids] = bids
        json[.vastXml] = vastXml

        return json.dict
    }
}
