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

fileprivate let storedResponseDisplayInterstitial = "response-prebid-display-interstitial-320-480"
fileprivate let storedImpDisplayInterstitial = "imp-prebid-display-interstitial-320-480"
fileprivate let gamAdUnitDisplayInterstitialOriginal = "/21808260008/prebid-demo-app-original-api-display-interstitial"

class GAMOriginalAPIDisplayInterstitialViewController: InterstitialBaseViewController, GADFullScreenContentDelegate {
    
    // Prebid
    private var adUnit: InterstitialAdUnit!
    
    // GAM
    private let gamRequest = GAMRequest()
    private var gamInterstitial: GAMInterstitialAd!
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseDisplayInterstitial
        
        // Setup Prebid ad unit
        adUnit = InterstitialAdUnit(configId: storedImpDisplayInterstitial)
        
        // Setup integration kind - GAM
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] (resultCode: ResultCode) in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            GAMInterstitialAd.load(withAdManagerAdUnitID: gamAdUnitDisplayInterstitialOriginal, request: self?.gamRequest) { (ad, error) in
                guard let self = self else { return }
                if let error = error {
                    PrebidDemoLogger.shared.error("Failed to load interstitial ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    ad.present(fromRootViewController: self)
                }
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        PrebidDemoLogger.shared.error("Failed to present interstitial ad with error: \(error.localizedDescription)")
    }
}
