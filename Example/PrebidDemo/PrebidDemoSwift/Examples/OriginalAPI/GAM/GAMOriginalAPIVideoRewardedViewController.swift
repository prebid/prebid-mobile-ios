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

fileprivate let storedResponseVideoRewarded = "response-prebid-video-rewarded-320-480"
fileprivate let storedImpVideoRewarded = "imp-prebid-video-rewarded-320-480"
fileprivate let gamAdUnitVideoRewardedOriginal = "/21808260008/prebid-demo-app-original-api-video-interstitial"

class GAMOriginalAPIVideoRewardedViewController: InterstitialBaseViewController, GADFullScreenContentDelegate {
    
    // Prebid
    private var adUnit: RewardedVideoAdUnit!
    
    // GAM
    private let gamRequest = GAMRequest()
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseVideoRewarded
        
        // Setup Prebid ad unit
        adUnit = RewardedVideoAdUnit(configId: storedImpVideoRewarded)
        let parameters = VideoParameters()
        parameters.mimes = ["video/mp4"]
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        adUnit.parameters = parameters
        
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            guard let self = self else { return }
            
            GADRewardedAd.load(withAdUnitID: gamAdUnitVideoRewardedOriginal,
                               request: self.gamRequest) { [weak self] ad, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    PrebidDemoLogger.shared.error("Failed to load rewarded ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    ad.fullScreenContentDelegate = self
                    ad.present(fromRootViewController: self, userDidEarnRewardHandler: {
                        _ = ad.adReward
                    })
                }
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        PrebidDemoLogger.shared.error("Failed to present rewarded ad with error: \(error.localizedDescription)")
    }
}
