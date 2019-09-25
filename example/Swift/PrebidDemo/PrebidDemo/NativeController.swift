//
//  NativeController.swift
//  PrebidDemo
//
//  Created by Wei Zhang on 9/24/19.
//  Copyright © 2019 Prebid. All rights reserved.
//

import UIKit

import PrebidMobile

import GoogleMobileAds

import MoPub

class NativeController : UIViewController,GADBannerViewDelegate, MPAdViewDelegate{

    
    var adServerName: String = ""
    var nativeAdUnit: NativeAdUnit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nativeAdUnit = NativeAdUnit(configId: "25e17008-5081-4676-94d5-923ced4359d3")
        if(adServerName == "DFP"){
            loadDFPNative()
        } else{
            loadMoPubNative()
        }
    }
    
    func loadMoPubNative(){
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "a470959f33034229945744c5f904d5bc")
        sdkConfig.globalMediationSettings = []
        
        MoPub.sharedInstance().initializeSdk(with: sdkConfig) {
            
        }
        let mopubBanner = MPAdView(adUnitId: "a470959f33034229945744c5f904d5bc", size: CGSize(width: 300, height: 400))
        mopubBanner!.delegate = self
        
        nativeAdUnit.fetchDemand(adObject: mopubBanner!) { (resultCode) in
            mopubBanner!.loadAd()
        }
    }
    
    func adViewDidLoadAd(_ view: MPAdView!) {
        self.view .addSubview(view)
    }
    
    func adViewDidFail(toLoadAd view: MPAdView!) {
        print("MoPub ad failed to load")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        // do nothing
        return self
    }
    
    func loadDFPNative(){
        let dfpBanner = DFPBannerView(adSize: kGADAdSizeFluid)
        dfpBanner.adUnitID = "/19968336/Wei_Prebid_Native_Test"
        dfpBanner.rootViewController = self
        dfpBanner.delegate = self
        let request = DFPRequest();
        nativeAdUnit.fetchDemand(adObject: request) { (resultCode) in
         dfpBanner.load(request);
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        var frame = bannerView.frame
        frame.origin = CGPoint(x:0,y:150)
        bannerView.frame = frame
        self.view.addSubview(bannerView);
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("DFP ad failed to load")
    }
    
}
