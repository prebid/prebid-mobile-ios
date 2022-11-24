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
import PrebidMobileMAXAdapters
import AppLovinSDK

fileprivate let storedImpVideoInterstitial = "imp-prebid-video-interstitial-320-480"
fileprivate let storedResponseRenderingVideoInterstitial = "response-prebid-video-interstitial-320-480"
fileprivate let maxAdUnitVideoInterstitial = "98e49039f26d7f00"

class MAXVideoInterstitialViewController: InterstitialBaseViewController, MAAdDelegate {
    
    // Prebid
    private var maxAdUnit: MediationInterstitialAdUnit!
    private var maxMediationDelegate: MAXMediationInterstitialUtils!
    
    // MAX
    private var maxInterstitial: MAInterstitialAd!
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseRenderingVideoInterstitial
        createAd()
    }
    
    func createAd() {
        // 1. Create a MAInterstitialAd
        maxInterstitial = MAInterstitialAd(adUnitIdentifier: maxAdUnitVideoInterstitial)
        
        // 2. Create a MAXMediationInterstitialUtils
        maxMediationDelegate = MAXMediationInterstitialUtils(interstitialAd: maxInterstitial)
        
        // 3. Create a MediationInterstitialAdUnit
        maxAdUnit = MediationInterstitialAdUnit(configId: storedImpVideoInterstitial, mediationDelegate: maxMediationDelegate)
        maxAdUnit.adFormats = [.video]
        
        // 4. Make a bid request to Prebid Server
        maxAdUnit.fetchDemand(completion: { [weak self] result in
            PrebidDemoLogger.shared.info("Prebid demand fetch result \(result.name())")
            guard let self = self else { return }
            
            // 5. Load the interstitial ad
            self.maxInterstitial.delegate = self
            self.maxInterstitial.load()
        })
    }
    
    // MARK: - MAAdDelegate
    
    func didLoad(_ ad: MAAd) {
        if let maxInterstitial = maxInterstitial, maxInterstitial.isReady {
            maxInterstitial.show()
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        PrebidDemoLogger.shared.error("\(error.message)")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        PrebidDemoLogger.shared.error("\(error.message)")
    }
    
    func didDisplay(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
}
