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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assets = NativeAsset()
        assets.title = NativeAssetTitle(length:25)
        assets.image = NativeAssetImage(minimumWidth: 20, minimumHeight: 30)
        nativeUnit = NativeRequest(configId: "25e17008-5081-4676-94d5-923ced4359d3", assets: [assets])
        
        
       

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
