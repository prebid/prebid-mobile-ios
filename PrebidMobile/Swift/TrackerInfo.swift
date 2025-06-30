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
    var expired = false
    var numberOfTimesFired = 0
    private var expirationTimer : Timer?
    private static let trackerExpirationInterval : TimeInterval = 3600
    
    init(URL: String) {
        self.URL = URL
        self.dateCreated = Date()
        super.init()
        createExpirationTimer()
    }
    func createExpirationTimer(){
        expirationTimer = Timer.scheduledTimer(withTimeInterval: TrackerInfo.trackerExpirationInterval, repeats: false, block: { [weak self] timer in
            timer.invalidate()
            guard let strongSelf = self else {
                Log.debug("FAILED TO ACQUIRE strongSelf for TrackerInfo")
                return
            }
            strongSelf.expired = true
        })
    }
    
    deinit {
        expirationTimer?.invalidate()
    }
}
