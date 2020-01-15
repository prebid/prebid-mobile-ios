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
import MoPub


class RewardedVideoController: UIViewController, GADRewardedAdDelegate, MPRewardedVideoDelegate {
    
    @IBOutlet var adServerLabel: UILabel!
    
    var adServerName: String = ""
    
    private var adUnit: AdUnit!
    
    private var amRewardedAd: GADRewardedAd!
    private let amRequest = GADRequest()
    private let amAdUnitId = "/5300653/test_adunit_vast_rewarded-video_pavliuchyk"
    
    private let mpAdUnitId = "46d2ebb3ccd340b38580b5d3581c6434"
    
    override func viewDidLoad() {
        
        adServerLabel.text = adServerName
        
        if (adServerName == "DFP") {
            setupAndLoadAMRewardedVideo()
        } else if (adServerName == "MoPub") {
            setupAndLoadMPRewardedVideo()
        }
    }
    
    func setupAndLoadAMRewardedVideo() {
        setupPBRewardedVideo()
        setupAMRewardedVideo()
        
        loadAMRewardedVideo()
    }
    
    func setupAndLoadMPRewardedVideo() {
        setupPBRewardedVideo()
        setupMPRewardedVideo()
        
        loadMPRewardedVideo()
    }
    
    func setupPBRewardedVideo() {

        Prebid.shared.prebidServerHost = .Rubicon

        Prebid.shared.prebidServerAccountId = "1001"
        adUnit = RewardedVideoAdUnit(configId: "1001-1")

        Prebid.shared.storedAuctionResponse = "sample_video_response"
        
    }
    
    func setupAMRewardedVideo() {
        amRewardedAd = GADRewardedAd(adUnitID: amAdUnitId)
    }
    
    func setupMPRewardedVideo() {
        MPRewardedVideo.setDelegate(self, forAdUnitId: mpAdUnitId)
    }
    
    func loadAMRewardedVideo() {
        
        adUnit.fetchDemand(adObject: self.amRequest) { (resultCode: ResultCode) in
            
            self.amRewardedAd.load(self.amRequest) { error in
                if let error = error {
                    print("loadAMRewardedVideo failed:\(error)")
                } else {
                    
                    if self.amRewardedAd?.isReady == true {
                        self.amRewardedAd?.present(fromRootViewController: self, delegate:self)
                    }
                    
                }
            }
            
        }
    }
    
    func loadMPRewardedVideo() {
        
        let targetingDict = NSMutableDictionary()
        
        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: targetingDict) { (resultCode: ResultCode) in
            print("Prebid demand fetch for mopub \(resultCode.name())")

            if let targetingDict = targetingDict as? Dictionary<String, String> {
                let keywords = Utils.shared.convertDictToMoPubKeywords(dict: targetingDict)
                MPRewardedVideo.loadAd(withAdUnitID: self.mpAdUnitId, keywords: keywords, userDataKeywords: nil, location: nil, mediationSettings: nil)
            }
        }
    }
    
    //MARK: - GADRewardedAdDelegate
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
        print("rewardedAdDidFailToPresentWithError:\(error.localizedDescription)")
    }

    //MARK: - MPRewardedVideoDelegate
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        MPRewardedVideo.presentAd(forAdUnitID: adUnitID, from: self, with: nil)
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        print("rewardedVideoAdDidFailToLoad:\(error.localizedDescription)")
    }
}
