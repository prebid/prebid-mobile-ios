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

class InterstitialViewController: UIViewController, MPInterstitialAdControllerDelegate {

    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""
    var bannerFormat: BannerFormat = .html
    
    private var adUnit: AdUnit!
    
    private let amRequest = GAMRequest()
    private var amInterstitial: GAMInterstitialAd!

    private var mpInterstitial: MPInterstitialAdController!

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName

        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            
            switch bannerFormat {
            case .html:
                setupAndLoadAMInterstitial()
            case .vast:
                setupAndLoadAMInterstitialVAST()
            }

        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            
            switch bannerFormat {
            case .html:
                setupAndLoadMPInterstitial()
            case .vast:
                setupAndLoadMPInterstitialVAST()
            }
        }
    }

    //MARK: - Interstitial
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
    
    //Load
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

}
