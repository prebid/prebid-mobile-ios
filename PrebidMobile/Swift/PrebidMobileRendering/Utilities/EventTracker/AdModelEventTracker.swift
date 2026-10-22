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

@objc(PBMAdModelEventTracker)
class AdModelEventTracker: NSObject, EventTrackerProtocol {
    private(set) weak var creativeModel: CreativeModel?
    let serverConnection: PrebidServerConnectionProtocol
    
    init(creativeModel: CreativeModel, serverConnection: PrebidServerConnectionProtocol) {
        self.creativeModel = creativeModel
        self.serverConnection = serverConnection
    }
    
    func trackEvent(_ event: TrackingEvent) {
        let eventName = event.description
        
        guard let urls = creativeModel?.trackingURLs[eventName] else {
            Log.info("No tracking URL(s) for event \(eventName)")
            return
        }
        
        urls.forEach { url in
            serverConnection.fireAndForget(url)
        }
    }
    
    func trackVideoAdLoaded(_ parameters: VideoVerificationParameters) {
    }
    
    func trackStartVideo(duration: TimeInterval, volume: Double) {
        trackEvent(.start)
    }
    
    func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {
    }
}
