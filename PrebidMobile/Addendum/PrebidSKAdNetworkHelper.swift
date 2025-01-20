/*   Copyright 2018-2025 Prebid.org, Inc.
 
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
import StoreKit

/// This class provides utilities for tracking ad clicks and presenting the SKStoreProductViewController
@objcMembers
public class PrebidSKAdNetworkHelper: NSObject {
    
    private weak var adView: UIView?
    private weak var viewControllerForPresentingModals: UIViewController?
    
    /// Subscribes to ad click events on the provided ad view and configures it with SKAdN tracking..
    /// - Parameters:
    ///   - adView: The ad view where click events will be tracked.
    ///   - viewController: The view controller used to present modals, such as the SKStoreProductViewController.
    public func subscribeOnAdClicked(adView: UIView, viewController: UIViewController) {
        self.adView = adView
        self.viewControllerForPresentingModals = viewController
        
        AdViewUtils.findPrebidLocalCacheID(adView) { [weak self] result in
            guard case .success(let cacheID) = result else {
                self?.attemptFindUUID()
                return
            }
            
            guard let bidString = CacheManager.shared.get(cacheId: cacheID) else {
                Log.warn("SDK could not find the bid response for provided cache id.")
                return
            }
            
            self?.configureAdViewWithSkadn(using: bidString)
        }
    }
    
    /// Mainly used for video creatives. Searches for **hb_uuid** keys from saved bids in third-party web views.
    private func attemptFindUUID() {
        guard let adView = adView,
              let webView = adView.allSubViewsOf(type: WKWebView.self).first else {
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
                        self?.configureAdViewWithSkadn(using: bid)
                    }
                }
        })
    }
    
    private func configureAdViewWithSkadn(using bidString: String) {
        guard let bid = Bid.bid(from: bidString) else {
            return
        }
        
        configureAdViewWithSkadn(using: bid)
    }
    
    private func configureAdViewWithSkadn(using bid: Bid) {
        guard let adView = adView else {
            return
        }
        
        guard let skadn = bid.skadn,
              let skadnParameters = SkadnParametersManager.getSkadnProductParameters(for: skadn) else {
            return
        }
        
        adView.subviews
            .filter({ $0 is TouchTrackingOverlayView })
            .forEach({ $0.removeFromSuperview()})
        
        let overlayView = TouchTrackingOverlayView(frame: adView.bounds)
        adView.addSubview(overlayView)
        
        overlayView.onClick = { [weak self] in
            self?.presentSKStoreProductViewController(with: skadnParameters)
        }
    }
    
    private func presentSKStoreProductViewController(with productParameters: [String: Any]) {
        DispatchQueue.main.async {
            let skadnController = SKStoreProductViewController()
            skadnController.delegate = self
            
            self.viewControllerForPresentingModals?.present(skadnController, animated: true)
            skadnController.loadProduct(withParameters: productParameters) { _, error in
                if let error {
                    Log.error("Error occurred during SKStoreProductViewController product loading: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SKStoreProductViewControllerDelegate

extension PrebidSKAdNetworkHelper: SKStoreProductViewControllerDelegate {
    
    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewControllerForPresentingModals?.dismiss(animated: true)
    }
}

/// A custom overlay view for tracking touch interactions.
private class TouchTrackingOverlayView: UIView {
    
    var onClick: (() -> Void)?
    
    private var lastTimestamp: TimeInterval?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            if event?.timestamp != lastTimestamp {
                onClick?()
            }
            
            lastTimestamp = event?.timestamp
            return nil
        }
        
        return super.hitTest(point, with: event)
    }
}
