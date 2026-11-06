/*   Copyright 2018-2021 Prebid.org, Inc.

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

import Foundation
import UIKit


import GoogleMobileAds

import PrebidMobile
import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters

class AboutViewController : FormTableViewController {
    
    private let info = [
        ("Components", [
            "Prebid Mobile Rendering SDK": Prebid.shared.version,
            "OMSDK_Prebidorg": Prebid.shared.omsdkVersion
        ]),
        ("Ad Server SDKs", [
            "GoogleMobileAds SDK": "\(MobileAds.shared.versionNumber)",
        ]),
        ("Bridging SDKs", [
            "GAM Event Handlers": versionOfBundle(providing: GAMBannerEventHandler.self),
            "AdMob Adapters": versionOfBundle(providing: PrebidAdMobBannerAdapter.self),
        ]),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PrebidMobile Configuration"
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
        sections = info.map { sectionTitle, frameworks in
            FormSection(sectionTitle, rows: frameworks.map { frameworkName, frameworkVersion in
                let row = FormRow(frameworkName, kind: .label, value: frameworkVersion)
                row.detailIdentifier = "\(frameworkName) Version"
                return row
            })
        }
    }
}
