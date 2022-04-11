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

enum AdFormat: Int {
    case html
    case vast
}

class BannerController:
        UIViewController,
        GADBannerViewDelegate,      // GMA SDK
        BannerViewDelegate,         // Prebid Rendering
        MAAdViewAdDelegate          // Applovin MAX
{
    
    // MARK: - UI Properties
    
    @IBOutlet var appBannerView: UIView!

    @IBOutlet var adServerLabel: UILabel!
    
    @IBOutlet var toggleRefreshButton: UIButton!
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
    
    private var isRefreshEnabled = true

    // Prebid Rendering
    private var prebidBannerView: BannerView!               // (In-App and GAM)
    
    // AdMob
    private var gadBanner: GADBannerView!
    private let gadRequest = GADRequest()
    private var prebidAdMobMediaitonAdUnit: MediationBannerAdUnit!
    private var admobMediationDelegate: AdMobMediationBannerUtils!
    
    // MAX
    private var maxBannerView: MAAdView!
    private var prebidMAXAdUnit: MediationBannerAdUnit!
    private var maxMediationDelegate: MAXMediationBannerUtils!
        
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
            case .originalGAM       : setupAndLoadGAM()
            case .originalAdMob     : print("There is no way to integrate AdMob with original SDK")
            case .inApp             : setupAndLoadInAppBanner()
            case .renderingGAM      : setupAndLoadGAMRendering()
            case .renderingAdMob    : setupAndLoadAdMobRendering()
            case .renderingMAX      : setupAndLoadMAXRendering()
            
            case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
        
        toggleRefreshButton.addTarget(self, action: #selector(toggleRefresh), for: .touchUpInside)

//        enableCOPPA()
//        addFirstPartyData(adUnit: prebidAdUnit)
//        setStoredResponse()
//        setRequestTimeoutMillis()
//        enablePbsDebug()
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        prebidAdUnit?.stopAutoRefresh()
    }
    
    @objc private func toggleRefresh() {
        isRefreshEnabled = !isRefreshEnabled
        toggleRefreshButton.setTitle((isRefreshEnabled ? "Stop Refresh" : "Resume Refresh"), for: .normal)
        if (isRefreshEnabled) {
            prebidAdUnit?.resumeAutoRefresh()
        } else {
            prebidAdUnit?.stopAutoRefresh()
        }
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
    
    func setupAndLoadAdMobRendering() {
        setupOpenxRenderingBanner()
        
        setupAdMobBanner(adUnitId: "ca-app-pub-5922967660082475/9483570409", width: 320, height: 50)
        loadAdMobRenderingBanner()
    }
    
    func setupAndLoadMAXRendering() {
        setupOpenxRenderingBanner()
        
        setupMAXBanner(adUnitId: "5f111f4bcd0f58ca", width: 320, height: 50)
        loadMAXRenderingBanner()
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
        
        bannerAdUnit.setAutoRefreshMillis(time: 30000)
        toggleRefreshButton.isHidden = false
    }

    func setupPrebidServer(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    // MARK: Setup PBS Rendering
    
    func setupOpenxRenderingBanner() {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid.openx.net/openrtb2/auction")
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
    
    // MARK: Setup AdServer - AdMob
    
    func setupAdMobBanner(adUnitId: String, width: Int, height: Int) {
        gadBanner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: width, height: height)))
        gadBanner.adUnitID = adUnitId
    }
    
    // MARK: Setup AdServer - MAX
    
    func setupMAXBanner(adUnitId: String, width: Int, height: Int) {
        maxBannerView = MAAdView(adUnitIdentifier: adUnitId)
        maxBannerView.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
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
    
    func loadAdMobRenderingBanner() {
        gadBanner.delegate = self
        appBannerView.addSubview(gadBanner)
        gadBanner.backgroundColor = .red
        gadBanner.rootViewController = self
        
        
        let size = CGSize(width: 320, height: 50)
        
        admobMediationDelegate = AdMobMediationBannerUtils(gadRequest: gadRequest, bannerView: gadBanner)
        prebidAdMobMediaitonAdUnit = MediationBannerAdUnit(configID: "50699c03-0910-477c-b4a4-911dbe2b9d42", size: size, mediationDelegate: admobMediationDelegate)
        
        prebidAdMobMediaitonAdUnit.fetchDemand { [weak self] result in
            let extras = GADCustomEventExtras()
            let prebidExtras = self?.admobMediationDelegate.getEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self?.gadRequest.register(extras)
            self?.gadBanner.load(self?.gadRequest)
        }
        
    }
    
    func loadMAXRenderingBanner() {
        maxBannerView.delegate = self
        appBannerView.addSubview(maxBannerView)
        maxBannerView.backgroundColor = .red
        
        let size = CGSize(width: 320, height: 50)
        
        maxMediationDelegate = MAXMediationBannerUtils(adView: maxBannerView)
        prebidMAXAdUnit = MediationBannerAdUnit(configID: "50699c03-0910-477c-b4a4-911dbe2b9d42", size: size, mediationDelegate: maxMediationDelegate)
        
        prebidMAXAdUnit.fetchDemand { [weak self] result in
            print(result.name())
            
            if result != .prebidDemandFetchSuccess {
                return
            }
            
            self?.maxBannerView.loadAd()
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
        Targeting.shared.addContextData(key: "globalContextDataKey1", value: "globalContextDataValue1")
        Targeting.shared.addUserData(key: "globalUserDataKey1", value: "globalUserDataValue1")
        
        //global context data
        let userData = PBMORTBContentData()
        userData.id = "globalUserDataValue1"
        adUnit.addUserData([userData])
        
        //adunit context data
        let appData = PBMORTBContentData()
        appData.id = "adunitContextDataValue1"
        adUnit.addAppContentData([appData])
        
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

    // MARK: - GADBannerViewDelegate
    
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

    // MARK: - MAAdViewAdDelegate
        
    func didLoad(_ ad: MAAd) {
        print("didLoad(_ ad: MAAd)")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)")
        print(error.message)
    }
    
    func didDisplay(_ ad: MAAd) {
        print("didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)")
    }
    
    func didHide(_ ad: MAAd) {
        print("didHide(_ ad: MAAd)")
    }
    
    func didClick(_ ad: MAAd) {
        print("didClick(_ ad: MAAd)")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("didFail(toDisplay ad: MAAd, withError error: MAError)")
        print(error.message)
    }
    
    func didExpand(_ ad: MAAd) {
        print("didExpand(_ ad: MAAd)")
    }
    
    func didCollapse(_ ad: MAAd) {
        print("didCollapse(_ ad: MAAd)")
    }
}
