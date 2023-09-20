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

fileprivate let storedImpVideoBanner = "prebid-demo-video-outstream-original-api"
fileprivate let gamAdUnitVideoBannerOriginal = "/21808260008/prebid-demo-original-api-video-banner"

class GAMOriginalAPIVideoBannerViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var adUnit: BannerAdUnit!
    
    // GAM
    private var gamBanner: GAMBannerView!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a BannerAdUnit
        adUnit = BannerAdUnit(configId: storedImpVideoBanner, size: adSize)
        
        // 2. Set ad format
        adUnit.adFormats = [.video]
        
        // 3. Configure video parameters
        let parameters = VideoParameters(mimes: ["video/mp4"])
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        parameters.placement = Signals.Placement.InBanner
        adUnit.videoParameters = parameters
        
        // 4. Create a GAMBannerView
        gamBanner = GAMBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gamBanner.adUnitID = gamAdUnitVideoBannerOriginal
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        
        // Add GMA SDK banner view to the app UI
        bannerView.addSubview(gamBanner)
        bannerView.backgroundColor = .clear
        
        // 5. Make a bid request to Prebid Server
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            // 6. Load GAM Ad
            self?.gamBanner.load(gamRequest)
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
