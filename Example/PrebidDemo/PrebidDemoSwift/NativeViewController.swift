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

fileprivate let nativeStoredImpression = "imp-prebid-banner-native-styles"


class NativeViewController: UIViewController, GADBannerViewDelegate {
    
    var nativeUnit: NativeRequest!
    
    var integrationKind: IntegrationKind = .undefined
    
    @IBOutlet var nativeView: UIView!
    
    var eventTrackers: NativeEventTracker!
    var dfpNativeAdUnit: GAMBannerView!
    let request = GAMRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPrebidServer(storedResponse: "response-prebid-banner-native-styles")
        
        loadNativeAssets()
        
        switch integrationKind {
        case .originalGAM:
            loadDFPNative()
        case .inApp:
            print("TODO: Add Example")
        case .renderingGAM:
            print("TODO: Add Example")
        case .renderingAdMob:
            print("TODO: Add Example")
        case .renderingMAX:
            print("TODO: Add Example")
        case .undefined:
            assertionFailure("The integration kind is: \(integrationKind.rawValue)")
        }
    }
    
    func setupPrebidServer(storedResponse: String) {
        Prebid.shared.accountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")

        Prebid.shared.storedAuctionResponse = storedResponse
    }
    
    func loadNativeAssets(){
        
        let image = NativeAssetImage(minimumWidth: 200, minimumHeight: 50, required: true)
        image.type = ImageAsset.Main
        
        let icon = NativeAssetImage(minimumWidth: 20, minimumHeight: 20, required: true)
        icon.type = ImageAsset.Icon
        
        let title = NativeAssetTitle(length: 90, required: true)
        
        let body = NativeAssetData(type: DataAsset.description, required: true)
        
        let cta = NativeAssetData(type: DataAsset.ctatext, required: true)
        
        let sponsored = NativeAssetData(type: DataAsset.sponsored, required: true)
        
        nativeUnit = NativeRequest(configId: nativeStoredImpression, assets: [title,icon,image,sponsored,body,cta])
        
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        
        let event1 = EventType.Impression
        eventTrackers = NativeEventTracker(event: event1, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
    }
    
    func loadDFPNative(){
        dfpNativeAdUnit = GAMBannerView(adSize: kGADAdSizeFluid)
        dfpNativeAdUnit.adUnitID = "/21808260008/unified_native_ad_unit"
        dfpNativeAdUnit.rootViewController = self
        dfpNativeAdUnit.delegate = self
        dfpNativeAdUnit.backgroundColor = .green
        nativeView.addSubview(dfpNativeAdUnit)
        if(nativeUnit != nil) {
            nativeUnit.fetchDemand(adObject: self.request) { [weak self] (resultCode: ResultCode) in
                print("Prebid demand fetch for DFP \(resultCode.name())")
                self?.dfpNativeAdUnit!.load(self?.request)
            }
        }
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
        nativeView.constraints.first { $0.firstAttribute == .width }?.constant = bannerView.adSize.size.width
        nativeView.constraints.first { $0.firstAttribute == .height }?.constant = bannerView.adSize.size.height
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func viewControllerForPresentingModalView() -> UIViewController! {
        return self
    }
}
