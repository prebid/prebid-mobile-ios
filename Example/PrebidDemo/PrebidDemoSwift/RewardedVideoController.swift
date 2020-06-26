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
    
    private let amRubiconAdUnitId = "/5300653/test_adunit_vast_rewarded-video_pavliuchyk"
    private let mpRubiconAdUnitId = "46d2ebb3ccd340b38580b5d3581c6434"
    
    override func viewDidLoad() {
        
        adServerLabel.text = adServerName
        
        if (adServerName == "DFP") {
            setupAndLoadAMRewardedVideo()
        } else if (adServerName == "MoPub") {
            setupAndLoadMPRewardedVideo()
        }
    }
    
    func setupAndLoadAMRewardedVideo() {
        setupPBRubiconRewardedVideo()
        setupAMRubiconRewardedVideo()
        loadAMRewardedVideo()
    }
    
    func setupAndLoadMPRewardedVideo() {
        setupPBRubiconRewardedVideo()
        setupMPRubiconRewardedVideo()
        loadMPRewardedVideo()
    }
    
    //Setup PB
    func setupPBRubiconRewardedVideo() {

        setupPB(host: .Rubicon, accountId: "1001", storedResponse: "sample_video_response")

        let adUnit = RewardedVideoAdUnit(configId: "1001-1")
        
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        // parameters.protocols = [Signals.Protocols(2)]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        //parameters.playbackMethod = [Signals.PlaybackMethod(2)]
        
        adUnit.parameters = parameters
        
        self.adUnit = adUnit
        
    }
    
    func setupPB(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    //Setup AdServer
    func setupAMRubiconRewardedVideo() {
        amRewardedAd = GADRewardedAd(adUnitID: amRubiconAdUnitId)
    }
    
    func setupMPRubiconRewardedVideo() {
        MPRewardedVideo.setDelegate(self, forAdUnitId: mpRubiconAdUnitId)
    }
    
    //Load
    func loadAMRewardedVideo() {
        
        adUnit.fetchDemand(adObject: self.amRequest) { [weak self] (resultCode: ResultCode) in
            
            guard let self = self else {
                print("self is nil")
                return
            }
            
            self.amRewardedAd.load(self.amRequest) { error in
                if let error = error {
                    print("loadAMRewardedVideo failed:\(error)")
                } else {
                    
                    if self.amRewardedAd.isReady == true {
                        self.amRewardedAd.present(fromRootViewController: self, delegate:self)
                    }
                }
            }
        }
    }
    
    func loadMPRewardedVideo() {
        
        let targetingDict = NSMutableDictionary()
        
        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: targetingDict) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for mopub \(resultCode.name())")

            if let targetingDict = targetingDict as? Dictionary<String, String> {
                let keywords = Utils.shared.convertDictToMoPubKeywords(dict: targetingDict)
                MPRewardedVideo.loadAd(withAdUnitID: self?.mpRubiconAdUnitId, keywords: keywords, userDataKeywords: nil, location: nil, mediationSettings: nil)
            }
        }
    }
    
    //MARK: - GADRewardedAdDelegate
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }

    func rewardedAdDidPresent(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad presented.")
    }

    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        print("Rewarded ad dismissed.")
    }

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
