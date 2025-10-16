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

/// Describes the close behavior. How should the SDK manage the ad when it is encountered as viewed
@objc open class ORTBRewardedClose: NSObject, PBMJsonCodable {
    /// The time interval in seconds passed after the reward event when SDK should close the interstitial
    @objc public var postrewardtime: NSNumber?

    /// The action that SDK should do.
    ///
    /// Available options:
    /// - autoclose - close the interstitial;
    /// - closebutton - show the close button.
    @objc public var action: String?

    private enum KeySet: String {
        case postrewardtime
        case action
    }

    @objc public override init() {
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        postrewardtime  = json[.postrewardtime]
        action          = json[.action]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.postrewardtime]   = postrewardtime
        json[.action]           = action

        return json.dict
    }
}
