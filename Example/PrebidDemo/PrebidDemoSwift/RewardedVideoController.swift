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
import PrebidMobileGAMEventHandlers
import PrebidMobileMoPubAdapters

class RewardedVideoController:
        UIViewController,
        MPRewardedVideoDelegate,
        RewardedAdUnitDelegate,
        MPRewardedAdsDelegate {
    
    @IBOutlet var adServerLabel: UILabel!
    
    var integrationKind: IntegrationKind = .undefined
    
    private var adUnit: AdUnit!
    
    private let amRequest = GAMRequest()
    
    private var rewardedAdUnit: RewardedAdUnit!
    public var mopubRewardedAdUnit: MediationRewardedAdUnit!
    
    private let amRubiconAdUnitId = "/5300653/test_adunit_vast_rewarded-video_pavliuchyk"
    private let mpRubiconAdUnitId = "46d2ebb3ccd340b38580b5d3581c6434"
        
    override func viewDidLoad() {
        
        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAMRewardedVideo()
        case .originalMoPub     : setupAndLoadMPRewardedVideo()
        case .originalAdMob     : print("TODO: Add Example")
        case .inApp             : setupAndLoadInAppRewarded()
        case .renderingGAM      : setupAndLoadGAMRenderingRewarded()
        case .renderingMoPub    : setupAndLoadMoPubRenderingRewardedVideo()
        case .renderingAdMob    : print("TODO: Add Example")
        case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
    }
    
    func setupAndLoadGAMRewardedVideo() {
        setupPBRubiconRewardedVideo()
        loadGAMRewardedVideo()
    }
    
    func setupAndLoadMPRewardedVideo() {
        setupPBRubiconRewardedVideo()
        setupMPRubiconRewardedVideo()
        loadMPRewardedVideo()
    }
    
    func setupAndLoadInAppRewarded() {
        setupOpenXPrebid()
        loadInAppRewardedVideo()
    }
    
    func setupAndLoadGAMRenderingRewarded() {
        setupOpenXPrebid()
        loadGAMRenderingRewardedVideo()
    }
    
    func setupAndLoadMoPubRenderingRewardedVideo() {
        setupOpenXPrebid()
        
        loadMoPubRenderingRewardedVideo()
    }
    
    // MARK: - Setup Servers
    
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
    
    func setupOpenXPrebid() {
        PrebidRenderingConfig.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
    }
    
    //Setup AdServer
    
    func setupMPRubiconRewardedVideo() {
        MPRewardedVideo.setDelegate(self, forAdUnitId: mpRubiconAdUnitId)
    }
    
    // MARK: Load Ad
    
    func loadGAMRewardedVideo() {
        
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
    
    func loadInAppRewardedVideo() {
        rewardedAdUnit = RewardedAdUnit(configID: "12f58bc2-b664-4672-8d19-638bcc96fd5c")
        rewardedAdUnit.delegate = self
        
        rewardedAdUnit.loadAd()
    }
    
    func loadGAMRenderingRewardedVideo() {
        let eventHandler = GAMRewardedAdEventHandler(adUnitID: "/21808260008/prebid_oxb_rewarded_video_test")
        rewardedAdUnit = RewardedAdUnit(configID: "12f58bc2-b664-4672-8d19-638bcc96fd5c", eventHandler: eventHandler)
        rewardedAdUnit.delegate = self
        
        rewardedAdUnit.loadAd()
    }
    
    func loadMoPubRenderingRewardedVideo() {
        
        mopubRewardedAdUnit = MediationRewardedAdUnit(configId: "12f58bc2-b664-4672-8d19-638bcc96fd5c",
                                                      mediationDelegate: MoPubMediationUtils())
        
        let bidInfoWrapper = MediationBidInfoWrapper()

        mopubRewardedAdUnit.fetchDemand(with: bidInfoWrapper) { [weak self] result in
            guard let self = self else {
                return
            }
            
            MPRewardedAds.setDelegate(self, forAdUnitId: "7538cc74d2984c348bc14caafa3e3395")
            MPRewardedAds.loadRewardedAd(withAdUnitID: "7538cc74d2984c348bc14caafa3e3395",
                                         keywords: bidInfoWrapper.keywords as String?,
                                         userDataKeywords: nil,
                                         customerId: "testCustomerId",
                                         mediationSettings: [],
                                         localExtras: bidInfoWrapper.localExtras)
        }
    }

    // MARK: - MPRewardedVideoDelegate
    
    func rewardedVideoAdDidLoad(forAdUnitID adUnitID: String!) {
        MPRewardedVideo.presentAd(forAdUnitID: adUnitID, from: self, with: nil)
    }
    
    func rewardedVideoAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        print("rewardedVideoAdDidFailToLoad:\(error.localizedDescription)")
    }
    
    // MARK: - MPRewardedAdsDelegate
    
    func rewardedAdDidLoad(forAdUnitID adUnitID: String!) {
        MPRewardedAds.presentRewardedAd(forAdUnitID: adUnitID,
                                        from: self,
                                        with: nil)
    }
    
    func rewardedAdDidFailToLoad(forAdUnitID adUnitID: String!, error: Error!) {
        print("rewardedAdDidFailToLoad with error: \(error.localizedDescription)")
    }
    
    // MARK: - RewardedAdUnitDelegate
    
    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        rewardedAdUnit.show(from: self)
    }
    
    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        print("In-App failed to load ad unit: \(error?.localizedDescription ?? "")")
    }
}
