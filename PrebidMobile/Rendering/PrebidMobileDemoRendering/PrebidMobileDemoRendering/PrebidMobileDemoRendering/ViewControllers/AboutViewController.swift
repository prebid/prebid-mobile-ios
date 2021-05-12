//
//  AboutViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2017 OpenX, Inc. All rights reserved.
//
import Foundation
import UIKit

import Eureka

import PrebidMobileGAMEventHandlers
import PrebidMobileMoPubAdapters
import GoogleMobileAds
import MoPubSDK


class AboutViewController : FormViewController {
    
    private let info = [
        ("Components", [
            "Prebid Mobile Rendering SDK": PBMSDKConfiguration.sdkVersion,
        ]),
        ("Ad Server SDKs", [
            "GoogleMobileAds SDK": GADMobileAds.sharedInstance().sdkVersion,
            "MoPub SDK": MP_SDK_VERSION,
        ]),
        ("Bridging SDKs", [
            "GAM Event Handlers": versionOfBundle(providing: GAMBannerEventHandler.self),
            "MoPub Adapters": versionOfBundle(providing: PrebidMoPubBannerAdapter.self),
        ]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PrebidMobileRendering Configuration"
        createForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
		//Force portrait
		UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private Methods
    
    private static func versionOfBundle(providing theClass: AnyClass) -> String {
        return Bundle(for: theClass).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "nil"
    }
    
    private func createForm() {
        for (sectionTitle, frameworks) in info {
            let section = Section(sectionTitle)
            form +++ section
            for (frameworkName, frameworkVersion) in frameworks {
                section <<< LabelRow() { row in
                    row.title = frameworkName
                    row.value = frameworkVersion
                    row.cellStyle = .subtitle
                }.cellSetup { cell, row in
                    cell.detailTextLabel?.accessibilityIdentifier = "\(frameworkName) Version"
                }
            }
        }
    }
}
