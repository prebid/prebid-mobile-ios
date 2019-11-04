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

    let request = DFPRequest()

    var adUnit: AdUnit!

    var mpBanner: MPAdView?
    
    var amBanner: DFPBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName
        
//        enableCOPPA()
//        addFirstPartyData(adUnit: bannerUnit)
//        setStoredResponse()
//        setRequestTimeoutMillis()

        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            
            switch bannerFormat {
                
            case .html:
                setupAndLoadAMBanner()
            case .vast:
                setupAndLoadAMBannerVAST()
            }
            

        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            loadMoPubBanner()

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        adUnit?.stopAutoRefresh()
    }

    func setupAndLoadAMBanner() {
        setupPBBanner()
        
        setupAMBanner()
        
        loadBanner()
    }
    
    func setupAndLoadAMBannerVAST() {
        
        setupPBBannerVAST()
        
        setupAMBannerVAST()

        loadBanner()
    }
    
    func setupPBBanner() {
        Prebid.shared.prebidServerHost = .Appnexus
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        Prebid.shared.storedAuctionResponse = ""
        
        adUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        adUnit.setAutoRefreshMillis(time: 35000)
    }
    
    func setupPBBannerVAST() {
        
        Prebid.shared.prebidServerHost = .Rubicon
        Prebid.shared.prebidServerAccountId = "1001"
        Prebid.shared.storedAuctionResponse = "sample_video_response"
        
        adUnit = VideoAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
    }
    
    func setupAMBanner() {
        setupAMBanner(id: "/19968336/PrebidMobileValidator_Banner_All_Sizes")
    }
    
    func setupAMBannerVAST() {
        setupAMBanner(id: "/5300653/test_adunit_vast_pavliuchyk")
    }
    
    func setupAMBanner(id: String) {
        amBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        amBanner.adUnitID = id
    }
    
    func loadBanner() {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        
        amBanner.rootViewController = self
        amBanner.delegate = self
        amBanner.backgroundColor = .red
        appBannerView.addSubview(amBanner)

        adUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self?.amBanner!.load(self?.request)
        }
    }

    func loadMoPubBanner() {
        setupPBBanner()
        
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {

        }

        mpBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        mpBanner!.delegate = self

        appBannerView.addSubview(mpBanner!)

        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: mpBanner!) { (resultCode: ResultCode) in
            print("Prebid demand fetch for mopub \(resultCode.name())")

            self.mpBanner!.loadAd()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                                                print("error: \(error)");

        })
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func adViewDidReceiveAd(_ bannerView: DFPBannerView) {
        print("adViewDidReceiveAd")
        
        self.amBanner.resize(bannerView.adSize)

    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: DFPBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }

}
