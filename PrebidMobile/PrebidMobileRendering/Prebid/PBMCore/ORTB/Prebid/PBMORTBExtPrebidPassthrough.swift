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

@objcMembers
public class PBMORTBExtPrebidPassthrough: PBMORTBAbstract {
    public var type: String?
    public var adConfiguration: PBMORTBAdConfiguration?
    public var sdkConfiguration: PBMORTBSDKConfiguration?
    public var rewardedConfiguration: PBMORTBRewardedConfiguration?
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        
        type = jsonDictionary[key: "type"]
        adConfiguration = jsonDictionary.entity(key: "adconfiguration")
        sdkConfiguration = jsonDictionary.entity(key: "sdkconfiguration")
        rewardedConfiguration = jsonDictionary.entity(key: "rwdd")
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["type"] = type
        ret["adconfiguration"] = adConfiguration?.toJsonDictionary().nilIfEmpty
        ret["sdkconfiguration"] = sdkConfiguration?.toJsonDictionary().nilIfEmpty
        ret["rwdd"] = rewardedConfiguration?.toJsonDictionary().nilIfEmpty
        
        return ret
    }
}
