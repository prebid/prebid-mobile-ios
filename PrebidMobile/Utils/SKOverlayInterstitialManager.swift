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
import WebKit

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
                        self?.attemptFindUUID(in: view)
                        return
                    }
                    
                    guard let bidString = CacheManager.shared.get(cacheId: cacheID) else {
                        Log.error("SDK could not find the bid response for provided cache id.")
                        return
                    }
                    
                    self?.presentSKOverlay(using: bidString, in: view)
                }
            })
        
        interstitialObserver?.start()
    }
    
    func dismiss() {
        skOverlayManager?.dismissSKOverlay()
        interstitialObserver = nil
        skOverlayManager = nil
    }
    
    /// Mainly used for video creatives. Searches for **hb_uuid** keys from saved bids in third-party web views.
    private func attemptFindUUID(in adView: UIView) {
        guard let webView = adView.allSubViewsOf(type: WKWebView.self).first else {
            return
        }
        
        webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { html, error in
            guard let html = html as? String else {
                return
            }
            
            CacheManager.shared
                .savedValuesDict
                .values
                .forEach { [weak self] value in
                    if let bid = Bid.bid(from: value),
                       let hbUUID = bid.targetingInfo?["hb_uuid"],
                       html.contains(hbUUID) {
                        self?.presentSKOverlay(using: bid, in: adView)
                    }
                }
        })
    }
    
    private func presentSKOverlay(using bidString: String, in adView: UIView) {
        guard let bid = Bid.bid(from: bidString) else {
            Log.error("Error parsing bid string.")
            return
        }
        
        presentSKOverlay(using: bid, in: adView)
    }
    
    private func presentSKOverlay(using bid: Bid, in adView: UIView) {
        guard let skadn = bid.skadn, skadn.skoverlay != nil else {
            Log.error("Bid response doesn't contain SKAdN configuration.")
            return
        }
        
        guard let viewController = adView.parentViewController else {
            Log.error("SDK couln't find a view controller that can present SKOverlay.")
            return
        }
        
        skOverlayManager = SKOverlayManager(viewControllerForPresentation: viewController)
        
        // NOTE: It was decided to not support `endcarddelay` in the Original API.
        // If `delay` is present, the SDK will use it, otherwise SKOverlay will be displayed immediately.
        skOverlayManager?.presentSKOverlay(with: skadn, isCompanionAd: false)
    }
}
