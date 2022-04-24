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
import AppLovinSDK

import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters
import PrebidMobileMAXAdapters

// Stored Impressions
fileprivate let storedImpDisplayInterstitial            = "imp-prebid-display-interstitial-320-480"
fileprivate let storedImpVideoInterstitial              = "imp-prebid-video-interstitial-320-480"

// Stored Responses
fileprivate let storedResponseDisplayInterstitial       = "response-prebid-display-interstitial-320-480"
fileprivate let storedResponseVideoInterstitial         = "response-prebid-video-interstitial-320-480"

// GAM
fileprivate let gamAdUnitDisplayInterstitialOriginal    = "/21808260008/prebid-demo-app-original-api-display-interstitial"
fileprivate let gamAdUnitVideoInterstitialOriginal      = "/21808260008/prebid-demo-app-original-api-video-interstitial"

fileprivate let gamAdUnitDisplayInterstitialRendering   = "/21808260008/prebid_oxb_html_interstitial"
fileprivate let gamAdUnitVideoInterstitialRendering     = "/21808260008/prebid_oxb_interstitial_video"

// AdMob
fileprivate let adMobAdUnitDisplayInterstitial          = "ca-app-pub-5922967660082475/3383099861"

// MAX
fileprivate let maxAdUnitDisplayInterstitial            = "8b3b31b990417275"

class InterstitialViewController:
    UIViewController,
    InterstitialAdUnitDelegate,
    GADFullScreenContentDelegate,
    MAAdDelegate {

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
    
    // MAX
    private var maxAdUnit: MediationInterstitialAdUnit!
    private var maxMediationDelegate: MAXMediationInterstitialUtils!
    private var maxInterstitial: MAInterstitialAd!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAM()
        case .inApp             : setupAndLoadInAppInterstitial()
        case .renderingGAM      : setupAndLoadGAMRenderingInterstitial()
        case .renderingAdMob    : setupAndLoadAdMobRenderingInterstitial()
        // To run this example you should create your own MAX ad unit.
        case .renderingMAX      : setupAndLoadMAXRenderingInterstitial()
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
        setupPrebidServer(storedResponse: storedResponseDisplayInterstitial)

        adUnit = InterstitialAdUnit(configId: storedImpDisplayInterstitial)
   
        loadAMInterstitial(gamAdUnitDisplayInterstitialOriginal)
    }
    
    func setupAndLoadInAppInterstitial() {
        switch adFormat {
        case .html:
            loadInAppInterstitial()
        case .vast:
            loadInAppVideoInterstitial()
        }
    }
    
    func setupAndLoadGAMRenderingInterstitial() {
        switch adFormat {
        case .html:
            loadGAMRenderingInterstitial()
        case .vast:
            loadGAMRenderingVideoInterstitial()
        }
    }
    
    func setupAndLoadAdMobRenderingInterstitial() {
        switch adFormat {
        case .html:
            loadAdMobRenderingDisplayInterstitial()
        case .vast:
            loadAdMobRenderingVideoInterstitial()
        }
    }
    
    func setupAndLoadMAXRenderingInterstitial() {
        switch adFormat {
        case .html:
            loadMAXRenderingDisplayInterstitial()
        case .vast:
            loadMAXRenderingVideoInterstitial()
        }
    }
    
    // Setup Prebid
    
    func setupPrebidServer(storedResponse: String) {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")

        Prebid.shared.storedAuctionResponse = storedResponse
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
                    do {
                        print(try ad.canPresent(fromRootViewController: self!))
                    } catch {
                        
                    }
                    ad.present(fromRootViewController: self!)
                }
            }
        }
    }
            
    func loadInAppInterstitial() {
        setupPrebidServer(storedResponse: storedResponseDisplayInterstitial)
        
        renderingInterstitial = InterstitialRenderingAdUnit(configID: storedImpDisplayInterstitial)
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    func loadGAMRenderingInterstitial() {
        setupPrebidServer(storedResponse: storedResponseDisplayInterstitial)

        let eventHandler = GAMInterstitialEventHandler(adUnitID: gamAdUnitDisplayInterstitialRendering)
        renderingInterstitial = InterstitialRenderingAdUnit(configID: storedImpDisplayInterstitial, eventHandler: eventHandler)
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    // AdMob
    func loadAdMobRenderingDisplayInterstitial() {
        setupPrebidServer(storedResponse: storedResponseDisplayInterstitial)
        
        mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: self.gadRequest)
        admobAdUnit = MediationInterstitialAdUnit(configId: storedImpDisplayInterstitial, mediationDelegate: mediationDelegate!)
        admobAdUnit?.fetchDemand(completion: { [weak self]result in
            let extras = GADCustomEventExtras()
            let prebidExtras = self?.mediationDelegate!.getEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self?.gadRequest.register(extras)
            
            GADInterstitialAd.load(withAdUnitID: adMobAdUnitDisplayInterstitial, request: self?.gadRequest) { [weak self] ad, error in
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
        setupPrebidServer(storedResponse: storedResponseVideoInterstitial)

        mediationDelegate = AdMobMediationInterstitialUtils(gadRequest: self.gadRequest)
        admobAdUnit = MediationInterstitialAdUnit(configId: storedImpVideoInterstitial, mediationDelegate: mediationDelegate!)
        admobAdUnit?.fetchDemand(completion: { [weak self]result in
            let extras = GADCustomEventExtras()
            let prebidExtras = self?.mediationDelegate!.getEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self?.gadRequest.register(extras)
            
            GADInterstitialAd.load(withAdUnitID: adMobAdUnitDisplayInterstitial, request: self?.gadRequest) { [weak self] ad, error in
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
    
    // MAX
    func loadMAXRenderingDisplayInterstitial() {
        setupPrebidServer(storedResponse: storedResponseDisplayInterstitial)
        maxInterstitial = MAInterstitialAd(adUnitIdentifier: maxAdUnitDisplayInterstitial)
        maxMediationDelegate = MAXMediationInterstitialUtils(interstitialAd: maxInterstitial)
        maxAdUnit = MediationInterstitialAdUnit(configId: storedImpDisplayInterstitial,
                                                mediationDelegate: maxMediationDelegate)
        
        maxAdUnit.fetchDemand(completion: { result in
            self.maxInterstitial.delegate = self
            self.maxInterstitial.load()
        })
    }
    
    func loadMAXRenderingVideoInterstitial() {
        setupPrebidServer(storedResponse: storedResponseVideoInterstitial)
        maxInterstitial = MAInterstitialAd(adUnitIdentifier: maxAdUnitDisplayInterstitial)
        maxMediationDelegate = MAXMediationInterstitialUtils(interstitialAd: maxInterstitial)
        maxAdUnit = MediationInterstitialAdUnit(configId: storedImpVideoInterstitial, mediationDelegate: maxMediationDelegate)
        
        maxAdUnit.fetchDemand(completion: { result in
            self.maxInterstitial.delegate = self
            self.maxInterstitial.load()
        })
    }
    
    //MARK: - Interstitial VAST
    
    func setupAndLoadAMInterstitialVAST() {
        setupPrebidServer(storedResponse: storedResponseVideoInterstitial)

        let adUnit = VideoInterstitialAdUnit(configId: storedImpVideoInterstitial)
        let parameters = VideoParameters()
        parameters.mimes = ["video/mp4"]
        
        parameters.protocols = [Signals.Protocols.VAST_2_0]
        // parameters.protocols = [Signals.Protocols(2)]
        
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        // parameters.playbackMethod = [Signals.PlaybackMethod(2)]
        
        adUnit.parameters = parameters
        
        self.adUnit = adUnit
        
        loadAMInterstitial(gamAdUnitVideoInterstitialOriginal)
    }
    
    func loadInAppVideoInterstitial() {
        setupPrebidServer(storedResponse: storedResponseVideoInterstitial)
        
        renderingInterstitial = InterstitialRenderingAdUnit(configID: storedImpVideoInterstitial)
        renderingInterstitial.adFormats = [.video]
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
    }
    
    func loadGAMRenderingVideoInterstitial() {
        setupPrebidServer(storedResponse: storedResponseVideoInterstitial)

        let eventHandler = GAMInterstitialEventHandler(adUnitID: gamAdUnitVideoInterstitialRendering)
        renderingInterstitial = InterstitialRenderingAdUnit(configID: storedImpVideoInterstitial, eventHandler: eventHandler)
        renderingInterstitial.adFormats = [.video]
        renderingInterstitial.delegate = self
        
        renderingInterstitial.loadAd()
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
    
    // MARK: - MAAdDelegate
    
    func didLoad(_ ad: MAAd) {
       print("didLoad(_ ad: MAAd)")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Log.error(error.message)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Log.error(error.message)
    }
    
    func didDisplay(_ ad: MAAd) {
        print("didDisplay(_ ad: MAAd)")
    }
    
    func didHide(_ ad: MAAd) {
        print("didHide(_ ad: MAAd)")
    }
    
    func didClick(_ ad: MAAd) {
        print("didClick(_ ad: MAAd)")
    }
}
