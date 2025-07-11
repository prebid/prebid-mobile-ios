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

//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md

@objc public class ORTBBidExtSkadnSKOverlay: NSObject, PBMJsonCodable {
    /// Delay before presenting SKOverlay in seconds, required for overlay to be shown
    @objc public var delay: NSNumber?

    /// Delay before presenting SKOverlay on an endcard in seconds, required for overlay to be shown
    @objc public var endcarddelay: NSNumber?

    /// Whether overlay can be dismissed by user, 0 = no, 1 = yes
    @objc public var dismissible: NSNumber?

    /// Position of the overlay, 0 = bottom, 1 = bottom raised
    @objc public var pos: NSNumber?

    private enum KeySet: String {
        case delay
        case endcarddelay
        case dismissible
        case pos
    }

    @objc public override init() {
        super.init()
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        delay           = json[.delay]
        endcarddelay    = json[.endcarddelay]
        dismissible     = json[.dismissible]
        pos             = json[.pos]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.delay]        = delay
        json[.endcarddelay] = endcarddelay
        json[.dismissible]  = dismissible
        json[.pos]          = pos

        return json.dict
    }
}
