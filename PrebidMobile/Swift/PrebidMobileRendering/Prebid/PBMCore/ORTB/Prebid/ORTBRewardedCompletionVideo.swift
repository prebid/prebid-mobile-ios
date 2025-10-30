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

@objc public class ORTBRewardedCompletionVideo: NSObject, PBMJsonCodable {
    /// The period of time that the ad is on the screen and the user earns a reward
    @objc public var time: NSNumber?

    /// The playback part when the user earns a reward
    @objc public var playbackevent: String?

    /// Endcard completion criteria
    @objc public var endcard: ORTBRewardedCompletionVideoEndcard?

    private enum KeySet: String {
        case time
        case playbackevent
        case endcard
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        time            = json[.time]
        playbackevent   = json[.playbackevent]
        endcard         = json[.endcard]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.time]             = time
        json[.playbackevent]    = playbackevent
        json[.endcard]          = endcard

        return json.dict
    }
}
