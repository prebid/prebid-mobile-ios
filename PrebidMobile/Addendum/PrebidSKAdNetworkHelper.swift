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
    
    private weak var viewControllerForPresentingModals: UIViewController?
    
    
    /// Subscribes to ad click events on the provided ad view and sets up the SKAdNetwork parameters.
    /// - Parameters:
    ///   - adView: The ad view where click events will be tracked.
    ///   - viewController: The view controller used to present modals, such as the SKStoreProductViewController.
    public func subscribeOnAdClicked(adView: UIView, viewController: UIViewController) {
        self.viewControllerForPresentingModals = viewController
        
        AdViewUtils.findPrebidLocalCacheID(adView) { result in
            guard case .success(let cacheID) = result else {
                return
            }
            
            guard let bidString = CacheManager.shared.get(cacheId: cacheID),
                  let bidDic = Utils.shared.getDictionaryFromString(bidString) else {
                Log.error("No bid response for provided cache id.")
                return
            }
            
            guard let rawBid = PBMORTBBid<PBMORTBBidExt>(jsonDictionary: bidDic, extParser: { extDic in
                return PBMORTBBidExt(jsonDictionary: extDic)
            }) else {
                return
            }
            
            let bid = Bid(bid: rawBid)
            
            guard let skadn = bid.skadn,
                  let skadnParameters = SkadnParametersManager.getSkadnProductParameters(for: skadn) else {
                return
            }
            
            adView.subviews.forEach({
                if $0 is TouchTrackingOverlayView {
                    $0.removeFromSuperview()
                }
            })
            
            let overlayView = TouchTrackingOverlayView(frame: adView.frame)
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            adView.addSubview(overlayView)
            
            overlayView.onClick = { [weak self] in
                self?.presentSKStoreProductViewController(with: skadnParameters)
            }
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
