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
class InterstitialImpressionTracker {
    
    private var interstitialObserver: InterstitialObserver?
    private var viewabilityTracker: PBMCreativeViewabilityTracker?
    
    private var pollingInterval: TimeInterval {
        0.2
    }
    
    func start(withTrackingURL trackingURL: String?) {
        interstitialObserver = InterstitialObserver { [weak self] view in
            guard let self = self else { return }
            
            self.viewabilityTracker = PBMCreativeViewabilityTracker(
                view: view,
                pollingTimeInterval: self.pollingInterval,
                onExposureChange: { [weak self] _, viewExposure in
                    guard let self else { return }
                    
                    if viewExposure.exposureFactor > 0 {
                        print("LOG: \(viewExposure), exposedPercentage: \(viewExposure.exposedPercentage)")
                        self.stop()
                        
                        if let trackingURL {
                            PrebidServerConnection.shared.fireAndForget(trackingURL)
                        }
                    }
                }
            )
            
            self.viewabilityTracker?.start()
        }
        
        interstitialObserver?.start()
    }
    
    func stop() {
        interstitialObserver?.stop()
        viewabilityTracker?.stop()
    }
}
