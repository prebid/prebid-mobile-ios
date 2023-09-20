/*   Copyright 2019-2022 Prebid.org, Inc.
 
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
import PrebidMobile

fileprivate let storedImpDisplayBanner = "prebid-demo-banner-320-50"

class InAppDisplayBannerViewController: BannerBaseViewController, BannerViewDelegate {
    
    // Prebid
    private var prebidBannerView: BannerView!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a BannerView
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: adSize), configID: storedImpDisplayBanner, adSize: adSize)
        
        // 2. Configure the BannerView
        prebidBannerView.delegate = self
        prebidBannerView.adFormat = .banner
        prebidBannerView.videoParameters.placement = .InBanner
        
        // Add Prebid banner view to the app UI
        bannerView.addSubview(prebidBannerView)
        
        // 3. Load the banner ad
        prebidBannerView.loadAd()
    }
    
    // MARK: - BannerViewDelegate
    
    func bannerViewPresentationController() -> UIViewController? {
        self
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
        PrebidDemoLogger.shared.error("Banner view did fail to receive ad with error: \(error)")
    }
}
