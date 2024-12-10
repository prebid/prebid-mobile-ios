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

fileprivate let storedImpDisplayBanner = "prebid-demo-banner-320-50"
fileprivate let gamAdUnitDisplayBannerOriginal = "/21808260008/prebid_demo_app_original_api_banner"

class GAMOriginalAPIDisplayBannerViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var adUnit: BannerAdUnit!
    
    // GAM
    private var gamBanner: GAMBannerView!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    deinit {
        // Clean up global ORTB config
        Targeting.shared.setGlobalORTBConfig(nil)
    }
    
    func createAd() {
        // 1. Set global ORTB
        let globalORTB = """
        {
          "ext": {
            "myext": {
              "test": 1
            }
          },
          "displaymanager": "Google",
          "displaymanagerver": "\(GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber))"
        }
        """
        Targeting.shared.setGlobalORTBConfig(globalORTB)
        
        // 2. Create a BannerAdUnit
        adUnit = BannerAdUnit(configId: storedImpDisplayBanner, size: adSize)
        adUnit.setAutoRefreshMillis(time: 30000)
        
        // 3. Configure banner parameters
        let parameters = BannerParameters()
        parameters.api = [Signals.Api.MRAID_2]
        adUnit.bannerParameters = parameters
        
        // 4. Set impression-level ORTB
        adUnit.setImpORTBConfig("{\"bidfloor\":0.01,\"banner\":{\"battr\":[1,2,3,4]}}")
        
        // 5. Create a GAMBannerView
        gamBanner = GAMBannerView(adSize: GADAdSizeFromCGSize(adSize))
        gamBanner.adUnitID = gamAdUnitDisplayBannerOriginal
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        
        // Add GMA SDK banner view to the app UI
        bannerView?.addSubview(gamBanner)
        
        // 6. Make a bid request to Prebid Server
        let gamRequest = GAMRequest()
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            // 7. Load GAM Ad
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
