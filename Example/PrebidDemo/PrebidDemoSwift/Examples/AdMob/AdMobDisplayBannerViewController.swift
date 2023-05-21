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
import PrebidMobileAdMobAdapters

fileprivate let storedImpDisplayBanner = "prebid-demo-banner-320-50"
fileprivate let adMobAdUnitDisplayBannerRendering = "ca-app-pub-5922967660082475/9483570409"

class AdMobDisplayBannerViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var prebidAdMobMediaitonAdUnit: MediationBannerAdUnit!
    private var mediationDelegate: AdMobMediationBannerUtils!
    
    // AdMob
    private var gadBanner: GADBannerView!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a GADRequest
        let gadRequest = GADRequest()
        
        // 2. Create a GADBannerView
        gadBanner = GADBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gadBanner.adUnitID = adMobAdUnitDisplayBannerRendering
        gadBanner.delegate = self
        gadBanner.rootViewController = self
        
        // Add GMA SDK banner view to the app UI
        bannerView.addSubview(gadBanner)
        
        // 3. Create an AdMobMediationBannerUtils
        mediationDelegate = AdMobMediationBannerUtils(gadRequest: gadRequest, bannerView: gadBanner)
        
        // 4. Create a MediationBannerAdUnit
        prebidAdMobMediaitonAdUnit = MediationBannerAdUnit(
            configID: storedImpDisplayBanner,
            size: adSize,
            mediationDelegate: mediationDelegate
        )
        
        // 5. Make a bid request to Prebid Server
        prebidAdMobMediaitonAdUnit.fetchDemand { [weak self] result in
            PrebidDemoLogger.shared.info("Prebid demand fetch for AdMob \(result.name())")
            
            // 6. Load ad
            self?.gadBanner.load(gadRequest)
        }
    }
    
    //MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("AdMob did fail to receive ad with error: \(error)")
        prebidAdMobMediaitonAdUnit?.adObjectDidFailToLoadAd(adObject: gadBanner, with: error)
    }
}
