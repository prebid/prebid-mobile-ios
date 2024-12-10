/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

import Foundation

@objcMembers
class BaseRewardedAdUnit: BaseInterstitialAdUnit, RewardedEventInteractionDelegate {

    override init(
        configID: String,
        minSizePerc: NSValue?,
        eventHandler: PBMPrimaryAdRequesterProtocol
    ) {
        super.init(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: eventHandler
        )
        
        // Setup default values
        adUnitConfig.adConfiguration.isRewarded = true
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    override func trackUserReward(
        _ interstitialController: PrebidMobileInterstitialControllerProtocol,
        _ reward: PrebidReward
    ) {
        DispatchQueue.main.async {
            self.delegate?.callDelegate_rewardedAdUserDidEarnReward?(reward: reward)
        }
    }
    
    // MARK: - RewardedEventInteractionDelegate
    
    func userDidEarnReward(_ reward: PrebidReward?) {
        if let reward {
            DispatchQueue.main.async {
                self.delegate?.callDelegate_rewardedAdUserDidEarnReward?(reward: reward)
            }
        }
    }
}
