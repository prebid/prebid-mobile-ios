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

import UIKit

class PrebidImpressionTracker {
    
    /// Payload for impression trackers.
    struct Payload {
        
        /// seatbid.bid.ext.prebid.targeting.hb_cache_id.
        /// Used to identify if SDK found Prebid creative.
        let cacheID: String?
    }
    
    private let tracker: PrebidImpressionTrackerProtocol
    
    init(isInterstitial: Bool) {
        if isInterstitial {
            tracker = InterstitialImpressionTracker()
        } else {
            tracker = BannerViewImpressionTracker()
        }
    }
    
    func register(payload: PrebidImpressionTracker.Payload) {
        tracker.register(payload: payload)
    }
    
    func register(eventManager: EventManager) {
        tracker.register(eventManager: eventManager)
    }
  
    func start(in adView: UIView) {
        DispatchQueue.main.async {
            self.tracker.start(in: adView)
        }
    }
    
    func stop() {
        tracker.stop()
    }
}
