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

/// Schedules the reload tracker to monitor the GAM banner view.
/// Each time the banner view reloads, the viewability tracker is triggered.
class BannerViewImpressionTracker {
    
    private weak var monitoredView: UIView?
    
    private var reloadTracker: BannerViewReloadTracker?
    private var viewabilityTracker: PBMCreativeViewabilityTracker?
    
    /// seatbid.bid.burl
    private var trackingURL: String?
    
    /// seatbid.bid.ext.prebid.targeting.hb_cache_id
    private var creativeCacheID: String?
    
    private var isImpressionTracked = false
    
    private var pollingInterval: TimeInterval {
        0.2
    }
    
    init() {
        reloadTracker = BannerViewReloadTracker(
            reloadCheckInterval: pollingInterval
        ) { [weak self] in
            self?.isImpressionTracked = false
            self?.attachViewabilityTracker()
        }
    }
    
    func start(in view: UIView?, trackingURL: String?, creativeCacheID: String?) {
        self.monitoredView = view
        self.trackingURL = trackingURL
        self.creativeCacheID = creativeCacheID
        reloadTracker?.start(in: view)
    }
    
    func stop() {
        reloadTracker?.stop()
        viewabilityTracker?.stop()
    }
    
    private func attachViewabilityTracker() {
        guard let monitoredView else { return }
        
        viewabilityTracker = PBMCreativeViewabilityTracker(
            view: monitoredView,
            pollingTimeInterval: pollingInterval,
            onExposureChange: { [weak self, weak monitoredView] _, viewExposure in
                guard let self = self, let monitoredView else { return }
                
                if viewExposure.exposureFactor > 0 && !self.isImpressionTracked {
                    self.viewabilityTracker?.stop()
                    self.isImpressionTracked = true
                    
                    // Ensure that we found Prebid creative
                    AdViewUtils.findPrebidCacheID(monitoredView) { result in
                        switch result {
                        case .success(let foundCacheID):
                            if let trackingURL = self.trackingURL, foundCacheID == self.creativeCacheID {
                                PrebidServerConnection.shared.fireAndForget(trackingURL)
                            }
                        case .failure(let error):
                            Log.warn(error.localizedDescription)
                        }
                    }
                }
            }
        )
        
        viewabilityTracker?.start()
    }
}
