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

/// Metadata provided by the publisher to describe the reward
@objcMembers
public class PBMORTBRewardedReward: PBMORTBAbstract {
    /// Type of the reward
    public var type: String?

    /// Amount of reward
    public var count: NSNumber?

    /// For the future extensions
    public var ext: [String : Any]?
    
    private enum KeySet: String {
        case type
        case count
        case ext
    }
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        type = json[.type]
        count = json[.count]
        ext = json[.ext]
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.type] = type
        json[.count] = count
        json[.ext] = ext
        
        return json.dict
    }
}
