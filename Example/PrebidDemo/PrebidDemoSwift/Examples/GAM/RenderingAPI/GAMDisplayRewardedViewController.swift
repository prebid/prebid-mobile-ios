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
import GoogleMobileAds
import PrebidMobile
import PrebidMobileGAMEventHandlers

fileprivate let storedImpDisplayRewarded = "prebid-demo-banner-rewarded-time"
fileprivate let gamAdUnitBannerRewardedRendering = "/21808260008/prebid_oxb_rewarded_video_test"

class GAMDisplayRewardedViewController: InterstitialBaseViewController, RewardedAdUnitDelegate {
    
    // Prebid
    private var rewardedAdUnit: RewardedAdUnit!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a GAMRewardedAdEventHandler
        let eventHandler = GAMRewardedAdEventHandler(adUnitID: gamAdUnitBannerRewardedRendering)
        
        // 2. Create a RewardedAdUnit
        rewardedAdUnit = RewardedAdUnit(
            configID: storedImpDisplayRewarded,
            eventHandler: eventHandler
        )
        
        rewardedAdUnit.delegate = self
        
        // 3. Load the rewarded ad
        rewardedAdUnit.loadAd()
    }
    
    // MARK: - RewardedAdUnitDelegate
    
    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        if rewardedAd.isReady {
            rewardedAd.show(from: self)
        }
    }
    
    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        PrebidDemoLogger.shared.error("Rewarded ad unit failed to receive ad with error: \(error?.localizedDescription ?? "")")
    }
    
    func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit, reward: PrebidReward) {
        PrebidDemoLogger.shared.info("User did earn reward: type - \(reward.type ?? ""), count - \(reward.count ?? 0)")
    }
}
