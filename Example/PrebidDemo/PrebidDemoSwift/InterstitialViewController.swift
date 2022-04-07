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

import PrebidMobile

import GoogleMobileAds

import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters

class InterstitialViewController:
    UIViewController,
    InterstitialAdUnitDelegate,
    GADFullScreenContentDelegate {

    // MARK: - UI Properties
    
    @IBOutlet var adServerLabel: UILabel!
    
    // MARK: - Public Properties

    var adFormat: AdFormat = .html
    var integrationKind: IntegrationKind = .undefined

    // MARK: - Ad Units
    
    // Prebid Original
    private var adUnit: AdUnit!
    
    // GAM (Original)
    private let amRequest = GAMRequest()
    private var amInterstitial: GAMInterstitialAd!
    
    // In-App
    private var renderingInterstitial: InterstitialRenderingAdUnit!
    
    // AdMob Rendering
    private var gadRequest = GADRequest()
    private var interstitial: GADInterstitialAd?
    private var admobAdUnit: MediationInterstitialAdUnit?
    private var mediationDelegate: AdMobMediationInterstitialUtils?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAM()
        case .originalAdMob     : print("There is no way to integrate original API with AdMob")
        case .inApp             : setupAndLoadInAppInterstitial()
        case .renderingGAM      : setupAndLoadGAMRenderingInterstitial()
        case .renderingAdMob    : setupAndLoadAdMobRenderingInterstitial()
        case .renderingMAX      : print("TODO: Add Example")
        case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
    }

    //MARK: - Interstitial
    
    func setupAndLoadGAM() {
        switch adFormat {
        case .html:
            setupAndLoadAMInterstitial()
        case .vast:
            setupAndLoadAMInterstitialVAST()
        }
    }
    
    func setupAndLoadAMInterstitial() {
        setupPBRubiconInterstitial()

        //Xandr "/19968336/PrebidMobileValidator_Interstitial"
        loadAMInterstitial("/5300653/pavliuchyk_test_adunit_1x1_puc")
    }
    
    func setupAndLoadInAppInterstitial() {
        setupOpenxRendering()
        
        switch adFormat {
        case .html:
            loadInAppInterstitial()
        case .vast:
            loadInAppVideoInterstitial()
        }
    }
    
    func setupAndLoadGAMRenderingInterstitial() {
        setupOpenxRendering()
        
        switch adFormat {
        case .html:
            loadGAMRenderingInterstitial()
        case .vast:
            loadGAMRenderingVideoInterstitial()
        }
    }
    
    func setupAndLoadAdMobRenderingInterstitial() {
        setupOpenxRendering()
        
        switch adFormat {
        case .html:
            loadAdMobRenderingInterstitial()
        case .vast:
            loadAdMobRenderingVideoInterstitial()
        }
    }
    
    //Setup PB
    func setupPBAppNexusInterstitial() {
        setupPBInterstitial(host: .Appnexus, accountId: "bfa84af2-bd16-4d35-96ad-31c6bb888df0", configId: "625c6125-f19e-4d5b-95c5-55501526b2a4", storedResponse: "")
    }

    func setupPBRubiconInterstitial() {
        setupPBInterstitial(host: .Rubicon, accountId: "1001", configId: "1001-1", storedResponse: "1001-rubicon-300x250")
    }
    
    func setupPBInterstitial(host: PrebidHost, accountId: String, configId: String, storedResponse: String) {
        setupPB(host: host, accountId: accountId, storedResponse: storedResponse)
        
        adUnit = InterstitialAdUnit(configId: configId)
        
//        Advanced interstitial support
//        adUnit = InterstitialAdUnit(configId: "625c6125-f19e-4d5b-95c5-55501526b2a4", minWidthPerc: 50, minHeightPerc: 70)

    }
    
    func setupPB(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    //Setup AdServer
        
    func setupOpenxRendering() {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
    }
    
    // MARK: - Load
    
    func loadAMInterstitial(_ adUnitID: String) {
        adUnit.fetchDemand(adObject: self.amRequest) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            
            GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID, request: self?.amRequest) { (ad, error) in
                if let error = error {
                      print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                      return
                } else if let ad = ad {
                    ad.present(fromRootViewController: self!)
                }
            }
        }
    }
            
    func loadInAppInterstitial() {
        renderingInterstitial = InterstitialRenderingAdUnit(configID: "5a4b8dcf-f984-4b04-9448-6529908d6cb6")
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    func loadGAMRenderingInterstitial() {
        let eventHandler = GAMInterstitialEventHandler(adUnitID: "/21808260008/prebid_oxb_html_interstitial")
        renderingInterstitial = InterstitialRenderingAdUnit(configID: "5a4b8dcf-f984-4b04-9448-6529908d6cb6", eventHandler: eventHandler)
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    // AdMob
    func loadAdMobRenderingInterstitial() {
        
        mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: self.gadRequest)
        admobAdUnit = MediationInterstitialAdUnit(configId: "5a4b8dcf-f984-4b04-9448-6529908d6cb6", mediationDelegate: mediationDelegate!)
        admobAdUnit?.fetchDemand(completion: { [weak self]result in
            let extras = GADCustomEventExtras()
            let prebidExtras = self?.mediationDelegate!.getEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self?.gadRequest.register(extras)
            
            GADInterstitialAd.load(withAdUnitID: "ca-app-pub-5922967660082475/3383099861", request: self?.gadRequest) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    Log.error(error.localizedDescription)
                    return
                }
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                self.interstitial?.present(fromRootViewController: self)
            }
        })
    }
    
    func loadAdMobRenderingVideoInterstitial() {
        mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: self.gadRequest)
        admobAdUnit = MediationInterstitialAdUnit(configId: "12f58bc2-b664-4672-8d19-638bcc96fd5c", mediationDelegate: mediationDelegate!)
        admobAdUnit?.fetchDemand(completion: { [weak self]result in
            let extras = GADCustomEventExtras()
            let prebidExtras = self?.mediationDelegate!.getEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self?.gadRequest.register(extras)
            
            GADInterstitialAd.load(withAdUnitID: "ca-app-pub-5922967660082475/3383099861", request: self?.gadRequest) { [weak self] ad, error in
                guard let self = self else { return }
                if let error = error {
                    Log.error(error.localizedDescription)
                    return
                }
                self.interstitial = ad
                self.interstitial?.fullScreenContentDelegate = self
                self.interstitial?.present(fromRootViewController: self)
            }
        })
    }
    
    //MARK: - Interstitial VAST
    
    func setupAndLoadAMInterstitialVAST() {
        setupPBRubiconInterstitialVAST()
        loadAMInterstitial("/5300653/test_adunit_vast_pavliuchyk")
    }
    
    func loadInAppVideoInterstitial() {
        renderingInterstitial = InterstitialRenderingAdUnit(configID: "12f58bc2-b664-4672-8d19-638bcc96fd5c")
        renderingInterstitial.adFormats = [.video]
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    func loadGAMRenderingVideoInterstitial() {
        let eventHandler = GAMInterstitialEventHandler(adUnitID: "/21808260008/prebid_oxb_interstitial_video")
        renderingInterstitial = InterstitialRenderingAdUnit(configID: "12f58bc2-b664-4672-8d19-638bcc96fd5c", eventHandler: eventHandler)
        renderingInterstitial.adFormats = [.video]
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    //Setup PB
    
    func setupPBRubiconInterstitialVAST() {
        setupPB(host: .Rubicon, accountId: "1001", storedResponse: "sample_video_response")
        
        let adUnit = VideoInterstitialAdUnit(configId: "1001-1")
        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        // parameters.protocols = [Signals.Protocols(2)]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        // parameters.playbackMethod = [Signals.PlaybackMethod(2)]
        
        adUnit.parameters = parameters
        
        self.adUnit = adUnit
    }
    
    // MARK: - InterstitialAdUnitDelegate

    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitial.show(from: self)
    }
    
    // MARK: - GADFullScreenContentDelegate
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Log.error(error.localizedDescription)
    }
    
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Log.info("adDidPresentFullScreenContent called")
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Log.info("adWillDismissFullScreenContent called")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Log.info("adDidDismissFullScreenContent called")
        interstitial = nil
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        Log.info("adDidRecordImpression called")
    }
}
