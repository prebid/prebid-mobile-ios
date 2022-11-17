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

fileprivate let storedImpVideoRewarded = "imp-prebid-video-rewarded-320-480"
fileprivate let storedResponseVideoRewarded = "response-prebid-video-rewarded-320-480"

class InAppVideoRewardedViewController: InterstitialBaseViewController, RewardedAdUnitDelegate {
    
    // Prebid
    private var rewardedAdUnit: RewardedAdUnit!

    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseVideoRewarded
        createAd()
    }
    
    func createAd() {
        // Setup Prebid ad unit
        rewardedAdUnit = RewardedAdUnit(configID: storedImpVideoRewarded)
        rewardedAdUnit.delegate = self
        // Load ad
        rewardedAdUnit.loadAd()
    }
    
    // MARK: - RewardedAdUnitDelegate
    
    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        rewardedAdUnit.show(from: self)
    }
    
    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        PrebidDemoLogger.shared.error("Rewarded ad unit did fail to receive ad: \(error?.localizedDescription ?? "")")
    }
}
