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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileGAMEventHandlers

fileprivate let storedImpVideoBanner = "prebid-demo-video-outstream"
fileprivate let gamAdUnitVideoBannerRendering = "/21808260008/prebid_oxb_300x250_banner"

class GAMVideoBannerViewController: BannerBaseViewController, BannerViewDelegate {
    
    // Prebid
    private var prebidBannerView: BannerView!
    
    // GAM
    private var gamBanner: GAMBannerView!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a GAMBannerEventHandler
        let eventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitVideoBannerRendering, validGADAdSizes: [GADAdSizeMediumRectangle].map(NSValueFromGADAdSize))
        // 2. Create a BannerView
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: adSize), configID: storedImpVideoBanner, adSize: adSize, eventHandler: eventHandler)
        
        // 3. Configure the BannerView
        prebidBannerView.adFormat = .video
        prebidBannerView.videoParameters.placement = .InBanner
        prebidBannerView.delegate = self
        
        // Add Prebid banner view to the app UI
        bannerView.backgroundColor = .clear
        bannerView.addSubview(prebidBannerView)
        
        // 4. Load the banner ad
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
