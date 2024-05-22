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

fileprivate let storedImpDisplayInterstitial = "prebid-demo-display-interstitial-320-480"
fileprivate let adMobAdUnitDisplayInterstitial = "ca-app-pub-5922967660082475/3383099861"

class AdMobDisplayInterstitialViewController: InterstitialBaseViewController, GADFullScreenContentDelegate {
    
    // Prebid
    private var admobAdUnit: MediationInterstitialAdUnit?
    private var mediationDelegate: AdMobMediationInterstitialUtils?
    
    // AdMob
    private var interstitial: GADInterstitialAd?
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a GADRequest
        let gadRequest = GADRequest()
        
        // 2. Create an AdMobMediationInterstitialUtils
        mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: gadRequest)
        
        // 3. Create a MediationInterstitialAdUnit
        admobAdUnit = MediationInterstitialAdUnit(configId: storedImpDisplayInterstitial, mediationDelegate: mediationDelegate!)
        
        // 4. Make a bid request to Prebid Server
        admobAdUnit?.fetchDemand(completion: { [weak self] result in
            PrebidDemoLogger.shared.info("Prebid demand fetch for AdMob \(result.name())")
            
            // 5. Load the interstitial ad
            GADInterstitialAd.load(withAdUnitID: adMobAdUnitDisplayInterstitial, request: gadRequest) { [weak self] ad, error in
                guard let self = self else { return }
                
                if let error = error {
                    PrebidDemoLogger.shared.error("\(error.localizedDescription)")
                    return
                }
                
                // 6. Present the interstitial ad
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                self.interstitial?.present(fromRootViewController: self)
            }
        })
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        PrebidDemoLogger.shared.error("AdMob did fail to receive ad with error: \(error.localizedDescription)")
    }
}
