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

fileprivate let storedImpDisplayBanner = "imp-prebid-banner-320-50"
fileprivate let storedResponseDisplayBanner = "response-prebid-banner-320-50"
fileprivate let gamAdUnitDisplayBannerRendering = "/21808260008/prebid_oxb_320x50_banner"

class GAMDisplayBannerViewController: BannerBaseViewController, BannerViewDelegate {
    
    // Prebid
    private var prebidBannerView: BannerView!
    
    // GAM
    private let gamRequest = GAMRequest()
    private var gamBanner: GAMBannerView!

    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseDisplayBanner
        createAd()
    }
    
    func createAd() {
        let eventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitDisplayBannerRendering, validGADAdSizes: [GADAdSizeBanner].map(NSValueFromGADAdSize))
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: adSize), configID: storedImpDisplayBanner, adSize: adSize, eventHandler: eventHandler)
        prebidBannerView.delegate = self
        bannerView.addSubview(prebidBannerView)
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
