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

/// Describes the condition when the SDK should send a signal to the application that the user has earned the reward.
@objc open class ORTBRewardedCompletion: NSObject, PBMJsonCodable {
    @objc public var banner: ORTBRewardedCompletionBanner?
    @objc public var video: ORTBRewardedCompletionVideo?

    private enum KeySet: String {
        case banner
        case video
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        banner = json[.banner]
        video = json[.video]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.banner] = banner
        json[.video] = video

        return json.dict
    }
}
