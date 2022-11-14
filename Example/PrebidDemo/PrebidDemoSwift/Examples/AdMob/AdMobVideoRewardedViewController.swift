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
import PrebidMobileAdMobAdapters

fileprivate let storedImpVideoRewarded = "imp-prebid-video-rewarded-320-480"
fileprivate let storedResponseVideoRewarded = "response-prebid-video-rewarded-320-480"
fileprivate let adMobAdUnitRewardedId = "ca-app-pub-5922967660082475/7397370641"

class AdMobVideoRewardedViewController: InterstitialBaseViewController, GADFullScreenContentDelegate {
    
    // Prebid
    private var mediationDelegate: AdMobMediationRewardedUtils!
    private var admobRewardedAdUnit: MediationRewardedAdUnit!
    
    // AdMob
    private let request = GADRequest()
    private var gadRewardedAd: GADRewardedAd?

    override func loadView() {
        super.loadView()
        
        Prebid.shared.storedAuctionResponse = storedResponseVideoRewarded
        createAd()
    }
    
    func createAd() {
        mediationDelegate = AdMobMediationRewardedUtils(gadRequest: request)
        admobRewardedAdUnit = MediationRewardedAdUnit(configId: storedImpVideoRewarded, mediationDelegate: mediationDelegate)
        admobRewardedAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            GADRewardedAd.load(withAdUnitID: adMobAdUnitRewardedId, request: self.request) { [weak self] ad, error in
                guard let self = self else { return }
                
                if let error = error {
                    Log.error(error.localizedDescription)
                    return
                }
                
                self.gadRewardedAd = ad
                self.gadRewardedAd?.fullScreenContentDelegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.gadRewardedAd?.present(fromRootViewController: self, userDidEarnRewardHandler: {})
                }
            }
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        PrebidDemoLogger.shared.error("AdMob did fail to receive ad with error: \(error.localizedDescription)")
    }
}
