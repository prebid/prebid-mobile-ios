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
@objcMembers
public class PBMORTBRewardedClose: PBMORTBAbstract {
    /// The time interval in seconds passed after the reward event when SDK should close the interstitial
    public var postrewardtime: NSNumber?

    /// The action that SDK should do.
    ///
    /// Available options:
    /// - autoclose - close the interstitial;
    /// - closebutton - show the close button.
    public var action: String?
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        postrewardtime = jsonDictionary[key: "postrewardtime"]
        action = jsonDictionary[key: "action"]
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["postrewardtime"] = postrewardtime
        ret["action"] = action
        
        return ret
    }
}
