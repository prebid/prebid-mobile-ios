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

fileprivate let storedImpDisplayInterstitial = "imp-prebid-display-interstitial-320-480"
fileprivate let storedResponseDisplayInterstitial = "response-prebid-display-interstitial-320-480"
fileprivate let maxAdUnitDisplayInterstitial = "98e49039f26d7f00"

class MAXDisplayInterstitialViewController: InterstitialBaseViewController, MAAdDelegate {
    
    // Prebid
    private var maxAdUnit: MediationInterstitialAdUnit!
    private var maxMediationDelegate: MAXMediationInterstitialUtils!
    
    // MAX
    private var maxInterstitial: MAInterstitialAd!

    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseDisplayInterstitial
        createAd()
    }
    
    func createAd() {
        maxInterstitial = MAInterstitialAd(adUnitIdentifier: maxAdUnitDisplayInterstitial)
        maxMediationDelegate = MAXMediationInterstitialUtils(interstitialAd: maxInterstitial)
        maxAdUnit = MediationInterstitialAdUnit(configId: storedImpDisplayInterstitial, mediationDelegate: maxMediationDelegate)
        
        maxAdUnit.fetchDemand(completion: { [weak self] result in
            PrebidDemoLogger.shared.info("Prebid demand fetch result \(result.name())")
            
            guard let self = self else { return }
            self.maxInterstitial.delegate = self
            self.maxInterstitial.load()
        })
    }
    
    // MARK: - MAAdDelegate
    
    func didLoad(_ ad: MAAd) {}
    
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
