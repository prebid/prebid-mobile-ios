/*   Copyright 2019-2020 Prebid.org, Inc.

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

class TrackerInfo: NSObject {

    var URL : String?
    var dateCreated : Date?
    private(set) var expired = false
    var numberOfTimesFired = 0
    private var expirationTimer : Timer?
    static let trackerExpirationInterval : TimeInterval = 3600
    
    /// - Parameter scheduleExpirationTimer: Schedules the one-shot timer that marks the tracker expired after
    ///   `trackerExpirationInterval`. The tracker manager creates a tracker on the main thread when it first enters
    ///   the retry queue, so the timer runs on the main run loop; retries keep the same tracker and its timer.
    init(URL: String, scheduleExpirationTimer: (TimeInterval, @escaping (Timer) -> Void) -> Timer) {
        self.URL = URL
        self.dateCreated = Date()
        super.init()
        createExpirationTimer(scheduleExpirationTimer)
    }
    private func createExpirationTimer(_ scheduleExpirationTimer: (TimeInterval, @escaping (Timer) -> Void) -> Timer){
        expirationTimer = scheduleExpirationTimer(TrackerInfo.trackerExpirationInterval) { [weak self] timer in
            timer.invalidate()
            guard let strongSelf = self else {
                Log.debug("FAILED TO ACQUIRE strongSelf for TrackerInfo")
                return
            }
            strongSelf.expired = true
        }
    }
    
    deinit {
        expirationTimer?.invalidate()
    }
}
