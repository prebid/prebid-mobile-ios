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

@objc(PBMORTBBidExtSkadn)
open class ORTBBidExtSkadn: NSObject, PBMJsonCodable {
    /// Version of SKAdNetwork desired. Must be 2.0 or above
    @objc public var version: String?

    /// Ad network identifier used in signature
    @objc public var network: String?

    /// Campaign ID compatible with Apple’s spec
    @objc public var campaign: NSNumber?

    /// A four-digit integer that ad networks define to represent the ad campaign. Used in SKAdNetwork 4.0+,
    /// replaces Campaign ID `campaign`. DSPs must generate signatures in 4.0+ using the Source Identifier.
    @objc public var sourceidentifier: String?

    /// ID of advertiser’s app in Apple’s app store
    @objc public var itunesitem: NSNumber?

    /// ID of publisher’s app in Apple’s app store
    @objc public var sourceapp: NSNumber?

    /// Supports multiple fidelity types introduced in SKAdNetwork v2.2
    @objc public var fidelities: [ORTBSkadnFidelity]?

    /// SKOverlay Support
    @objc public var skoverlay: ORTBBidExtSkadnSKOverlay?

    //Placeholder for exchange-specific extensions to OpenRTB.
    //Note: ext object not supported.

    private enum KeySet: String {
        case version
        case network
        case campaign
        case itunesitem
        case sourceapp
        case sourceidentifier
        case fidelities
        case skoverlay
    }

    @objc public override init() {
        super.init()
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        version             = json[.version]
        network             = json[.network]
        campaign            = json[.campaign]
        itunesitem          = json[.itunesitem]
        sourceapp           = json[.sourceapp]
        sourceidentifier    = json[.sourceidentifier]
        fidelities          = json[.fidelities]
        skoverlay           = json[.skoverlay]
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.version]          = version
        json[.network]          = network
        json[.campaign]         = campaign
        json[.itunesitem]       = itunesitem
        json[.sourceapp]        = sourceapp
        json[.sourceidentifier] = sourceidentifier
        json[.fidelities]       = fidelities
        json[.skoverlay]        = skoverlay

        return json.dict
    }
}
