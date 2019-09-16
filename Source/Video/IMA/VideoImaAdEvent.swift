/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

@objcMembers
public final class VideoImaAdEvent: NSObject {

    fileprivate static let adLoadSuccessString = "Ad loading successful"
    fileprivate static let adLoadFailString = "Ad loading failed"
    
    fileprivate static let adStartedString = "Ad playing started"
    fileprivate static let adDidReachEndString = "Ad playing finished"
    
    fileprivate static let adClickedString = "Ad click-through"
    fileprivate static let adImpressionString = "Impression"
    
    static let adRewardedCompletedString = "Rewarded video finished"
    static let adRewardedCancelledString = "Rewarded video canceled"
    
    static let adInternalErrorString = "Internal error occurred"
    
    /**
     *  Type of the event.
     */
    public let type: VideoImaAdEventType
    
    /**
     *  Stringified type of the event.
     */
    public let typeString: String
    
    init(type: VideoImaAdEventType, typeString: String) {
        self.type = type
        self.typeString = typeString
    }
}

final class VideoImaAdEventFactory {
    private init() {}
    
    static func getAdLoadSuccess(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdLoadSuccess, typeString: typeString ?? VideoImaAdEvent.adLoadSuccessString)
    }
    
    static func getAdLoadFail(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdLoadFail, typeString: typeString ?? VideoImaAdEvent.adLoadFailString)
    }
    
    static func getAdStarted(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdStarted, typeString: typeString ?? VideoImaAdEvent.adStartedString)
    }
    
    static func getAdDidReachEnd(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdDidReachEnd, typeString: typeString ?? VideoImaAdEvent.adDidReachEndString)
    }
    
    static func getAdClicked(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdClicked, typeString: typeString ?? VideoImaAdEvent.adClickedString)
    }
    
    static func getAdImpression(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdImpression, typeString: typeString ?? VideoImaAdEvent.adImpressionString)
    }
    
    static func getAdRewardedCompleted(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdRewardedCompleted, typeString: typeString ?? VideoImaAdEvent.adRewardedCompletedString)
    }
    
    static func getAdRewardedCancelled(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdRewardedCancelled, typeString: typeString ?? VideoImaAdEvent.adRewardedCancelledString)
    }
    
    static func getAdInternalError(typeString: String?) -> VideoImaAdEvent{
        return VideoImaAdEvent(type: .AdInternalError, typeString: typeString ?? VideoImaAdEvent.adInternalErrorString)
    }
}
