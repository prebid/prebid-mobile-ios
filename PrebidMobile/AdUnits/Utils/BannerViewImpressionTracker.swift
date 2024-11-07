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
    
    private var trackingURL: String?
    
    private var isImpressionTracked = false
    
    private var pollingInterval: TimeInterval {
        0.2
    }
    
    init() {
        reloadTracker = BannerViewReloadTracker(
            reloadCheckInterval: pollingInterval
        ) { [weak self] in
            self?.isImpressionTracked = false
            self?.initViewabilityTracker()
        }
    }
    
    func start(in view: UIView?, trackingURL: String?) {
        self.monitoredView = view
        self.trackingURL = trackingURL
        reloadTracker?.start(in: view)
    }
    
    func stop() {
        reloadTracker?.stop()
        viewabilityTracker?.stop()
    }
    
    private func initViewabilityTracker() {
        guard let monitoredView else { return }
        
        viewabilityTracker = PBMCreativeViewabilityTracker(
            view: monitoredView,
            pollingTimeInterval: pollingInterval,
            onExposureChange: { [weak self] _, viewExposure in
                guard let self = self else { return }
                
                if viewExposure.exposureFactor > 0 && !self.isImpressionTracked {
                    self.viewabilityTracker?.stop()
                    self.isImpressionTracked = true
                    
                    if let trackingURL {
                        PrebidServerConnection.shared.fireAndForget(trackingURL)
                    }
                }
            }
        )
        
        viewabilityTracker?.start()
    }
}
