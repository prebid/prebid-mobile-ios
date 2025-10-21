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

@objc open class ORTBRewardedConfiguration: NSObject, PBMJsonCodable {
    /// Metadata provided by the publisher to describe the reward.
    @objc public var reward: ORTBRewardedReward?

    /// Describes the condition when the SDK should send a signal to the application that the user has earned the reward.
    @objc public var completion: ORTBRewardedCompletion?

    /// Describes the close behavior. How should the SDK manage the ad when it is encountered as viewed.
    @objc public var close: ORTBRewardedClose?

    private enum KeySet: String {
        case reward
        case completion
        case close
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        reward      = json[.reward]
        completion  = json[.completion]
        close       = json[.close]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.reward]       = reward
        json[.completion]   = completion
        json[.close]        = close

        return json.dict
    }
}
