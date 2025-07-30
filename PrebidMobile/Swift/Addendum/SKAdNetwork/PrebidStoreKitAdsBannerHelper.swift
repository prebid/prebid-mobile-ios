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

class PrebidStoreKitAdsBannerHelper: PrebidSKAdNetworkStoreKitAdsHelperProtocol {
    
    private var skadnClickHandler: PrebidSKAdNetworkAdClickHandler?
    
    func start(in adView: UIView) {
        if let presentingViewController = adView.parentViewController ?? UIApplication.topViewController() {
            skadnClickHandler = PrebidSKAdNetworkAdClickHandler()
            skadnClickHandler?.start(in: adView, viewController: presentingViewController)
        } else {
            Log.error("SDK couldn't find a view controller to present the SKStoreProductViewController from.")
        }
    }
    
    func stop() {
        skadnClickHandler?.stop()
        skadnClickHandler = nil
    }
}
