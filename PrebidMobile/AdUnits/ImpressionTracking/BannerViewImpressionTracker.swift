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
class BannerViewImpressionTracker: PrebidImpressionTrackerProtocol {
    
    private weak var monitoredView: UIView?
    
    private var reloadTracker: BannerViewReloadTracker?
    private var viewabilityTracker: CreativeViewabilityTracker?
    
    private var eventManager: EventManager?
    private var payload: PrebidImpressionTracker.Payload?
    
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
    
    func start(in view: UIView) {
        self.monitoredView = view
        reloadTracker?.start(in: view)
    }
    
    func stop() {
        reloadTracker?.stop()
        viewabilityTracker?.stop()
        payload = nil
        eventManager = nil
    }
    
    private func attachViewabilityTracker() {
        guard let monitoredView else { return }
        
        viewabilityTracker = Factory.PBMCreativeViewabilityTracker(
            view: monitoredView,
            pollingTimeInterval: pollingInterval,
            onExposureChange: { [weak self, weak monitoredView] _, viewExposure in
                guard let self = self, let monitoredView else { return }
                
                if viewExposure.exposureFactor > 0 && !self.isImpressionTracked {
                    self.viewabilityTracker?.stop()
                    self.isImpressionTracked = true
                    
                    // Ensure that we found Prebid creative
                    AdViewUtils.findPrebidCacheID(monitoredView) { [weak self] result in
                        guard let self = self, let eventManager = self.eventManager else { return }
                        
                        switch result {
                        case .success(let foundCacheID):
                            if let creativeCacheID = self.payload?.cacheID, foundCacheID == creativeCacheID {
                                eventManager.trackEvent(.impression)
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
    
    func register(payload: PrebidImpressionTracker.Payload) {
        self.payload = payload
    }
    
    func register(eventManager: EventManager) {
        self.eventManager = eventManager
    }
}
