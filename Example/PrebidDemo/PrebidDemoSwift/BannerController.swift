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

class BannerController: UIViewController, GADBannerViewDelegate, MPAdViewDelegate {

   @IBOutlet var appBannerView: UIView!

    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""

    let request = DFPRequest()

    var dfpBanner: DFPBannerView!

    var bannerUnit: BannerAdUnit!

    var mopubBanner: MPAdView?

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName

        bannerUnit = BannerAdUnit(configId: "6ace8c7d-88c0-4623-8117-75bc3f0a2e45", size: CGSize(width: 300, height: 250))
        bannerUnit.setAutoRefreshMillis(time: 35000)
        //bannerUnit.addAdditionalSize(sizes: [CGSize(width: 300, height: 600)])
        
//        enableCOPPA()
//        addFirstPartyData(adUnit: bannerUnit)
//        setStoredResponse()
//        setRequestTimeoutMillis()

        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            loadDFPBanner(bannerUnit: bannerUnit)

        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            loadMoPubBanner(bannerUnit: bannerUnit)

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // important to remove the time instance
        bannerUnit?.stopAutoRefresh()
    }

    func loadDFPBanner(bannerUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        dfpBanner = DFPBannerView(adSize: kGADAdSizeMediumRectangle)
        dfpBanner.adUnitID = "/19968336/PrebidMobileValidator_Banner_All_Sizes"
        dfpBanner.rootViewController = self
        dfpBanner.delegate = self
        dfpBanner.backgroundColor = .red
        appBannerView.addSubview(dfpBanner)
        
        bannerUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self?.dfpBanner!.load(self?.request)
        }
    }

    func loadMoPubBanner(bannerUnit: AdUnit) {

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a935eac11acd416f92640411234fbba6")
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {

        }

        mopubBanner = MPAdView(adUnitId: "a935eac11acd416f92640411234fbba6", size: CGSize(width: 300, height: 250))
        mopubBanner!.delegate = self

        appBannerView.addSubview(mopubBanner!)

        // Do any additional setup after loading the view, typically from a nib.
        bannerUnit.fetchDemand(adObject: mopubBanner!) { (resultCode: ResultCode) in
            print("Prebid demand fetch for mopub \(resultCode.name())")

            self.mopubBanner!.loadAd()
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
        
        self.dfpBanner.resize(bannerView.adSize)

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
