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

@objc open class ORTBRewardedReward: NSObject, PBMJsonCodable {
    /// Type of the reward
    @objc public var type: String?

    /// Amount of reward
    @objc public var count: NSNumber?

    /// For the future extensions
    @objc public var ext: [String : Any]?

    private enum KeySet: String {
        case type
        case count
        case ext
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        type    = json[.type]
        count   = json[.count]
        ext     = json[.ext]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.type]     = type
        json[.count]    = count
        json[.ext]      = ext

        return json.dict
    }
}
