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
import PrebidMobileGAMEventHandlers

enum AdFormat: Int {
    case html
    case vast
}

class BannerController:
        UIViewController,
        GADBannerViewDelegate,      // GMA SDK
        MPAdViewDelegate,           // MoPub
        BannerViewDelegate          // Prebid Rendering
{

    // MARK: - UI Properties
    
    @IBOutlet var appBannerView: UIView!

    @IBOutlet var adServerLabel: UILabel!
    
    // MARK: - Public Properties

    var bannerFormat    : AdFormat = .html
    var integrationKind : IntegrationKind = .undefined
    
    // MARK: - Private Properties
    
    let width = 300
    let height = 250
    
    // Prebid Original
    private var prebidAdUnit: AdUnit!
    
    // GAM
    private let gamRequest = GAMRequest()
    private var gamBanner: GAMBannerView!
    
    // MoPub
    private var mpBanner: MPAdView!
    
    // Prebid Rendering
    private var prebidBannerView: BannerView!           // (In-App and GAM)
    private var prebidMoPubAdUnit: MoPubBannerAdUnit!   // (MoPub)
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
            case .originalGAM       : setupAndLoadGAM()
            case .originalMoPub     : setupAndLoadMPBanner()
            case .inApp             : setupAndLoadInAppBanner()
            case .renderingGAM      : setupAndLoadGAMRendering()
            case .renderingMoPub    : setupAndLoadMoPubRendering()
            case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }

//        enableCOPPA()
//        addFirstPartyData(adUnit: adUnit)
//        setStoredResponse()
//        setRequestTimeoutMillis()
//        enablePbsDebug()
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        prebidAdUnit?.stopAutoRefresh()
    }

    //MARK: - Internal Methods
    
    func setupAndLoadGAM() {
        switch bannerFormat {
            
        case .html:
            setupAndLoadGAMBanner()
        case .vast:
            setupAndLoadGAMBannerVAST()
        }
    }
    
    func setupAndLoadGAMBanner() {
        setupRubiconBanner(width: width, height: height)
        setupGAMBannerRubicon(width: width, height: height)
        
        loadGAMBanner()
    }

    func setupAndLoadMPBanner() {
        setupRubiconBanner(width: width, height: height)
        setupMPBannerRubicon(width: width, height: height)
        
        loadMPBanner()
    }
    
    func setupAndLoadInAppBanner() {
        setupOpenxRenderingBanner()
        
        switch bannerFormat {
        case .html:
            loadInAppBanner()
        case .vast:
            loadInAppVideoBanner()
        }
    }
    
    func setupAndLoadGAMRendering() {
        setupOpenxRenderingBanner()
        
        switch bannerFormat {
        case .html:
            loadGAMRenderingBanner()
        case .vast:
            loadGAMRenderingVideoBanner()
        }
    }
    
    func setupAndLoadMoPubRendering() {
        setupOpenxRenderingBanner()
        
        setupMoPubRenderingBanner(width: 320, height: 50)
        
        loadMoPubRenderingBanner()
    }
    
    // MARK: Setup PBS
    
    func setupAppNexusBanner(width: Int, height: Int) {
        setupBannerAdUnit(host: .Appnexus,
                          accountId: "bfa84af2-bd16-4d35-96ad-31c6bb888df0",
                          configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45",
                          storedResponse: "",
                          width: width, height: height)
    }

    func setupRubiconBanner(width: Int, height: Int) {
        setupBannerAdUnit(host: .Rubicon,
                          accountId: "1001",
                          configId: "1001-1",
                          storedResponse: "1001-rubicon-300x250",
                          width: width, height: height)
    }
    
    func setupBannerAdUnit(host: PrebidHost, accountId: String, configId: String, storedResponse: String, width: Int, height: Int) {
        
        setupPrebidServer(host: host,
                          accountId: accountId,
                          storedResponse: storedResponse)
        
        let bannerAdUnit = BannerAdUnit(configId: configId, size: CGSize(width: width, height: height))
        
        let parameters = BannerAdUnit.Parameters()

        parameters.api = [Signals.Api.MRAID_2]
        
        bannerAdUnit.parameters = parameters
        
        prebidAdUnit = bannerAdUnit
    }

    func setupPrebidServer(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    // MARK: Setup PBS Rendering
    
    func setupOpenxRenderingBanner() {
        PrebidRenderingConfig.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! PrebidRenderingConfig.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
    }

    // MARK: Setup AdServer - GAM
    
    func setupGAMBannerAppNexus(width: Int, height: Int) {
        setupGAMBanner(width: width, height: height, adUnitId: "/19968336/PrebidMobileValidator_Banner_All_Sizes")
    }

    func setupGAMBannerRubicon(width: Int, height: Int) {
        setupGAMBanner(width: width, height: height, adUnitId: "/5300653/pavliuchyk_test_adunit_1x1_puc")
    }

    func setupGAMBanner(width: Int, height:Int, adUnitId: String) {
        let customAdSize = GADAdSizeFromCGSize(CGSize(width: width, height: height))
        
        gamBanner = GAMBannerView(adSize: customAdSize)
        gamBanner.adUnitID = adUnitId
    }
    
    // MARK: Setup AdServer - MoPub

    func setupMPBannerAppNexus(width: Int, height: Int) {
        setupMPBanner(adUnitId: "a935eac11acd416f92640411234fbba6", width: width, height: height)
    }
    
    func setupMPBannerRubicon(width: Int, height: Int) {
        setupMPBanner(adUnitId: "a108b8dd5ebc472098167e6f1c118120", width: width, height: height)
    }
    
    func setupMoPubRenderingBanner(width: Int, height: Int) {
        setupMPBanner(adUnitId: "0df35635801e4110b65e762a62437698", width: width, height: height)
    }
    
    func setupMPBanner(adUnitId: String, width: Int, height: Int) {
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitId)
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
        }

        mpBanner = MPAdView(adUnitId: adUnitId)
        mpBanner.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    // MARK: Load
    
    func loadGAMBanner() {
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        
        gamBanner.backgroundColor = .red
        gamBanner.rootViewController = self
        gamBanner.delegate = self
        
        appBannerView.addSubview(gamBanner)

        prebidAdUnit.fetchDemand(adObject: self.gamRequest) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for AdManager \(resultCode.name())")
            self?.gamBanner.load(self?.gamRequest)
        }
    }

    func loadMPBanner() {
        mpBanner.delegate = self
        appBannerView.addSubview(mpBanner)
        
        mpBanner.backgroundColor = .red

        // Do any additional setup after loading the view, typically from a nib.
        prebidAdUnit.fetchDemand(adObject: mpBanner) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for MoPub \(resultCode.name())")

            self?.mpBanner.loadAd()
        }
    }
    
    func loadInAppBanner() {
        let size = CGSize(width: width, height: height)
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                              configID: "50699c03-0910-477c-b4a4-911dbe2b9d42",
                              adSize: CGSize(width: 320, height: 50))
                                
        prebidBannerView.delegate = self
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    func loadGAMRenderingBanner() {
        let size = CGSize(width: width, height: height)
        
        let eventHandler = GAMBannerEventHandler(adUnitID: "/21808260008/prebid_oxb_320x50_banner", validGADAdSizes: [kGADAdSizeBanner].map(NSValueFromGADAdSize))
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                              configID: "50699c03-0910-477c-b4a4-911dbe2b9d42",
                              adSize: CGSize(width: 320, height: 50),
                              eventHandler: eventHandler)
                                
        prebidBannerView.delegate = self
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    func loadMoPubRenderingBanner() {
        mpBanner.delegate = self
        appBannerView.addSubview(mpBanner)
        
        mpBanner.backgroundColor = .red
        
        let size = CGSize(width: 320, height: 50)
        prebidMoPubAdUnit = MoPubBannerAdUnit(configID: "50699c03-0910-477c-b4a4-911dbe2b9d42", size: size)

        prebidMoPubAdUnit.fetchDemand(with: mpBanner) { [weak self] result in
            self?.mpBanner.loadAd()
        }
    }

    //MARK: Banner VAST
    
    func setupAndLoadGAMBannerVAST() {
        setupPBRubiconBannerVAST(width: width, height: height)
        setupAMRubiconBannerVAST(width: width, height: height)
        loadGAMBanner()
    }

    func setupPBRubiconBannerVAST(width: Int, height: Int) {

        setupPrebidServer(host: .Rubicon, accountId: "1001", storedResponse: "sample_video_response")

        let adUnit = VideoAdUnit(configId: "1001-1", size: CGSize(width: width, height: height))

        let parameters = VideoBaseAdUnit.Parameters()
        parameters.mimes = ["video/mp4"]

        parameters.protocols = [Signals.Protocols.VAST_2_0]
        // parameters.protocols = [Signals.Protocols(2)]

        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOff]
        // parameters.playbackMethod = [Signals.PlaybackMethod(2)]

        parameters.placement = Signals.Placement.InBanner
        // parameters.placement = Signals.Placement(2)

        adUnit.parameters = parameters

        self.prebidAdUnit = adUnit
    }

    func setupAMRubiconBannerVAST(width: Int, height: Int) {
        setupGAMBanner(width: width, height: height, adUnitId: "/5300653/test_adunit_vast_pavliuchyk")
    }
    
    func loadInAppVideoBanner() {
        let size = CGSize(width: 300, height: 250)
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                              configID: "9007b76d-c73c-49c6-b0a8-1c7890a84b33",
                              adSize: CGSize(width: 300, height: 250))
        
        prebidBannerView.adFormat = .video
        prebidBannerView.videoPlacementType = .inBanner
                                
        prebidBannerView.delegate = self
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    func loadGAMRenderingVideoBanner() {
        let size = CGSize(width: 300, height: 250)
        
        let eventHandler = GAMBannerEventHandler(adUnitID: "/21808260008/prebid_oxb_300x250_banner", validGADAdSizes: [kGADAdSizeBanner].map(NSValueFromGADAdSize))
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                              configID: "9007b76d-c73c-49c6-b0a8-1c7890a84b33",
                              adSize: CGSize(width: 300, height: 250),
                              eventHandler: eventHandler)
                                
        prebidBannerView.delegate = self
        prebidBannerView.adFormat = .video
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    // MARK: - Utils
    
    func enableCOPPA() {
        Targeting.shared.subjectToCOPPA = true
    }
    
    func addFirstPartyData(adUnit: AdUnit) {
        //Access Control List
        Targeting.shared.addBidderToAccessControlList(Prebid.bidderNameAppNexus)
        
        //global user data
        Targeting.shared.addUserData(key: "globalUserDataKey1", value: "globalUserDataValue1")
        
        //global context data
        Targeting.shared.addContextData(key: "globalContextDataKey1", value: "globalContextDataValue1")
        
        //adunit context data
        adUnit.addContextData(key: "adunitContextDataKey1", value: "adunitContextDataValue1")
        
        //global context keywords
        Targeting.shared.addContextKeyword("globalContextKeywordValue1")
        Targeting.shared.addContextKeyword("globalContextKeywordValue2")
        
        //global user keywords
        Targeting.shared.addUserKeyword("globalUserKeywordValue1")
        Targeting.shared.addUserKeyword("globalUserKeywordValue2")
        
        //adunit context keywords
        adUnit.addContextKeyword("adunitContextKeywordValue1")
        adUnit.addContextKeyword("adunitContextKeywordValue2")
    }
    
    func setStoredResponse() {
        Prebid.shared.storedAuctionResponse = "111122223333"
    }
    
    func setRequestTimeoutMillis() {
        Prebid.shared.timeoutMillis = 5000
    }

    func enablePbsDebug() {
        Prebid.shared.pbsDebug = true
    }
    
    // MARK: - BannerViewDelegate
    
    func bannerViewPresentationController() -> UIViewController? {
        return self
    }
    
    func bannerView(_ bannerView: BannerView, didReceiveAdWithAdSize adSize: CGSize) {
        
    }
    
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
        print(">>>>>  \(error.localizedDescription)")
    }

    //MARK: - GADBannerViewDelegate
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        
        AdViewUtils.findPrebidCreativeSize(bannerView,
                                            success: { (size) in
                                                guard let bannerView = bannerView as? GAMBannerView else {
                                                    return
                                                }

                                                bannerView.resize(GADAdSizeFromCGSize(size))

        },
                                            failure: { (error) in
                                                print("error: \(error)")

        })
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    //MARK: - MPAdViewDelegate
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }

    func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
        print("adViewDidLoadAd")
    }

    func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
        print("adView: didFailToLoadAdWithError: \(error.localizedDescription)" )
    }
}
