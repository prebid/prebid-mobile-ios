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

import MoPub

enum BannerFormat: Int {
    case html
    case vast
}

class BannerController: UIViewController, GADBannerViewDelegate, MPAdViewDelegate {

   @IBOutlet var appBannerView: UIView!

    @IBOutlet var adServerLabel: UILabel!

    var bannerFormat: BannerFormat = .html
    var adServerName: String = ""

    private var adUnit: AdUnit!
    
    private let amRequest = DFPRequest()
    private var amBanner: DFPBannerView!
    
    private var mpBanner: MPAdView!

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName

        if (adServerName == "DFP") {
            
            switch bannerFormat {
                
            case .html:
                setupAndLoadAMBanner()
            case .vast:
                setupAndLoadAMBannerVAST()
            }

        } else if (adServerName == "MoPub") {
            setupAndLoadMPBanner()
        }

//        enableCOPPA()
//        addFirstPartyData(adUnit: adUnit)
//        setStoredResponse()
//        setRequestTimeoutMillis()
//        enablePbsDebug()
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        adUnit?.stopAutoRefresh()
    }

    //MARK: Banner
    func setupAndLoadAMBanner() {
        let width = 300
        let height = 250
        
        setupPBRubiconBanner(width: width, height: height)
        setupAMRubiconBanner(width: width, height: height)
        loadAMBanner()
    }

    func setupAndLoadMPBanner() {
        let width = 300
        let height = 250
        
        setupPBRubiconBanner(width: width, height: height)
        setupMPRubiconBanner(width: width, height: height)
        loadMPBanner()

    }

    //setup PB
    func setupPBAppNexusBanner(width: Int, height: Int) {
        setupPBBanner(host: .Appnexus, accountId: "bfa84af2-bd16-4d35-96ad-31c6bb888df0", configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", storedResponse: "", width: width, height: height)
    }

    func setupPBRubiconBanner(width: Int, height: Int) {
        setupPBBanner(host: .Rubicon, accountId: "1001", configId: "1001-1", storedResponse: "1001-rubicon-300x250", width: width, height: height)
    }
    
    func setupPBBanner(host: PrebidHost, accountId: String, configId: String, storedResponse: String, width: Int, height: Int) {
        
        setupPB(host: host, accountId: accountId, storedResponse: storedResponse)
        let adUnit = BannerAdUnit(configId: configId, size: CGSize(width: width, height: height))
        
        let parameters = BannerAdUnit.Parameters()

        parameters.api = [Signals.Api.MRAID_2]
//        parameters.api = [Signals.Api(5)]

        adUnit.parameters = parameters
        
        self.adUnit = adUnit

        //adUnit.setAutoRefreshMillis(time: 35000)
    }

    func setupPB(host: PrebidHost, accountId: String, storedResponse: String) {
        Prebid.shared.prebidServerHost = host
        Prebid.shared.prebidServerAccountId = accountId
        Prebid.shared.storedAuctionResponse = storedResponse

        //set QA env
        Prebid.shared.prebidServerHost = .Custom
        do {
            try Prebid.shared.setCustomPrebidServer(url: "https://prebid-server.qa.rubiconproject.com/openrtb2/auction")
        } catch {
            print(error)
        }
        
        Prebid.shared.storedAuctionResponse = "1001-rubicon-300x250-skadnetwork"
    }

    //Setup AdServer
    func setupAMAppNexusBanner(width: Int, height: Int) {
        setupAMBanner(width: width, height: height, adUnitId: "/19968336/PrebidMobileValidator_Banner_All_Sizes")
    }

    func setupAMRubiconBanner(width: Int, height: Int) {
        setupAMBanner(width: width, height: height, adUnitId: "/5300653/pavliuchyk_test_adunit_1x1_puc")
    }

    func setupAMBanner(width: Int, height:Int, adUnitId: String) {
        let customAdSize = GADAdSizeFromCGSize(CGSize(width: width, height: height))
        
        amBanner = DFPBannerView(adSize: customAdSize)
        amBanner.adUnitID = adUnitId
    }

    func setupMPAppNexusBanner(width: Int, height: Int) {
        setupMPBanner(adUnitId: "a935eac11acd416f92640411234fbba6", width: width, height: height)
    }
    
    func setupMPRubiconBanner(width: Int, height: Int) {
        setupMPBanner(adUnitId: "a108b8dd5ebc472098167e6f1c118120", width: width, height: height)
    }
    
    func setupMPBanner(adUnitId: String, width: Int, height: Int) {
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: adUnitId)
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {

        }

        mpBanner = MPAdView(adUnitId: adUnitId)
        mpBanner.frame = CGRect(x: 0, y: 0, width: width, height: height)
        mpBanner.delegate = self
        appBannerView.addSubview(mpBanner)
    }
    
    //Load
    func loadAMBanner() {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        
        amBanner.backgroundColor = .red
        amBanner.rootViewController = self
        amBanner.delegate = self
        appBannerView.addSubview(amBanner)

        adUnit.fetchDemand(adObject: self.amRequest) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for AdManager \(resultCode.name())")
            self?.amBanner.load(self?.amRequest)
        }
    }

    func loadMPBanner() {
        mpBanner.backgroundColor = .red

        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: mpBanner) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for MoPub \(resultCode.name())")

            self?.mpBanner.loadAd()
        }
    }

    //MARK: Banner VAST
    func setupAndLoadAMBannerVAST() {
        let width = 300
        let height = 250

        setupPBRubiconBannerVAST(width: width, height: height)
        setupAMRubiconBannerVAST(width: width, height: height)
        loadAMBanner()
    }

    func setupPBRubiconBannerVAST(width: Int, height: Int) {

        setupPB(host: .Rubicon, accountId: "1001", storedResponse: "sample_video_response")

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

        self.adUnit = adUnit
    }

    func setupAMRubiconBannerVAST(width: Int, height: Int) {
        setupAMBanner(width: width, height: height, adUnitId: "/5300653/test_adunit_vast_pavliuchyk")
    }
    
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

    //MARK: - GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        
        AdViewUtils.findPrebidCreativeSize(bannerView,
                                            success: { (size) in
                                                guard let bannerView = bannerView as? DFPBannerView else {
                                                    return
                                                }

                                                bannerView.resize(GADAdSizeFromCGSize(size))

        },
                                            failure: { (error) in
                                                print("error: \(error)")

        })
        
        if #available(iOS 14.0, *) {
            AdViewUtils.subscribeOnAdClicked(viewController: self, adView: bannerView)
        } else {
            // Fallback on earlier versions
            print("this feature is support from iOS v14")
        }
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adView:didFailToReceiveAdWithError:")

//        AdViewUtils.onAdClicked(viewController: self, adView: bannerView)
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
