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
import GoogleMobileAds

fileprivate let storedResponseDisplayBanner = "response-prebid-banner-320-50"
fileprivate let storedImpDisplayBanner = "imp-prebid-banner-320-50"
fileprivate let gamAdUnitDisplayBannerOriginal = "/21808260008/prebid_demo_app_original_api_banner"

class GAMOriginalAPIBannerDisplayViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var adUnit: BannerAdUnit!
    
    // GAM
    private let gamRequest = GAMRequest()
    private var gamBanner: GAMBannerView!
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseDisplayBanner
        
        // Create a BannerAdUnit associated with a Prebid Server configuration ID and a banner size.
        adUnit = BannerAdUnit(configId: storedImpDisplayBanner, size: adSize)
        // Create and setup banner parameters
        let parameters = BannerParameters()
        // Define any appropriate API Frameworks
        parameters.api = [Signals.Api.MRAID_2]
        adUnit.parameters = parameters
        // Set autorefresh interval
        adUnit.setAutoRefreshMillis(time: 30000)
        
        // Setup integration kind - GAM
        gamBanner = GAMBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gamBanner.adUnitID = gamAdUnitDisplayBannerOriginal
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        bannerView?.addSubview(gamBanner)
        
        // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit.
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            // Load ad
            self?.gamBanner.load(self?.gamRequest)
        }
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? GAMBannerView else { return }
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { (error) in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
}
