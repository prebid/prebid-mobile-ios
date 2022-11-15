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

fileprivate let storedImpVideoRewarded = "imp-prebid-video-rewarded-320-480"
fileprivate let storedResponseVideoRewarded = "response-prebid-video-rewarded-320-480"
fileprivate let maxAdUnitRewardedId = "f7a08e702c6bec54"

class MAXVideoRewardedViewController: InterstitialBaseViewController, MARewardedAdDelegate {
    
    // Prebid
    private var maxRewardedAdUnit: MediationRewardedAdUnit!
    private var mediationDelegate: MAXMediationRewardedUtils!
    
    // MAX
    private var maxRewarded: MARewardedAd!
    
    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseVideoRewarded
        createAd()
    }
    
    func createAd() {
        // Setup integration kind - AppLovin MAX
        maxRewarded = MARewardedAd.shared(withAdUnitIdentifier: maxAdUnitRewardedId)
        // Setup Prebid mediation ad unit
        mediationDelegate = MAXMediationRewardedUtils(rewardedAd: maxRewarded)
        maxRewardedAdUnit = MediationRewardedAdUnit(configId: storedImpVideoRewarded, mediationDelegate: mediationDelegate)
        // Setup Prebid mediation ad unit
        maxRewardedAdUnit.fetchDemand { [weak self] result in
            self?.maxRewarded.delegate = self
            self?.maxRewarded.load()
        }
    }
    
    // MARK: - MARewardedAdDelegate
    
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
    
    func didStartRewardedVideo(for ad: MAAd) {
        // This delegate is not supported.
    }
    
    func didCompleteRewardedVideo(for ad: MAAd) {
        // This delegate is not supported.
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {}
}
