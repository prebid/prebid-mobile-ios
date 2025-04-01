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
public class PBMORTBRewardedCompletionVideo: PBMORTBAbstract {
    /// The period of time that the ad is on the screen and the user earns a reward
    public var time: NSNumber?

    /// The playback part when the user earns a reward
    public var playbackevent: String?

    /// Endcard completion criteria
    public var endcard: PBMORTBRewardedCompletionVideoEndcard?
    
    private enum KeySet: String {
        case time
        case playbackevent
        case endcard
    }
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        let json = JSONObject<KeySet>(jsonDictionary)
        
        time = json[.time]
        playbackevent = json[.playbackevent]
        endcard = json[.endcard]
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var json = JSONObject<KeySet>()
        
        json[.time] = time
        json[.playbackevent] = playbackevent
        json[.endcard] = endcard
        
        return json.dict
    }
}
