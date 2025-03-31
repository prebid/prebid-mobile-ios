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
@objcMembers
public class PBMORTBRewardedCompletion: PBMORTBAbstract {
    public var banner: PBMORTBRewardedCompletionBanner?
    public var video: PBMORTBRewardedCompletionVideo?
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        banner = jsonDictionary.entity(key: "banner")
        video = jsonDictionary.entity(key: "video")
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["banner"] = banner?.toJsonDictionary().nilIfEmpty
        ret["video"] = video?.toJsonDictionary().nilIfEmpty
        
        return ret
    }
}
