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

    var dfpInterstitial: DFPInterstitial!

    var mopubInterstitial: MPInterstitialAdController!

    override func viewDidLoad() {
        super.viewDidLoad()

        adServerLabel.text = adServerName

        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        let interstitialUnit = InterstitialAdUnit(configId: "625c6125-f19e-4d5b-95c5-55501526b2a4")

        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            loadDFPInterstitial(adUnit: interstitialUnit)

        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            loadMoPubInterstitial(adUnit: interstitialUnit)

        }
    }

    func loadDFPInterstitial(adUnit: AdUnit) {
        print("Google Mobile Ads SDK version: \(DFPRequest.sdkVersion())")

        dfpInterstitial = DFPInterstitial(adUnitID: "/19968336/PrebidMobileValidator_Interstitial")
        dfpInterstitial.delegate = self
        request.testDevices = [ kGADSimulatorID]
        adUnit.fetchDemand(adObject: self.request) { (ResultCode) in
            print("Prebid demand fetch for DFP \(ResultCode)")
            self.dfpInterstitial!.load(self.request)
        }
    }

    func loadMoPubInterstitial(adUnit: AdUnit) {

        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "2829868d308643edbec0795977f17437")
        sdkConfig.globalMediationSettings = []

        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {

        }

        self.mopubInterstitial = MPInterstitialAdController(forAdUnitId: "2829868d308643edbec0795977f17437")
        self.mopubInterstitial.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
        adUnit.fetchDemand(adObject: mopubInterstitial!) { (ResultCode) in
            print("Prebid demand fetch for mopub \(ResultCode)")

            self.mopubInterstitial.loadAd()
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

        if (self.dfpInterstitial?.isReady ?? true) {
            print("Ad ready")
            self.dfpInterstitial?.present(fromRootViewController: self)
        } else {
            print("Ad not ready")
        }
    }

    func interstitialDidLoadAd(_ interstitial: MPInterstitialAdController!) {
        print("Ad ready")
        if (self.mopubInterstitial.ready ) {
            self.mopubInterstitial.show(from: self)
        }
    }

    func interstitialDidFail(toLoadAd interstitial: MPInterstitialAdController!) {
        print("Ad not ready")
    }

}
