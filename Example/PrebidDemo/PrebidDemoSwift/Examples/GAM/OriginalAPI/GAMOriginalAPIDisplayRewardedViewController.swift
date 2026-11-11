/*   Copyright 2019-2026 Prebid.org, Inc.
 
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

fileprivate let storedImpDisplayRewardedOriginal = "prebid-demo-banner-rewarded-time"
fileprivate let gamAdUnitDisplayRewardedOriginal = "/21808260008/prebid-demo-app-original-api-display-interstitial"

class GAMOriginalAPIDisplayRewardedViewController:
    InterstitialBaseViewController,
    FullScreenContentDelegate {
    
    private var adUnit: RewardedDisplayAdUnit!
    private let gamRequest = AdManagerRequest()
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a RewardedDisplayAdUnit
        adUnit = RewardedDisplayAdUnit(configId: storedImpDisplayRewardedOriginal)
        
        // 2. Configure banner parameters
        let bannerParameters = BannerParameters()
        bannerParameters.api = [Signals.Api.MRAID_2]
        bannerParameters.adSizes = [CGSize(width: 320, height: 480)]
        adUnit.bannerParameters = bannerParameters
        
        // 3. Make a bid request to Prebid Server
        adUnit.fetchDemand(adObject: gamRequest) { [weak self] resultCode in
            PrebidDemoLogger.shared.info("Prebid demand fetch for GAM \(resultCode.name())")
            
            // 4. Load the GAM rewarded ad
            RewardedAd.load(with: gamAdUnitDisplayRewardedOriginal, request: self?.gamRequest) { [weak self] ad, error in
                guard let self = self else { return }
                
                if let error = error {
                    PrebidDemoLogger.shared.error("Failed to load display rewarded ad with error: \(error.localizedDescription)")
                } else if let ad = ad {
                    // 5. Present the rewarded ad
                    ad.fullScreenContentDelegate = self
                    ad.present(from: self) {
                        _ = ad.adReward
                    }
                }
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        PrebidDemoLogger.shared.error("Failed to present display rewarded ad with error: \(error.localizedDescription)")
    }
}
