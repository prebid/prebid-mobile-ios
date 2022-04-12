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
import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters

// Stored Impressions
fileprivate let storedImpVideoRewarded                  = "imp-prebid-video-rewarded-320-480"

// Stored Responses
fileprivate let storedResponseVideoRewarded             = "response-prebid-video-rewarded-320-480"

// GAM

fileprivate let gamAdUnitVideoRewardedOriginal      = "/21808260008/prebid-demo-app-original-api-video-interstitial"

fileprivate let gamAdUnitVideoRewardedRendering     = "/21808260008/prebid_oxb_rewarded_video_test"

// AdMob

fileprivate let adMobAdUnitDisplayInterstitial          = "ca-app-pub-5922967660082475/7397370641"

class RewardedVideoController:
        UIViewController,
        RewardedAdUnitDelegate,
        GADFullScreenContentDelegate {
    
    @IBOutlet var adServerLabel: UILabel!
    
    var integrationKind: IntegrationKind = .undefined
    
    private var adUnit: AdUnit!
    
    private let amRequest = GAMRequest()
    
    private var rewardedAdUnit: RewardedAdUnit!
    public var admobRewardedAdUnit: MediationRewardedAdUnit!
            
    private var gadRewardedAd: GADRewardedAd?
    
    override func viewDidLoad() {
        
        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAMRewardedVideo()
        case .inApp             : setupAndLoadInAppRewarded()
        case .renderingGAM      : setupAndLoadGAMRenderingRewarded()
        case .renderingAdMob    : setupAndLoadAdMobRenderingRewardedVideo()
        case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
    }
    
    func setupAndLoadGAMRewardedVideo() {
        setupPrebidServer(storedResponse: storedResponseVideoRewarded)
        
        loadGAMRewardedVideo()
    }
    
    func setupAndLoadInAppRewarded() {
        setupPrebidServer(storedResponse: storedResponseVideoRewarded)
        loadInAppRewardedVideo()
    }
    
    func setupAndLoadGAMRenderingRewarded() {
        setupPrebidServer(storedResponse: storedResponseVideoRewarded)
        loadGAMRenderingRewardedVideo()
    }
    
    func setupAndLoadAdMobRenderingRewardedVideo() {
        setupPrebidServer(storedResponse: storedResponseVideoRewarded)
        loadAdMobRenderingRewardedVideo()
    }
        
    // MARK: - Setup Servers
    
    func setupPB(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    func setupPrebidServer(storedResponse: String) {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")

        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    func setupOpenXPrebid() {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
    }
    
    // MARK: Load Ad
    
    func loadGAMRewardedVideo() {
        
        let adUnit = RewardedVideoAdUnit(configId: storedImpVideoRewarded)
        
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        // parameters.protocols = [Signals.Protocols(2)]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        //parameters.playbackMethod = [Signals.PlaybackMethod(2)]
        
        adUnit.parameters = parameters
        
        self.adUnit = adUnit
        
        adUnit.fetchDemand(adObject: self.amRequest) { [weak self] (resultCode: ResultCode) in
            
            guard let self = self else {
                print("self is nil")
                return
            }
            
            GADRewardedAd.load(withAdUnitID: gamAdUnitVideoRewardedOriginal, request: self.amRequest) { (ad, error) in
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
    
    func loadInAppRewardedVideo() {
        rewardedAdUnit = RewardedAdUnit(configID: storedImpVideoRewarded)
        rewardedAdUnit.delegate = self
        
        rewardedAdUnit.loadAd()
    }
    
    func loadGAMRenderingRewardedVideo() {
        let eventHandler = GAMRewardedAdEventHandler(adUnitID: gamAdUnitVideoRewardedRendering)
        rewardedAdUnit = RewardedAdUnit(configID: storedImpVideoRewarded, eventHandler: eventHandler)
        rewardedAdUnit.delegate = self
        
        rewardedAdUnit.loadAd()
    }
    
    func loadAdMobRenderingRewardedVideo() {
        let request = GADRequest()
        let mediationDelegate = AdMobMediationRewardedUtils(gadRequest: request)
        admobRewardedAdUnit = MediationRewardedAdUnit(configId: storedImpVideoRewarded, mediationDelegate: mediationDelegate)
        admobRewardedAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            GADRewardedAd.load(withAdUnitID: adMobAdUnitDisplayInterstitial, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    Log.error(error.localizedDescription)
                    return
                }
                self.gadRewardedAd = ad
                self.gadRewardedAd?.fullScreenContentDelegate = self
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.gadRewardedAd?.present(fromRootViewController: self, userDidEarnRewardHandler: {
                        print("Reward user")
                    })
                }
            }
        }
    }
    
    // MARK: - RewardedAdUnitDelegate
    
    func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
        rewardedAdUnit.show(from: self)
    }
    
    func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
        print("In-App failed to load ad unit: \(error?.localizedDescription ?? "")")
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("didFailToPresentFullScreenContentWithError")
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("adDidRecordImpression")
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidPresentFullScreenContent")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adWillDismissFullScreenContent")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("adDidDismissFullScreenContent")
    }
}
