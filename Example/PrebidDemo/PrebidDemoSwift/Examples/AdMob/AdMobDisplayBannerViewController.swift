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

fileprivate let storedImpDisplayBanner = "imp-prebid-banner-320-50"
fileprivate let storedResponseDisplayBanner = "response-prebid-banner-320-50"
fileprivate let adMobAdUnitDisplayBannerRendering = "ca-app-pub-5922967660082475/9483570409"

class AdMobDisplayBannerViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var prebidAdMobMediaitonAdUnit: MediationBannerAdUnit!
    private var mediationDelegate: AdMobMediationBannerUtils!
    
    // AdMob
    private var gadBanner: GADBannerView!
    private let gadRequest = GADRequest()
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseDisplayBanner
        createAd()
    }
    
    func createAd() {
        gadBanner = GADBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gadBanner.adUnitID = adMobAdUnitDisplayBannerRendering
        gadBanner.delegate = self
        gadBanner.rootViewController = self
        bannerView.addSubview(gadBanner)
        mediationDelegate = AdMobMediationBannerUtils(gadRequest: gadRequest, bannerView: gadBanner)
        prebidAdMobMediaitonAdUnit = MediationBannerAdUnit(configID: storedImpDisplayBanner, size: adSize, mediationDelegate: mediationDelegate)
        prebidAdMobMediaitonAdUnit.fetchDemand { [weak self] result in
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
        PrebidDemoLogger.shared.error("AdMob did fail to receive ad with error: \(error)")
    }
}
