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

import MoPubSDK
import PrebidMobileMoPubAdapters
import PrebidMobileGAMEventHandlers

class InterstitialViewController:
    UIViewController,
    MPInterstitialAdControllerDelegate,
    InterstitialAdUnitDelegate {

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

    // MoPub (Original)
    private var mpInterstitial: MPInterstitialAdController!
    
    // In-App
    private var renderingInterstitial: InterstitialRenderingAdUnit!
    private var renderingMoPubInterstitial: MediationInterstitialAdUnit!
    
    private let mediationDelegate: PrebidMediationDelegate = MoPubMediationUtils()

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAM()
        case .originalMoPub     : setupAndLoadMoPub()
        case .inApp             : setupAndLoadInAppInterstitial()
        case .renderingGAM      : setupAndLoadGAMRenderingInterstitial()
        case .renderingMoPub    : setupAndLoadMoPubRenderingInterstitial()
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
    
    func setupAndLoadMoPub() {
        switch adFormat {
        case .html:
            setupAndLoadMPInterstitial()
        case .vast:
            setupAndLoadMPInterstitialVAST()
        }
    }
    
    func setupAndLoadAMInterstitial() {
        setupPBRubiconInterstitial()

        //Xandr "/19968336/PrebidMobileValidator_Interstitial"
        loadAMInterstitial("/5300653/pavliuchyk_test_adunit_1x1_puc")
    }
    
    func setupAndLoadMPInterstitial() {
        setupPBRubiconInterstitial()
        setupMPRubiconInterstitial()
        loadMPInterstitial()
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
    
    func setupAndLoadMoPubRenderingInterstitial() {
        setupOpenxRendering()
        
        switch adFormat {
        case .html:
            loadMoPubRenderingInterstitial()
        case .vast:
            loadMoPubRenderingVideoInterstitial()
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
    
    func setupMPAppNexusInterstitial() {
        setupMPInterstitial(adUnitId: "2829868d308643edbec0795977f17437")
    }

    func setupMPRubiconInterstitial() {
        setupMPInterstitial(adUnitId: "d5c75d9f0b8742cab579610930077c35")
    }
    
    func setupMPInterstitial(adUnitId: String) {
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitId)
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}

        self.mpInterstitial = MPInterstitialAdController(forAdUnitId: adUnitId)
        self.mpInterstitial.delegate = self
    }
        
    func setupOpenxRendering() {
        PrebidRenderingConfig.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
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
    
    func loadMPInterstitial() {
        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: mpInterstitial) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for mopub \(resultCode.name())")

            self?.mpInterstitial.loadAd()
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
    
    func loadMoPubRenderingInterstitial() {
        renderingMoPubInterstitial = MediationInterstitialAdUnit(configId: "5a4b8dcf-f984-4b04-9448-6529908d6cb6", mediationDelegate: mediationDelegate)
        
        mpInterstitial = MPInterstitialAdController(forAdUnitId: "e979c52714434796909993e21c8fc8da")
        mpInterstitial.delegate = self

        renderingMoPubInterstitial.fetchDemand(with: mpInterstitial) { [weak self] _ in
            self?.mpInterstitial.loadAd()
        }
    }
    
    //MARK: - Interstitial VAST
    
    func setupAndLoadAMInterstitialVAST() {
        setupPBRubiconInterstitialVAST()
        loadAMInterstitial("/5300653/test_adunit_vast_pavliuchyk")
    }
    
    func setupAndLoadMPInterstitialVAST() {
        setupPBRubiconInterstitialVAST()
        setupMPRubiconInterstitialVAST()
        loadMPInterstitial()
    }
    
    func loadInAppVideoInterstitial() {
        renderingInterstitial = InterstitialRenderingAdUnit(configID: "12f58bc2-b664-4672-8d19-638bcc96fd5c")
        renderingInterstitial.adFormat = .video
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    func loadGAMRenderingVideoInterstitial() {
        let eventHandler = GAMInterstitialEventHandler(adUnitID: "/21808260008/prebid_oxb_interstitial_video")
        renderingInterstitial = InterstitialRenderingAdUnit(configID: "12f58bc2-b664-4672-8d19-638bcc96fd5c", eventHandler: eventHandler)
        renderingInterstitial.adFormat = .video
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    func loadMoPubRenderingVideoInterstitial() {
        renderingMoPubInterstitial = MediationInterstitialAdUnit(configId: "12f58bc2-b664-4672-8d19-638bcc96fd5c", mediationDelegate: mediationDelegate)
        
        mpInterstitial = MPInterstitialAdController(forAdUnitId: "7e3146fc0c744afebc8547a4567da895")
        mpInterstitial.delegate = self

        renderingMoPubInterstitial.fetchDemand(with: mpInterstitial) { [weak self] _ in
            self?.mpInterstitial.loadAd()
        }
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
    
    //Setup AdServer
    
    func setupMPRubiconInterstitialVAST() {
        
        setupMPInterstitial(adUnitId: "fdafd17a5aeb41c798e6901a7f76f256")
    }

    //MARK: - MPInterstitialAdControllerDelegate
    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        print("Ad ready")
        if (self.mpInterstitial.ready ) {
            self.mpInterstitial.show(from: self)
        }
    }

    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        print("Ad not ready")
    }
    
    // MARK: - InterstitialAdUnitDelegate

    func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
        interstitial.show(from: self)
    }
}
