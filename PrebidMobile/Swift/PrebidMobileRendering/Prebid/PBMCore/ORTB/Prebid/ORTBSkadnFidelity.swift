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

@objc public class ORTBSkadnFidelity: NSObject, PBMJsonCodable {
    /// The fidelity-type of the attribution to track
    @objc public var fidelity: NSNumber?

    /// SKAdNetwork signature as specified by Apple
    @objc public var signature: String?

    /// An id unique to each ad response. Refer to Apple’s documentation for the proper UUID format requirements
    @objc public var nonce: UUID?

    /// Unix time in millis string used at the time of signature
    @objc public var timestamp: NSNumber?

    private enum KeySet: String {
        case fidelity
        case nonce
        case timestamp
        case signature
    }

    @objc public override init() {
        super.init()
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        fidelity    = json[.fidelity]
        nonce       = json[.nonce]
        timestamp   = json[.timestamp]
        signature   = json[.signature]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.fidelity]     = fidelity
        json[.nonce]        = nonce
        json[.timestamp]    = timestamp
        json[.signature]    = signature

        return json.dict
    }
}
