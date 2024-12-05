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

fileprivate let storedImpDisplayRewarded = "prebid-demo-banner-rewarded-time"
fileprivate let maxAdUnitRewardedId = "f7a08e702c6bec54"

class MAXDisplayRewardedViewController: InterstitialBaseViewController, MARewardedAdDelegate {
    
    // Prebid
    private var maxRewardedAdUnit: MediationRewardedAdUnit!
    private var mediationDelegate: MAXMediationRewardedUtils!
    
    // MAX
    private var maxRewarded: MARewardedAd!
    
    override func loadView() {
        super.loadView()
        
        createAd()
    }
    
    func createAd() {
        // 1. Create a MARewardedAd
        maxRewarded = MARewardedAd.shared(withAdUnitIdentifier: maxAdUnitRewardedId)
        
        // 2. Create a MAXMediationRewardedUtils
        mediationDelegate = MAXMediationRewardedUtils(rewardedAd: maxRewarded)
        
        // 3. Create a MediationRewardedAdUnit
        maxRewardedAdUnit = MediationRewardedAdUnit(
            configId: storedImpDisplayRewarded,
            mediationDelegate: mediationDelegate
        )
        
        // 4. Make a bid request to Prebid Server
        maxRewardedAdUnit.fetchDemand { [weak self] result in
            // 5. Load the rewarded ad
            self?.maxRewarded.delegate = self
            self?.maxRewarded.load()
        }
    }
    
    // MARK: - MARewardedAdDelegate
    
    func didLoad(_ ad: MAAd) {
        if let maxRewarded = maxRewarded, maxRewarded.isReady {
            maxRewarded.show()
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
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        print("User did earn reward: label - \(reward.label), amount - \(reward.amount)")
    }
}
