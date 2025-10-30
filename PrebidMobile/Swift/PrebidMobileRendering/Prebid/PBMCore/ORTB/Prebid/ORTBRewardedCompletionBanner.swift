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

@objc public class ORTBRewardedCompletionBanner: NSObject, PBMJsonCodable {
    /// The period of time that the ad is on the screen and the user earns a reward
    @objc public var time: NSNumber?

    /// The URL with a custom schema that will be sent by the creative and should be caught by the SDK
    @objc public var event: String?

    private enum KeySet: String {
        case time
        case event
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        time    = json[.time]
        event   = json[.event]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.time]     = time
        json[.event]    = event

        return json.dict
    }
}
