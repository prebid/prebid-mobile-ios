//
//  NativeController.swift
//  PrebidDemoSwift
//
//  Created by Punnaghai Puviarasu on 10/14/19.
//  Copyright © 2019 Prebid. All rights reserved.
//

import UIKit

import PrebidMobile

import GoogleMobileAds

class NativeController: UIViewController, GADNativeAdDelegate {
    
    var nativeUnit: NativeRequest!
    
    var eventTrackers:NativeEventTracker!
    var dfpNativeAdUnit:GADAdLoader!
    let request = DFPRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let asset1 = NativeAsset()
        asset1.required = true
        asset1.image = NativeAssetImage(minimumWidth: 200, minimumHeight: 200)
        asset1.image?.type = ImageAsset.Main
        
        let asset2 = NativeAsset()
        asset2.required = true
        asset2.title = NativeAssetTitle(length: 90)
        
        nativeUnit = NativeRequest(configId: "1f85e687-b45f-4649-a4d5-65f74f2ede8e", assets: [asset1,asset2])
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        nativeUnit.contextSubType = ContextSubType.Social
        eventTrackers = NativeEventTracker(event: EventType.Impression, methods: [EventTracking.Image,EventTracking.js])
        nativeUnit.eventtrackers = [eventTrackers]
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ (kGADSimulatorID as! String), "cc7ca766f86b43ab6cdc92bed424069b"]
        dfpNativeAdUnit = GADAdLoader(adUnitID: "/19968336/Wei_Prebid_Native_Test", rootViewController: self, adTypes: [GADAdLoaderAdType.unifiedNative], options: [])
        
        
        nativeUnit.fetchDemand(adObject: self.request) {[weak self] (resultCode:ResultCode) in
            print("Prebid demand fetch for DFP \(resultCode.name())")
            self?.dfpNativeAdUnit!.load(self?.request)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
