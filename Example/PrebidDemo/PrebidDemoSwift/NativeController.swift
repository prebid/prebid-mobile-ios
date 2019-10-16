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
    var assets:NativeAsset!
    var eventTrackers:NativeEventTracker!
    var dfpNativeAdUnit:GADAdLoader!
    let request = DFPRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assets = NativeAsset()
        assets.title = NativeAssetTitle(length:25)
        assets.image = NativeAssetImage(minimumWidth: 20, minimumHeight: 30)
        nativeUnit = NativeRequest(configId: "25e17008-5081-4676-94d5-923ced4359d3", assets: [assets])
        nativeUnit.context = ContextType.Social
        nativeUnit.placementType = PlacementType.FeedContent
        //nativeUnit.contextSubType = ContextSubType.General
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
