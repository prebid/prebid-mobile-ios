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

fileprivate let storedImpVideoInterstitial = "imp-prebid-video-interstitial-320-480"
fileprivate let storedResponseOriginalVideoInterstitial = "response-prebid-video-interstitial-320-480-original-api"
fileprivate let gamAdUnitVideoInterstitialOriginal = "/21808260008/prebid-demo-app-original-api-video-interstitial"

class GAMOriginalAPIVideoInterstitialViewController: InterstitialBaseViewController, GADFullScreenContentDelegate {
    
    // Prebid
    private var adUnit: VideoInterstitialAdUnit!
    
    // GAM
    private let gamRequest = GAMRequest()
    private var gamInterstitial: GAMInterstitialAd!
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseOriginalVideoInterstitial
        createAd()
    }
    
    func createAd() {
        adUnit = VideoInterstitialAdUnit(configId: storedImpVideoInterstitial)
        
        let parameters = VideoParameters()
        parameters.mimes = ["video/mp4"]
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        
        adUnit.parameters = parameters
        
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            GAMInterstitialAd.load(withAdManagerAdUnitID: gamAdUnitVideoInterstitialOriginal, request: self?.gamRequest) { ad, error in
                guard let self = self else { return }
                if let error = error {
                    PrebidDemoLogger.shared.error("Failed to load interstitial ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    ad.present(fromRootViewController: self)
                    ad.fullScreenContentDelegate = self
                }
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        PrebidDemoLogger.shared.error("Failed to present interstitial ad with error: \(error.localizedDescription)")
    }
}
