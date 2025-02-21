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

class PrebidStoreKitAdsInterstitialHelper: PrebidSKAdNetworkStoreKitAdsHelperProtocol {
    
    private var skadnClickHandler: PrebidSKAdNetworkAdClickHandler?
    private var interstitialObserver: InterstitialObserver?
    
    func start(in adView: UIView) {
        interstitialObserver = InterstitialObserver(window: adView as? UIWindow) { [weak self] foundView in
            if let presentingViewController = adView.parentViewController ?? UIApplication.topViewController() {
                self?.skadnClickHandler = PrebidSKAdNetworkAdClickHandler()
                self?.skadnClickHandler?.start(
                    in: foundView,
                    viewController: presentingViewController,
                    displayDelay: 1
                )
            } else {
                Log.error("SDK couldn't find a view controller to present the SKStoreProductViewController from.")
            }
        }
        
        interstitialObserver?.start()
    }
    
    func stop() {
        interstitialObserver?.stop()
        interstitialObserver = nil
        skadnClickHandler?.stop()
        skadnClickHandler = nil
    }
}
