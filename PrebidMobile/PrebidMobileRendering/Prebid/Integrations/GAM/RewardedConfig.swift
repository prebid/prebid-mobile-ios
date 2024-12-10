/*   Copyright 2018-2024 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import Foundation

@objc(PBMRewardedConfig) @objcMembers
public class RewardedConfig: NSObject {
    
    // MARK: - Reward
    
    public var reward: PrebidReward? {
        PrebidReward(with: ortbRewarded?.reward)
    }
    
    // MARK: - Banner
    
    public var bannerTime: NSNumber? {
        ortbRewarded?.completion?.banner?.time
    }
    
    public var bannerEvent: String? {
        ortbRewarded?.completion?.banner?.event
    }
    
    // MARK: - Video
    
    public var videoTime: NSNumber? {
        ortbRewarded?.completion?.video?.time
    }
    
    public var videoPlaybackevent: String? {
        ortbRewarded?.completion?.video?.playbackevent
    }
    
    
    // MARK: - Endcard
    
    public var endcardTime: NSNumber? {
        ortbRewarded?.completion?.video?.endcard?.time
    }
    
    public var endcardEvent: String? {
        ortbRewarded?.completion?.video?.endcard?.event
    }
    
    // MARK: - Close
    
    public var closeAction: String? {
        ortbRewarded?.close?.action
    }
    
    public var postRewardTime: NSNumber? {
        ortbRewarded?.close?.postrewardtime
    }
    
    // MARK: - Default Values
    
    /// The timeout duration for rewarded completion, measured in seconds.
    public let defaultCompletionTime: NSNumber = 120
    
    /// The playback event when the SDK should send a signal to the application that the user has earned the reward
    public let defaultVideoPlaybackEvent = "complete"
    
    private let ortbRewarded: PBMORTBRewardedConfiguration?
    
    public init(ortbRewarded: PBMORTBRewardedConfiguration?) {
        self.ortbRewarded = ortbRewarded
    }
}
