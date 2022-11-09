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

class OriginalBannerDisplayViewController: BannerBaseViewController, GADBannerViewDelegate {
    
    // Prebid
    private var adUnit: BannerAdUnit!
    private let size = CGSize(width: 320, height: 50)
    
    // GAM
    private let gamRequest = GAMRequest()
    private var gamBanner: GAMBannerView!
    
    override func loadView() {
        super.loadView()
        Prebid.shared.storedAuctionResponse = storedResponseDisplayBanner
        setupBannerAdUnit()
        setupGAMBanner(bannerSize: size, adUnitId: gamAdUnitDisplayBannerOriginal)
        loadGAMBanner()
    }
    
    // MARK: Setup Prebid AdUnit
    
    func setupBannerAdUnit() {
        adUnit = BannerAdUnit(configId: storedImpDisplayBanner, size: size)
        
        let parameters = BannerParameters()
        parameters.api = [Signals.Api.MRAID_2]
        adUnit.parameters = parameters
        adUnit.setAutoRefreshMillis(time: 30000)
    }
    
    // MARK: Setup AdServer - GAM
    
    func setupGAMBanner(bannerSize: CGSize, adUnitId: String) {
        let customAdSize = GADAdSizeFromCGSize(bannerSize)
        
        gamBanner = GAMBannerView(adSize: customAdSize)
        gamBanner.adUnitID = adUnitId
    }
    
    // MARK: Load Ad
    
    func loadGAMBanner() {
        gamBanner.backgroundColor = .red
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        
        bannerView?.addSubview(gamBanner)
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] (resultCode: ResultCode) in
            // TODO: Add unified logger
            print("Prebid demand fetch for AdManager \(resultCode.name())")
            self?.gamBanner.load(self?.gamRequest)
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        AdViewUtils.findPrebidCreativeSize(bannerView, success: { (size) in
            guard let bannerView = bannerView as? GAMBannerView else {
                return
            }
            
            bannerView.resize(GADAdSizeFromCGSize(size))
        }, failure: { (error) in
            print("error: \(error)")
        })
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        
    }
}
