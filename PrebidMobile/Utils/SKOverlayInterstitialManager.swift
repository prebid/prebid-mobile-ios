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

/// Manager that helps with displaying SKOverlay in Original API interstitials
class SKOverlayInterstitialManager {
    
    private var interstitialObserver: InterstitialObserver?
    private var skOverlayManager: SKOverlayManager?
    
    func tryToShow() {
        interstitialObserver = InterstitialObserver(
            window: UIWindow.firstKeyWindow,
            onTargetInterstitialPresented: { [weak self] view in
                self?.interstitialObserver?.stop()
                
                AdViewUtils.findPrebidLocalCacheID(view) { [weak self] result in
                    guard case .success(let cacheID) = result else {
                        return
                    }
                    
                    guard let bidString = CacheManager.shared.get(cacheId: cacheID) else {
                        Log.error("SDK could not find the bid response for provided cache id.")
                        return
                    }
                    
                    guard let bid = Bid.bid(from: bidString) else {
                        Log.error("Error parsing bid string.")
                        return
                    }
                    
                    guard let skadn = bid.skadn, skadn.skoverlay != nil else {
                        Log.error("Bid response doesn't contain SKAdN configuration.")
                        return
                    }
                    
                    guard let viewController = view.parentViewController else {
                        Log.error("SDK couln't find a view controller that can present SKOverlay.")
                        return
                    }
                    
                    self?.skOverlayManager = SKOverlayManager(viewControllerForPresentation: viewController)
                    
                    // TODO: Determine if companion ad is present
                    self?.skOverlayManager?.presentSKOverlay(with: skadn, isCompanionAd: false)
                }
            })
        
        interstitialObserver?.start()
    }
    
    func dismiss() {
        skOverlayManager?.dismissSKOverlay()
        interstitialObserver = nil
        skOverlayManager = nil
    }
}
