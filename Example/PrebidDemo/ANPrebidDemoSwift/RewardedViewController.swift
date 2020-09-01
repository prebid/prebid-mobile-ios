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
    
    public var adServerName: String = ""
    
    private var adUnit: AdUnit!
    
    private var amRewardedAd: GADRewardedAd!
    private let amRequest = GADRequest()
    
    private let amAdUnitId = "/19968336/PrebidMobile_RewardedVideo"
    private let mpAdUnitId = "413bf4485439404d8535cd531feef7e1"
    
    private let anAdUnitID = "19880949"
    
    override func viewDidLoad() {
        
//        Prebid.shared.prebidServerHost = PrebidHost.Custom
//        do {
//            try Prebid.shared.setCustomPrebidServer(url: "https://ib.adnxs.com/openrtb2/prebid")
//        } catch {
//            print("error setting the URL")
//        }
//
//        setupPB(host: .Custom, accountId: "9325", storedResponse: "sample_video_response")
//
//        let adUnit = RewardedVideoAdUnit(configId: anAdUnitID)
        
        //Prebid server
        //configId: 2c0af852-a55d-49dc-a5ca-ef7e141f73cc
        //Account: aecd6ef7-b992-4e99-9bb8-65e2d984e1dd
        
        setupPB(host: .Appnexus, accountId: "aecd6ef7-b992-4e99-9bb8-65e2d984e1dd", storedResponse: "sample_video_response")
        let adUnit = RewardedVideoAdUnit(configId: "2c0af852-a55d-49dc-a5ca-ef7e141f73cc")
        
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        
        adUnit.parameters = parameters
        
        self.adUnit = adUnit
        
        //adServerName = "DFP"
        
        if (adServerName == "DFP") {
            self.amRewardedAd = GADRewardedAd(adUnitID: amAdUnitId)
            
            self.adUnit.fetchDemand(adObject: self.amRequest) { [weak self] (resultCode: ResultCode) in
                
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
            
        } else if (adServerName == "MoPub") {
            
            let targetingDict = NSMutableDictionary()
            
            MPRewardedVideo.setDelegate(self, forAdUnitId: mpAdUnitId)
            
            //Do any additional setup after loading the view, typically from a nib.
            self.adUnit.fetchDemand(adObject: targetingDict) { [weak self] (resultCode: ResultCode) in
                print("Prebid demand fetch for mopub \(resultCode.name())")

                if let targetingDict = targetingDict as? Dictionary<String, String> {
                    let keywords = Utils.shared.convertDictToMoPubKeywords(dict: targetingDict)
                    MPRewardedVideo.loadAd(withAdUnitID: self?.mpAdUnitId, keywords: keywords, userDataKeywords: nil, mediationSettings: nil)
                }
            }
        }
    }
    
    func setupPB(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
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
                MPRewardedVideo.loadAd(withAdUnitID: self?.mpAdUnitId, keywords: keywords, userDataKeywords: nil, mediationSettings: nil);
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
    
    func rewardedVideoAdDidDisappear(forAdUnitID adUnitID: String!) {
    
    }
}
