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

/// Schedules reload tracker and every time GAM banner view reloads => fires viewability tracker.
class BannerViewImpressionTracker {
    
    private var bannerViewReloadTracker: BannerViewReloadTracker?
    private var viewabilityTracker: PBMCreativeViewabilityTracker?
    
    private weak var view: UIView?
    
    private var isImpressionTracked = false
    
    private var defaultPollingTimeInterval: TimeInterval {
        0.2
    }
    
    init(view: UIView? = nil) {
        self.view = view
    }
    
    func start() {
        initAdViewReloadTracker()
    }
    
    func stop() {
        bannerViewReloadTracker?.stop()
        viewabilityTracker?.stop()
    }
    
    private func initAdViewReloadTracker() {
        guard let view else { return }
        
        bannerViewReloadTracker = BannerViewReloadTracker(in: view) { [weak self] in
            self?.isImpressionTracked = false
            self?.initViewabilityTracker()
        }
        
        bannerViewReloadTracker?.start()
    }
    
    private func initViewabilityTracker() {
        guard let view else { return }
        
        viewabilityTracker = PBMCreativeViewabilityTracker(
            view: view,
            pollingTimeInterval: defaultPollingTimeInterval,
            onExposureChange: { [weak self] tracker, viewExposure in
                guard let self = self else { return }
                
                if !self.isImpressionTracked {
                    print("LOG: \(viewExposure), exposedPercentage: \(viewExposure.exposedPercentage)")
                }
                
                if viewExposure.exposedPercentage > 0, !self.isImpressionTracked {
                    // Stop tracker
                    self.viewabilityTracker?.stop()
                    
                    self.isImpressionTracked = true
                    
                    // TODO: Track burl
                }
            }
        )
        
        viewabilityTracker?.start()
    }
}
