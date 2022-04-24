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
fileprivate let storedImpDisplayBanner              = "imp-prebid-banner-320-50"
fileprivate let storedImpVideoBanner                = "imp-prebid-video-outstream"

// Stored Responses
fileprivate let storedResponseDisplayBanner         = "response-prebid-banner-320-50"

fileprivate let storedResponseVideoBanner           = "response-prebid-video-outstream"

// GAM
fileprivate let gamAdUnitDisplayBannerOriginal      = "/21808260008/prebid_demo_app_original_api_banner"
fileprivate let gamAdUnitVideoBannerOriginal        = "/21808260008/prebid-demo-original-api-video-banner"

fileprivate let gamAdUnitDisplayBannerRendering     = "/21808260008/prebid_oxb_320x50_banner"
fileprivate let gamAdUnitVideoBannerRendering       = "/21808260008/prebid_oxb_300x250_banner"

// AdMob
fileprivate let adMobAdUnitDisplayBannerOriginal    = "ca-app-pub-5922967660082475/9483570409"

// MAX
fileprivate let maxAdUnitDisplayBannerOriginal      = "be91247472f4cd02"

enum AdFormat: Int {
    case html
    case vast
}

class BannerController:
    UIViewController,
    GADBannerViewDelegate,       // GMA SDK
    BannerViewDelegate,          // Prebid Rendering
    MAAdViewAdDelegate
{
    // MARK: - UI Properties
    
    @IBOutlet var appBannerView: UIView!
    
    @IBOutlet var adServerLabel: UILabel!
    
    @IBOutlet var toggleRefreshButton: UIButton!
    
    // MARK: - Public Properties
    
    var bannerFormat    : AdFormat = .html
    var integrationKind : IntegrationKind = .undefined
    
    // MARK: - Private Properties
    
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
    private var mediationDelegate: AdMobMediationBannerUtils!
    
    // MAX
    private var maxAdBannerView: MAAdView!
    private var maxAdUnit: MediationBannerAdUnit!
    private var maxMediationDelegate: MAXMediationBannerUtils!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adServerLabel.text = integrationKind.rawValue
        
        switch integrationKind {
        case .originalGAM       : setupAndLoadGAM()
        case .inApp             : setupAndLoadInAppBanner()
        case .renderingGAM      : setupAndLoadGAMRendering()
        case .renderingAdMob    : setupAndLoadAdMobRendering()
        // To run this example you should create your own MAX ad unit.
        case .renderingMAX      : setupAndLoadMAXRendering()
            
        case .undefined         : assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
        
        toggleRefreshButton.addTarget(self, action: #selector(toggleRefresh), for: .touchUpInside)
        
        //        enableCOPPA()
        //        addFirstPartyData(adUnit: prebidAdUnit)
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
        setupBannerAdUnit()
        
        setupGAMBanner(width: 320, height: 50,
                       adUnitId: gamAdUnitDisplayBannerOriginal)
        
        loadGAMBanner()
    }
    
    func setupAndLoadInAppBanner() {
        switch bannerFormat {
        case .html:
            loadInAppBanner()
        case .vast:
            loadInAppVideoBanner()
        }
    }
    
    func setupAndLoadGAMRendering() {
        switch bannerFormat {
        case .html:
            loadGAMRenderingBanner()
        case .vast:
            loadGAMRenderingVideoBanner()
        }
    }
    
    func setupAndLoadAdMobRendering() {
        
        setupPrebidServer(storedResponse: storedResponseDisplayBanner)
        
        setupAdMobBanner(adUnitId: adMobAdUnitDisplayBannerOriginal,
                         width: 320, height: 50)
        
        loadAdMobRenderingBanner()
    }
    
    func setupAndLoadMAXRendering() {
        setupPrebidServer(storedResponse: storedResponseDisplayBanner)
        setupMAXBanner(adUnitId: maxAdUnitDisplayBannerOriginal, width: 320, height: 50)
        loadMAXRenderingBanner()
    }
    
    // MARK: Setup PBS
    
    func setupBannerAdUnit() {
        
        setupPrebidServer(storedResponse: storedResponseDisplayBanner)
        
        let bannerAdUnit = BannerAdUnit(configId: storedImpDisplayBanner,
                                        size: CGSize(width: 320, height: 50))
        
        let parameters = BannerParameters()
        
        parameters.api = [Signals.Api.MRAID_2]
        
        bannerAdUnit.parameters = parameters
        
        prebidAdUnit = bannerAdUnit
        
        bannerAdUnit.setAutoRefreshMillis(time: 30000)
        toggleRefreshButton.isHidden = false
    }
    
    func setupPrebidServer(storedResponse: String) {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        
        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    // MARK: Setup AdServer - GAM
    
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
        maxAdBannerView = MAAdView(adUnitIdentifier: adUnitId)
        maxAdBannerView.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        maxAdBannerView.backgroundColor = .red
        maxAdBannerView.delegate = self
        maxAdBannerView.isHidden = false
        appBannerView.addSubview(maxAdBannerView)
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
        setupPrebidServer(storedResponse: storedResponseDisplayBanner)
        
        let size = CGSize(width: 320, height: 50)
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                                      configID: storedImpDisplayBanner,
                                      adSize: CGSize(width: 320, height: 50))
        
        prebidBannerView.delegate = self
        
        appBannerView.constraints.first { $0.firstAttribute == .width }?.constant = prebidBannerView.adUnitConfig.adSize.width
        appBannerView.constraints.first { $0.firstAttribute == .height }?.constant = prebidBannerView.adUnitConfig.adSize.height
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    func loadGAMRenderingBanner() {
        setupPrebidServer(storedResponse: storedResponseDisplayBanner)
        
        let size = CGSize(width: 320, height: 50)
        
        let eventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitDisplayBannerRendering,
                                                 validGADAdSizes: [kGADAdSizeBanner].map(NSValueFromGADAdSize))
        
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                                      configID: storedImpDisplayBanner,
                                      adSize: CGSize(width: 320, height: 50),
                                      eventHandler: eventHandler)
        
        prebidBannerView.delegate = self
        
        appBannerView.constraints.first { $0.firstAttribute == .width }?.constant = prebidBannerView.adUnitConfig.adSize.width
        appBannerView.constraints.first { $0.firstAttribute == .height }?.constant = prebidBannerView.adUnitConfig.adSize.height
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    func loadAdMobRenderingBanner() {
        gadBanner.delegate = self
        
        appBannerView.constraints.first { $0.firstAttribute == .width }?.constant = gadBanner.adSize.size.width
        appBannerView.constraints.first { $0.firstAttribute == .height }?.constant = gadBanner.adSize.size.height
        
        appBannerView.addSubview(gadBanner)
        gadBanner.backgroundColor = .red
        gadBanner.rootViewController = self
        
        
        let size = CGSize(width: 320, height: 50)
        
        mediationDelegate = AdMobMediationBannerUtils(gadRequest: gadRequest, bannerView: gadBanner)
        prebidAdMobMediaitonAdUnit = MediationBannerAdUnit(configID: storedImpDisplayBanner, size: size, mediationDelegate: mediationDelegate)
        
        prebidAdMobMediaitonAdUnit.fetchDemand { [weak self] result in
            let extras = GADCustomEventExtras()
            let prebidExtras = self?.mediationDelegate.getEventExtras()
            extras.setExtras(prebidExtras, forLabel: AdMobConstants.PrebidAdMobEventExtrasLabel)
            self?.gadRequest.register(extras)
            self?.gadBanner.load(self?.gadRequest)
        }
    }
    
    func loadMAXRenderingBanner() {
        let size = CGSize(width: 320, height: 50)
        
        maxMediationDelegate = MAXMediationBannerUtils(adView: maxAdBannerView)
        maxAdUnit = MediationBannerAdUnit(configID: storedImpDisplayBanner,
                                          size: size,
                                          mediationDelegate: maxMediationDelegate)
        
        maxAdUnit.fetchDemand { [weak self] result in
            self?.maxAdBannerView.loadAd()
        }
    }
    
    //MARK: Banner VAST
    func setupAndLoadGAMBannerVAST() {
        setupGAMBannerVAST(width: 300, height: 250)
        
        setupGAMBanner(width: 300, height: 250,
                       adUnitId: gamAdUnitVideoBannerOriginal)
        
        loadGAMBanner()
    }
    
    func setupGAMBannerVAST(width: Int, height: Int) {
        // TODO: actualize stored response for this case
        setupPrebidServer(storedResponse: storedResponseVideoBanner)
        
        let adUnit = VideoAdUnit(configId: storedImpVideoBanner, size: CGSize(width: width, height: height))
        
        let parameters = VideoParameters()
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
    
    func loadInAppVideoBanner() {
        setupPrebidServer(storedResponse: storedResponseVideoBanner)
        
        let size = CGSize(width: 300, height: 250)
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                                      configID: storedImpVideoBanner,
                                      adSize: CGSize(width: 300, height: 250))
        
        prebidBannerView.adFormat = .video
        prebidBannerView.videoParameters.placement = .InBanner
        
        prebidBannerView.delegate = self
        
        appBannerView.constraints.first { $0.firstAttribute == .width }?.constant = prebidBannerView.adUnitConfig.adSize.width
        appBannerView.constraints.first { $0.firstAttribute == .height }?.constant = prebidBannerView.adUnitConfig.adSize.height
        
        appBannerView.addSubview(prebidBannerView)
        
        prebidBannerView.loadAd()
    }
    
    func loadGAMRenderingVideoBanner() {
        let size = CGSize(width: 300, height: 250)
        
        setupPrebidServer(storedResponse: storedResponseVideoBanner)
        
        let eventHandler = GAMBannerEventHandler(adUnitID: gamAdUnitVideoBannerRendering, validGADAdSizes: [kGADAdSizeBanner].map(NSValueFromGADAdSize))
        prebidBannerView = BannerView(frame: CGRect(origin: .zero, size: size),
                                      configID: storedImpVideoBanner,
                                      adSize: CGSize(width: 300, height: 250),
                                      eventHandler: eventHandler)
        
        prebidBannerView.delegate = self
        prebidBannerView.adFormat = .video
        
        appBannerView.constraints.first { $0.firstAttribute == .width }?.constant = prebidBannerView.adUnitConfig.adSize.width
        appBannerView.constraints.first { $0.firstAttribute == .height }?.constant = prebidBannerView.adUnitConfig.adSize.height
        
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
    
    // MARK: - MAAdViewAdDelegate
    
    func didLoad(_ ad: MAAd) {
        
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        Log.error(error.message)
        
        let nsError = NSError(domain: "MAX", code: error.code.rawValue, userInfo: [NSLocalizedDescriptionKey: error.message])
        maxAdUnit?.adObjectDidFailToLoadAd(adObject: maxAdBannerView!, with: nsError)
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        Log.error(error.message)
        
        let nsError = NSError(domain: "MAX", code: error.code.rawValue, userInfo: [NSLocalizedDescriptionKey: error.message])
        maxAdUnit?.adObjectDidFailToLoadAd(adObject: maxAdBannerView!, with: nsError)
    }
    
    func didDisplay(_ ad: MAAd) {
        print("didDisplay(_ ad: MAAd)")
    }
    
    func didHide(_ ad: MAAd) {
        print("didHide(_ ad: MAAd)")
    }
    
    func didExpand(_ ad: MAAd) {
        print("didExpand(_ ad: MAAd)")
    }
    
    func didCollapse(_ ad: MAAd) {
        print("didCollapse(_ ad: MAAd)")
    }
    
    func didClick(_ ad: MAAd) {
        print("didClick(_ ad: MAAd)")
    }
}
