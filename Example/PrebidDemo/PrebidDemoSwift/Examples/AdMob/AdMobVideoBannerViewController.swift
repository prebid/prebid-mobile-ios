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

fileprivate let storedImpVideoBanner = "imp-prebid-video-outstream"
fileprivate let storedResponseRenderingVideoBanner = "response-prebid-video-outstream"
fileprivate let adMobAdUnitDisplayBannerRendering = "ca-app-pub-5922967660082475/9483570409"

class AdMobVideoBannerViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var prebidAdMobMediaitonAdUnit: MediationBannerAdUnit!
    private var mediationDelegate: AdMobMediationBannerUtils!
    
    // AdMob
    private var gadBanner: GADBannerView!
    private let gadRequest = GADRequest()
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseRenderingVideoBanner
        createAd()
    }
    
    func createAd() {
        // Setup GADBannerView
        gadBanner = GADBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gadBanner.adUnitID = adMobAdUnitDisplayBannerRendering
        gadBanner.delegate = self
        gadBanner.rootViewController = self
        bannerView.backgroundColor = .clear
        bannerView.addSubview(gadBanner)
        // Setup Prebud banner mediation ad unit
        mediationDelegate = AdMobMediationBannerUtils(gadRequest: gadRequest, bannerView: gadBanner)
        prebidAdMobMediaitonAdUnit = MediationBannerAdUnit(configID: storedImpVideoBanner, size: adSize, mediationDelegate: mediationDelegate)
        // Trigger a call to Prebid Server to retrieve demand for this Prebid Mobile ad unit
        prebidAdMobMediaitonAdUnit.fetchDemand { [weak self] result in
            PrebidDemoLogger.shared.info("Prebid demand fetch for AdMob \(result.name())")
            // Load ad
            self?.gadBanner.load(self?.gadRequest)
        }
    }
    
    //MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? GAMBannerView else { return }
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { (error) in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        PrebidDemoLogger.shared.error("AdMob did fail to receive ad with error: \(error.localizedDescription)")
    }
}
