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

@objc open class ORTBExtPrebidPassthrough: NSObject, PBMJsonCodable {
    @objc public var type: String?
    @objc public var adConfiguration: ORTBAdConfiguration?
    @objc public var sdkConfiguration: ORTBSDKConfiguration?
    @objc public var rewardedConfiguration: ORTBRewardedConfiguration?

    private enum KeySet: String {
        case type
        case adconfiguration
        case sdkconfiguration
        case rwdd
    }

    @objc public override init() {
        super.init()
    }

    @objc public required init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)

        type = json[.type]
        adConfiguration         = json[.adconfiguration]
        sdkConfiguration        = json[.sdkconfiguration]
        rewardedConfiguration   = json[.rwdd]

        super.init()
    }
    
    @objc public var jsonDictionary: [String : Any] {
        var json = JSONObject<KeySet>()

        json[.type]             = type
        json[.adconfiguration]  = adConfiguration
        json[.sdkconfiguration] = sdkConfiguration
        json[.rwdd]             = rewardedConfiguration

        return json.dict
    }
}
