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

fileprivate let storedImpsBanner = ["prebid-demo-banner-300-250", "prebid-demo-video-outstream-original-api"]
fileprivate let gamAdUnitMultiformatBannerOriginal = "/21808260008/prebid-demo-original-banner-multiformat"

class GAMOriginalAPIMultiformatBannerViewController:
    BannerBaseViewController,
    GoogleMobileAds.BannerViewDelegate {
    
    // Prebid
    private var adUnit: BannerAdUnit!
    
    // GAM
    private var gamBanner: AdManagerBannerView!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a BannerAdUnit
        adUnit = BannerAdUnit(configId: storedImpsBanner.randomElement()!, size: adSize)
        adUnit.setAutoRefreshMillis(time: 30000)
        
        // 2. Set adFormats
        adUnit.adFormats = [.banner, .video]
        
        // 3. Configure banner parameters
        let bannerParameters = BannerParameters()
        bannerParameters.api = [Signals.Api.MRAID_2]
        adUnit.bannerParameters = bannerParameters
        
        // 4. Configure video parameters
        let videoParameters = VideoParameters(mimes: ["video/mp4"])
        videoParameters.protocols = [Signals.Protocols.VAST_2_0]
        videoParameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        videoParameters.placement = Signals.Placement.InBanner
        adUnit.videoParameters = videoParameters
        
        // 5. Create a AdManagerBannerView
        gamBanner = AdManagerBannerView(adSize: adSizeFor(cgSize: adSize))
        gamBanner.adUnitID = gamAdUnitMultiformatBannerOriginal
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        
        // Add GMA SDK banner view to the app UI
        bannerView?.addSubview(gamBanner)
        
        // 6. Make a bid request to Prebid Server
        let gamRequest = AdManagerRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            // 7. Load GAM Ad
            self?.gamBanner.load(gamRequest)
        }
    }
    
    // MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { size in
            guard let bannerView = bannerView as? AdManagerBannerView else { return }
            bannerView.resize(adSizeFor(cgSize: size))
        }, failure: { (error) in
            PrebidDemoLogger.shared.error("Error occuring during searching for Prebid creative size: \(error)")
        })
    }
    
    func bannerView(
        _ bannerView: GoogleMobileAds.BannerView,
        didFailToReceiveAdWithError error: Error
    ) {
        PrebidDemoLogger.shared.error("GAM did fail to receive ad with error: \(error)")
    }
}

