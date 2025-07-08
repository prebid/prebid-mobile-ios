//
//  ViewController.swift
//  SPMTestApp
//
//  Created by James on 6/30/25.
//

import UIKit

import PrebidMobile
import PrebidMobileAdMobAdapters
import PrebidMobileGAMEventHandlers
import PrebidMobileMAXAdapters

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(Prebid.shared.version)
        print(AdMobConstants.PrebidAdMobRewardedAdapterVersion)
        print(GAMUtils.shared)
        print(MAXConstants.PrebidMAXAdapterVersion)
    }


}

