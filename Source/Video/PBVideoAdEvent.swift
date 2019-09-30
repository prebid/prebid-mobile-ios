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
public final class PBVideoAdEvent: NSObject {

    fileprivate static let adLoadSuccessString = "Ad loading successful"
    fileprivate static let adLoadFailString = "Ad loading failed"
    
    fileprivate static let adStartedString = "Ad playing started"
    fileprivate static let adDidReachEndString = "Ad playing finished"
    
    fileprivate static let adClickedString = "Ad click-through"
    
    /**
     *  Type of the event.
     */
    public let type: PBVideoAdEventType
    
    /**
     *  Stringified type of the event.
     */
    public let typeString: String
    
    init(type: PBVideoAdEventType, typeString: String) {
        self.type = type
        self.typeString = typeString
    }
}

final class VideoAdEventFactory {
    private init() {}
    
    static func getAdLoadSuccess(typeString: String?) -> PBVideoAdEvent {
        return PBVideoAdEvent(type: .AdLoadSuccess, typeString: typeString ?? PBVideoAdEvent.adLoadSuccessString)
    }
    
    static func getAdLoadFail(typeString: String?) -> PBVideoAdEvent {
        return PBVideoAdEvent(type: .AdLoadFail, typeString: typeString ?? PBVideoAdEvent.adLoadFailString)
    }
    
    static func getAdStarted(typeString: String?) -> PBVideoAdEvent {
        return PBVideoAdEvent(type: .AdStarted, typeString: typeString ?? PBVideoAdEvent.adStartedString)
    }
    
    static func getAdDidReachEnd(typeString: String?) -> PBVideoAdEvent {
        return PBVideoAdEvent(type: .AdDidReachEnd, typeString: typeString ?? PBVideoAdEvent.adDidReachEndString)
    }
    
    static func getAdClicked(typeString: String?) -> PBVideoAdEvent {
        return PBVideoAdEvent(type: .AdClicked, typeString: typeString ?? PBVideoAdEvent.adClickedString)
    }
    
}
