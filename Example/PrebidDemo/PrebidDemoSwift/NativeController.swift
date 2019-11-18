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

class NativeController: UIViewController, GADBannerViewDelegate, MPAdViewDelegate {
    
    var nativeUnit: NativeRequest!
    
    var adServerName: String = ""
    
    @IBOutlet var nativeView: UIView!
    
    var eventTrackers: NativeEventTracker!
    var dfpNativeAdUnit: DFPBannerView!
    var mopubNativeAdUnit: MPAdView!
    let request = DFPRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNativeAssets()
        
        if (adServerName == "DFP") {
            print("entered \(adServerName) loop" )
            loadDFPNative()

        } else if (adServerName == "MoPub") {
            print("entered \(adServerName) loop" )
            loadMoPubNative()

        }
        
        // Do any additional setup after loading the view.
    }
    
    func loadNativeAssets(){
        
        let image:NativeAssetImage = NativeAssetImage(minimumWidth: 200, minimumHeight: 200)
        image.type = ImageAsset.Main
        
        let asset1 = NativeAsset(isRequired: true, nativeObject: image)
        
        let title = NativeAssetTitle(length: 90)
        let asset2 = NativeAsset(isRequired: true, nativeObject: title)
        
        let object:AnyObject = NativeRequest(configId: "abc")
        
        let asset3 = NativeAsset(isRequired: true, nativeObject: object)
        
        
        nativeUnit = NativeRequest(configId: "1f85e687-b45f-4649-a4d5-65f74f2ede8e", assets: [asset1!,asset2!])
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        eventTrackers = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    func loadDFPNative(){
        
        dfpNativeAdUnit = DFPBannerView(adSize: kGADAdSizeFluid)
        dfpNativeAdUnit.adUnitID = "/19968336/Wei_Prebid_Native_Test"
        dfpNativeAdUnit.rootViewController = self
        dfpNativeAdUnit.delegate = self
        dfpNativeAdUnit.backgroundColor = .green
        nativeView.addSubview(dfpNativeAdUnit)
        if(nativeUnit != nil){
            nativeUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
                print("Prebid demand fetch for DFP \(resultCode.name())")
                self?.dfpNativeAdUnit!.load(self?.request)
            }
        }
    }
    
    func loadMoPubNative() {
        
        mopubNativeAdUnit = MPAdView(adUnitId: "a470959f33034229945744c5f904d5bc")
        mopubNativeAdUnit.frame = CGRect(x: 0, y: 0, width: 300, height: 250)
        mopubNativeAdUnit.delegate = self
        mopubNativeAdUnit.backgroundColor = .green
        nativeView.addSubview(mopubNativeAdUnit)

        if(nativeUnit != nil){
            // Do any additional setup after loading the view, typically from a nib.
            nativeUnit.fetchDemand(adObject: mopubNativeAdUnit) { (resultCode: ResultCode) in
                print("Prebid demand fetch for mopub \(resultCode.name())")

                self.mopubNativeAdUnit!.loadAd()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        self.dfpNativeAdUnit.resize(bannerView.adSize)

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
