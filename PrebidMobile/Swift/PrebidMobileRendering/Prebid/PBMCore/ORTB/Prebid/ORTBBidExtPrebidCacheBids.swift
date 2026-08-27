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

class ORTBBidExtPrebidCacheBids: PBMJsonCodable {
    var url: String?
    var cacheId: String?
    
    // cacheId is the field PUC actually needs to retrieve a creative from Prebid Cache
    // (GET /cache?uuid=<cacheId>, surfaced to the creative via the hb_cache_id targeting
    // key). `url` is only a pre-assembled convenience string built from cacheId plus the
    // cache host/path; it is never consumed independently, so it does not count on its own.
    // See https://docs.prebid.org/prebid-server/endpoints/pbs-endpoints-pbc.html and
    // https://docs.prebid.org/prebid-server/use-cases/pbs-sdk.html.
    var hasCacheData: Bool {
        !(cacheId?.isEmpty ?? true)
    }

    private enum KeySet: String {
        case url
        case cacheId
    }
    
    init() {
    }

    required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        url     = json[.url]
        cacheId = json[.cacheId]
    }
    
    var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.url]      = url
        json[.cacheId]  = cacheId

        return json.dict
    }
}
