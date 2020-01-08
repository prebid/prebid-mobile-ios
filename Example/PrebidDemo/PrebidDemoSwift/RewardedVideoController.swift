/*   Copyright 2018-2019 Prebid.org, Inc.

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
import Foundation

import GoogleMobileAds
import PrebidMobile

class RewardedVideoController: UIViewController, GADRewardedAdDelegate {
    
    var adServerName: String = ""
    
    var adUnit: AdUnit!
    var rewardedAd: GADRewardedAd!
    let request = GADRequest()
    
    override func viewDidLoad() {
        setupAndLoadAMRewardedVideo()
    }
    
    func setupAndLoadAMRewardedVideo() {
        setupPBRewardedVideo()
        setupAMRewardedVideo()
        
        loadRewardedVideo()
    }
    
    func setupPBRewardedVideo() {
        Prebid.shared.prebidServerHost = PrebidHost.Custom
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server.qa.rubiconproject.com/openrtb2/auction")
        
        Prebid.shared.prebidServerAccountId = "1011"
        Prebid.shared.storedAuctionResponse = ""
        
        adUnit = RewardedVideoAdUnit(configId: "1011-test-video")
    }
    
    func setupAMRewardedVideo() {
        
        rewardedAd = GADRewardedAd(adUnitID: "/5300653/test_adunit_vast_rewarded-video_pavliuchyk")
    }
    
    func loadRewardedVideo() {
        adUnit.fetchDemand(adObject: self.request) { (resultCode: ResultCode) in
            
            self.rewardedAd.load(self.request) { error in
              if let error = error {
                print("Loading failed: \(error)")
              } else {
                print("Loading Succeeded")
                
                if self.rewardedAd?.isReady == true {
                    self.rewardedAd?.present(fromRootViewController: self, delegate:self)
                }
                
              }
            }

        }
    }
    
    /// Tells the delegate that the user earned a reward.
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
      print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    /// Tells the delegate that the rewarded ad was presented.
    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
      print("Rewarded ad presented.")
    }
    /// Tells the delegate that the rewarded ad was dismissed.
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
      print("Rewarded ad dismissed.")
    }
    /// Tells the delegate that the rewarded ad failed to present.
    func rewardedAd(_ rewardedAd: GADRewardedAd, didFailToPresentWithError error: Error) {
      print("Rewarded ad failed to present.")
    }

}
