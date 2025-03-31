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
public class PBMORTBRewardedConfiguration: PBMORTBAbstract {
    /// Metadata provided by the publisher to describe the reward.
    public var reward: PBMORTBRewardedReward?

    /// Describes the condition when the SDK should send a signal to the application that the user has earned the reward.
    public var completion: PBMORTBRewardedCompletion?

    /// Describes the close behavior. How should the SDK manage the ad when it is encountered as viewed.
    public var close: PBMORTBRewardedClose?
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        reward = jsonDictionary.entity(key: "reward")
        completion = jsonDictionary.entity(key: "completion")
        close = jsonDictionary.entity(key: "close")
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["reward"] = reward?.toJsonDictionary().nilIfEmpty
        ret["completion"] = completion?.toJsonDictionary().nilIfEmpty
        ret["close"] = close?.toJsonDictionary().nilIfEmpty
        
        return ret
    }
}
