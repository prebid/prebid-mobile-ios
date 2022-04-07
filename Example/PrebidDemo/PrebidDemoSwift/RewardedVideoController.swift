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
import MoPubSDK


class RewardedVideoController: UIViewController, MPRewardedVideoDelegate {
    
    @IBOutlet var adServerLabel: UILabel!
    
    var adServerName: String = ""
    
    private var adUnit: AdUnit!
    
    private let amRequest = GAMRequest()
    
    private let amRubiconAdUnitId = "/19968336/PSP_M29_Abhishek_Video"
    private let mpRubiconAdUnitId = "46d2ebb3ccd340b38580b5d3581c6434"
    
    override func viewDidLoad() {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["f2a7d257f84db8b1c4d7dd441323ad98"]

        adServerLabel.text = adServerName
        
        if (adServerName == "DFP") {
            setupAndLoadAMRewardedVideo()
        } else if (adServerName == "MoPub") {
            setupAndLoadMPRewardedVideo()
        }
    }
    
    func setupAndLoadAMRewardedVideo() {
        setupPBRubiconRewardedVideo()
        loadAMRewardedVideo()
    }
    
    func setupAndLoadMPRewardedVideo() {
        setupPBRubiconRewardedVideo()
        setupMPRubiconRewardedVideo()
        loadMPRewardedVideo()
    }
    
    //Setup PB
    func setupPBRubiconRewardedVideo() {

//        setupPB(host: .Appnexus, accountId: "9325", storedResponse: "")

        let adUnit = RewardedVideoAdUnit(configId: "24659163")

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
//        Prebid.shared.prebidServerHost = .Appnexus
//        Prebid.shared.prebidServerAccountId = "9325"
//        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    //Setup AdServer
    
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
            
            GADRewardedAd.load(withAdUnitID: self.amRubiconAdUnitId, request: self.amRequest) { (ad, error) in
                if let error = error {
                    print("loadAMRewardedVideo failed:\(error)")
                } else if let ad = ad {
                    
                    ad.present(fromRootViewController: self, userDidEarnRewardHandler: {
                        let reward = ad.adReward
                        // TODO: Reward the user.
                      })

                }
            }
        }
    }
    
    func loadMPRewardedVideo() {
        
        adUnit.fetchDemand { [weak self] (resultCode: ResultCode, targetingDict: [String : String]?) in
            print("Prebid demand fetch for mopub \(resultCode.name())")
            
            guard let targetingDict = targetingDict else {
                return
            }
            
            let keywords = Utils.shared.convertDictToMoPubKeywords(dict: targetingDict)
            MPRewardedVideo.loadAd(withAdUnitID: self?.mpRubiconAdUnitId, keywords: keywords, userDataKeywords: nil, location: nil, mediationSettings: nil)
        }
    }

    //MARK: - MPRewardedVideoDelegate
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        MPRewardedVideo.presentAd(forAdUnitID: adUnitID, from: self, with: nil)
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        print("rewardedVideoAdDidFailToLoad:\(error.localizedDescription)")
    }
}
