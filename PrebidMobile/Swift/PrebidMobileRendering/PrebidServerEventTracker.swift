/*   Copyright 2018-2021 Prebid.org, Inc.

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

import UIKit

class PrebidServerEventTracker: NSObject, EventTrackerProtocol {
    
    private(set) var serverEvents = [ServerEvent]()
    
    init(serverEvents: [ServerEvent] = []) {
        self.serverEvents = serverEvents
    }
    
    func trackEvent(_ event: TrackingEvent) {
        for serverEvent in serverEvents {
            if serverEvent.expectedEventType == event {
                PrebidServerConnection.shared.fireAndForget(serverEvent.url)
            }
        }
    }
    
    func trackVideoAdLoaded(_ parameters: VideoVerificationParameters) {}
    
    func trackStartVideo(duration: TimeInterval, volume: Double) {}
    
    func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {}
    
    func addServerEvents(_ serverEvents: [ServerEvent]) {
        self.serverEvents.append(contentsOf: serverEvents)
    }
}
