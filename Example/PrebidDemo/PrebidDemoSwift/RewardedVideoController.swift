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
    
    private let amRubiconAdUnitId = "/5300653/test_adunit_vast_rewarded-video_pavliuchyk"
    private let mpRubiconAdUnitId = "46d2ebb3ccd340b38580b5d3581c6434"
    private let admobPrebidAdUnitId = "ca-app-pub-5922967660082475/7397370641"
        
    private var gadRewardedAd: GADRewardedAd?
    
    override func viewDidLoad() {
        
        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAMRewardedVideo()
        case .originalAdMob     : print("TODO: Add Example")
        case .inApp             : setupAndLoadInAppRewarded()
        case .renderingGAM      : setupAndLoadGAMRenderingRewarded()
        case .renderingAdMob    : setupAndLoadAdMobRenderingRewardedVideo()
        case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
    }
    
    func setupAndLoadGAMRewardedVideo() {
        setupPBRubiconRewardedVideo()
        loadGAMRewardedVideo()
    }
    
    func setupAndLoadInAppRewarded() {
        setupOpenXPrebid()
        loadInAppRewardedVideo()
    }
    
    func setupAndLoadGAMRenderingRewarded() {
        setupOpenXPrebid()
        loadGAMRenderingRewardedVideo()
    }
    
    func setupAndLoadAdMobRenderingRewardedVideo() {
        setupOpenXPrebid()
        loadAdMobRenderingRewardedVideo()
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
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
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
    
    func loadAdMobRenderingRewardedVideo() {
        let request = GADRequest()
        let mediationDelegate = AdMobMediationRewardedUtils(gadRequest: request)
        admobRewardedAdUnit = MediationRewardedAdUnit(configId: "12f58bc2-b664-4672-8d19-638bcc96fd5c", mediationDelegate: mediationDelegate)
        admobRewardedAdUnit.fetchDemand { [weak self] result in
            guard let self = self else { return }
            GADRewardedAd.load(withAdUnitID: self.admobPrebidAdUnitId, request: request) { [weak self] ad, error in
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
