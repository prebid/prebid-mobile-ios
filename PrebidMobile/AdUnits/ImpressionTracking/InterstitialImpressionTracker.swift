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

import WebKit

/// Schedules an observer for interstitial views and, upon detection, activates the viewability tracker.
class InterstitialImpressionTracker: PrebidImpressionTrackerProtocol {
    
    private var interstitialObserver: InterstitialObserver?
    private var viewabilityTracker: PBMCreativeViewabilityTracker?
    
    private var payload: PrebidImpressionTrackerPayload?
    
    private var pollingInterval: TimeInterval {
        0.2
    }
    
    func start(in view: UIView) {
        interstitialObserver = InterstitialObserver(window: view as? UIWindow) { [weak self] view in
            self?.attachViewabilityTracker(to: view)
        }
        
        interstitialObserver?.start()
    }
    
    func stop() {
        interstitialObserver?.stop()
        viewabilityTracker?.stop()
    }
    
    private func attachViewabilityTracker(to view: UIView) {
        viewabilityTracker = PBMCreativeViewabilityTracker(
            view: view,
            pollingTimeInterval: pollingInterval,
            onExposureChange: { [weak self, weak view] _, viewExposure in
                guard let self, let view else { return }
                
                if viewExposure.exposureFactor > 0 {
                    self.stop()
                    
                    // Ensure that we found Prebid creative
                    AdViewUtils.findPrebidCacheID(view) { result in
                        switch result {
                        case .success(let foundCacheID):
                            if let trackingURLs = self.payload?.trackingURLs,
                               let creativeCacheID = self.payload?.cacheID,
                               foundCacheID == creativeCacheID {
                                for trackingURL in trackingURLs {
                                    PrebidServerConnection.shared.fireAndForget(trackingURL)
                                }
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
    
    func register(payload: PrebidImpressionTrackerPayload) {
        self.payload = payload
    }
}
