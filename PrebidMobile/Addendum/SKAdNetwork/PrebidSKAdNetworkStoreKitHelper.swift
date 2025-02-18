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

/// Helper class that invokes SKStoreProductViewController on ad click.
@objcMembers
class PrebidSKAdNetworkStoreKitAdsHelper: NSObject {
    
    private weak var adView: UIView?
    private weak var viewControllerForPresentingModals: UIViewController?
    
    private var productControllerPresenter: SKStoreProductViewControllerPresenter?
    
    /// Configures the provided ad view with SKAdN on click event..
    /// - Parameters:
    ///   - adView: The ad view where click events is tracked.
    ///   - viewController: The view controller used to present modals, such as the SKStoreProductViewController.
    func start(in adView: UIView, viewController: UIViewController) {
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
        guard let adView = adView, let viewControllerForPresentingModals = viewControllerForPresentingModals else {
            return
        }
        
        guard let skadn = bid.skadn,
              let productParameters = SkadnParametersManager.getSkadnProductParameters(for: skadn) else {
            Log.error("SDK couldn't retrieve SKAdN product parameters from bid response.")
            return
        }
        
        productControllerPresenter = SKStoreProductViewControllerPresenter()
        productControllerPresenter?.present(
            from: viewControllerForPresentingModals,
            using: productParameters
        )
    }
}
