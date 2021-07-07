//
//  ViewController.swift
//  TestPodspecModules
//
//  Created by Vadim Khohlov on 6/29/21.
//

import UIKit

import GoogleMobileAds
import MoPubSDK

import PrebidMobileRendering
import PrebidMobileMoPubAdapters
import PrebidMobileGAMEventHandlers

class ViewController: UIViewController {
    
    @IBOutlet weak var projectVersionLabel: UILabel!
    @IBOutlet weak var renderingVersionLabel: UILabel!
    
    
    @IBOutlet weak var gamVersionLabel: UILabel!
    @IBOutlet weak var mopubVersionLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        projectVersionLabel.text = version
        
        renderingVersionLabel.text = PrebidRenderingConfig.shared.version
        
        gamVersionLabel.text = GADMobileAds.sharedInstance().sdkVersion
        mopubVersionLabel.text = MoPub.sharedInstance().version()
    }
}

