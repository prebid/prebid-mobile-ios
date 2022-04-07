//
//  NativeViewController.swift
//  PrebidDemoSwift
//
//  Created by Punnaghai Puviarasu on 12/2/19.
//  Copyright © 2019 Prebid. All rights reserved.
//

import UIKit

import PrebidMobile

import GoogleMobileAds
import GoogleUtilities
import MoPubSDK

class NativeViewController: UIViewController, GADBannerViewDelegate, MPAdViewDelegate , GADAdSizeDelegate {

    var nativeUnit: NativeRequest!
    
    var adServerName: String = ""
    
    @IBOutlet var nativeView: UIView!
    
    var eventTrackers: NativeEventTracker!
    var dfpNativeAdUnit: GAMBannerView!
    var mopubNativeAdUnit: MPAdView!
    let request = GAMRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Prebid.shared.shouldAssignNativeAssetID = true

        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
       ["f2a7d257f84db8b1c4d7dd441323ad98"]

//        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
//        Prebid.shared.prebidServerAccountId = "9325"
        
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
            
            let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200, required: true)
            image.type = ImageAsset.Main
            
            let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
            icon.type = ImageAsset.Icon
            
            let title = NativeAssetTitle(length: 90, required: true)
            
            let body = NativeAssetData(type: DataAsset.description, required: true)
            
            let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
            
            let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
            
            nativeUnit = NativeRequest(configId: "24659163", assets: [icon,title,image,body,cta,sponsored])

            nativeUnit.context = ContextType.Social
            nativeUnit.placementType = PlacementType.FeedContent
            nativeUnit.contextSubType = ContextSubType.Social
            
            let event1 = EventType.Impression
            eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
            nativeUnit.eventtrackers = [eventTrackers]
        }
            
    // MARK: - GADAdSizeDelegate

    @objc func adView(_ bannerView: GADBannerView, willChangeAdSizeTo adSize: GADAdSize) {
      let height = adSize.size.height
      let width = adSize.size.width
    }
        func loadDFPNative(){
            
            dfpNativeAdUnit = GAMBannerView(adSize: GADAdSizeFluid)
            
            dfpNativeAdUnit.validAdSizes = [NSValueFromGADAdSize(GADAdSizeFluid),
                                       NSValueFromGADAdSize(GADAdSizeBanner)]
            dfpNativeAdUnit.adUnitID = "/19968336/PSP_M22_Abhishek_Native"
            dfpNativeAdUnit.rootViewController = self
            dfpNativeAdUnit.delegate = self
            dfpNativeAdUnit.backgroundColor = .green
            dfpNativeAdUnit.adSizeDelegate = self

            
            
            var frameRect = dfpNativeAdUnit.frame
            frameRect.size.width = view.bounds.width
            dfpNativeAdUnit.frame = frameRect

            
            nativeView.addSubview(dfpNativeAdUnit)
            if(nativeUnit != nil){
                nativeUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
                    print("Prebid demand fetch for DFP \(resultCode.name())")
                    self?.dfpNativeAdUnit!.load(self?.request)
                }
            }
        }
        
        func loadMoPubNative() {
            
            mopubNativeAdUnit = MPAdView(adUnitId: "037a743e5d184129ab79c941240efff8")
            mopubNativeAdUnit.frame = CGRect(x: 0, y: 0, width: 300, height: 580)
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
                                                    print("error: \(error)");

            })
            
            //TODO: ask about adViewDidReceiveAd(_ bannerView: DFPBannerView)
            self.dfpNativeAdUnit.resize(bannerView.adSize)
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        func viewControllerForPresentingModalView() -> UIViewController! {
            return self
        }
        
        func adViewDidLoadAd(_ view: MPAdView!, adSize: CGSize) {
            
            view.sizeToFit()
            
        }
        
        func adView(_ view: MPAdView!, didFailToLoadAdWithError error: Error!) {
            print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

}
