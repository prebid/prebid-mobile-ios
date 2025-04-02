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
open class PBMORTBRewardedCompletion: PBMORTBAbstract {
    public var banner: PBMORTBRewardedCompletionBanner?
    public var video: PBMORTBRewardedCompletionVideo?
    
    private enum KeySet: String {
        case banner
        case video
    }
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        banner = json[.banner]
        video = json[.video]
        
        super.init()
    }
    
    open override func toJsonDictionary() -> [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.banner] = banner
        json[.video] = video
        
        return json.dict
    }
}
