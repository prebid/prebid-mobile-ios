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

class InterstitialViewController: UIViewController, GADInterstitialDelegate, MPInterstitialAdControllerDelegate {

    @IBOutlet var adServerLabel: UILabel!

    var adServerName: String = ""

    let request = GADRequest()

    var amInterstitial: DFPInterstitial!

    var mpInterstitial: MPInterstitialAdController!
    
    var adUnit: AdUnit!
    
    var bannerFormat: BannerFormat = .html

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

    //MARK: - AdManager
    func setupAndLoadAMInterstitial() {
        
        setupPBInterstitial()
        setupAMInterstitial()
        
        loadInterstitial()
    }
    
    func setupAndLoadAMInterstitialVAST() {

        setupPBInterstitialVAST()
        setupAMInterstitialVAST()
        
        loadInterstitial()
    }
    
    func setupPBInterstitial() {
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        Prebid.shared.storedAuctionResponse = ""
        
        adUnit = InterstitialAdUnit(configId: "625c6125-f19e-4d5b-95c5-55501526b2a4")
        
//        Advanced interstitial support
//        adUnit = InterstitialAdUnit(configId: "625c6125-f19e-4d5b-95c5-55501526b2a4", minWidthPerc: 50, minHeightPerc: 70)

    }
    
    func setupPBInterstitialVAST() {
        Prebid.shared.prebidServerHost = .Rubicon
        
        Prebid.shared.prebidServerAccountId = "1001"
        adUnit = VideoAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), type: .inBanner)
        
        Prebid.shared.storedAuctionResponse = "sample_video_response"
    }
    
    func setupAMInterstitial() {
        amInterstitial = DFPInterstitial(adUnitID: "/19968336/PrebidMobileValidator_Interstitial")
        amInterstitial.delegate = self
    }
    
    func setupAMInterstitialVAST() {
        amInterstitial = DFPInterstitial(adUnitID: "/5300653/test_adunit_vast_pavliuchyk")
        amInterstitial.delegate = self
    }
    
    func loadInterstitial() {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")
        
        adUnit.fetchDemand(adObject: self.request) { (resultCode: ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self.amInterstitial!.load(self.request)
        }
    }

    //MARK: - MoPub
    func setupAndLoadMPInterstitial() {
        setupPBInterstitial()
        setupMPInterstitial()
        
        loadMPInterstitial()

    }
    
    func setupAndLoadMPInterstitialVAST() {
        setupPBInterstitialVAST()
        setupMPInterstitialVAST()
        
        loadMPInterstitial()

    }
    
    func setupMPInterstitial() {
        
        setupMPInterstitial(id: "2829868d308643edbec0795977f17437")
    }
    
    func setupMPInterstitialVAST() {
        
        setupMPInterstitial(id: "fdafd17a5aeb41c798e6901a7f76f256")
    }
    
    func setupMPInterstitial(id: String) {
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: id)
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {}

        self.mpInterstitial = MPInterstitialAdController(forAdUnitId: id)
        self.mpInterstitial.delegate = self
    }
    
    func loadMPInterstitial() {
        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: mpInterstitial!) { (resultCode: ResultCode) in
            print("Prebid demand fetch for mopub \(resultCode.name())")

            self.mpInterstitial.loadAd()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("Ad presented")
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // Send another GADRequest here
        print("Ad dismissed")
    }

    func interstitialDidReceiveAd(_ ad: GADInterstitial) {

        if (self.amInterstitial?.isReady ?? true) {
            print("Ad ready")
            self.amInterstitial?.present(fromRootViewController: self)
        } else {
            print("Ad not ready")
        }
    }

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
