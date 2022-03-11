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

import UIKit
import Eureka
import PrebidMobile

final class PrebidMobileXSDKConfigurationController : FormViewController {
    
    var sdkConfig: Prebid {
        return Prebid.shared
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createForm()
    }
    
    // MARK: - Private Methods
    
    func createForm() {
        title = "PrebidMobile SDK Configuration"
        
        form
            +++ sectionTimeouts
            +++ sectionMisc
            +++ sectionAppConfig
    }
    
    var sectionTimeouts: Section {
        return Section("Creative Factory Timeouts")
            <<< TextRow() { row in
                    row.title = "General"
                    row.value = "\(self.sdkConfig.creativeFactoryTimeout)"
                    row.cell.textField.accessibilityIdentifier = "creativeFactoryTimeoutTextField"
                }
                .onChange { row in
                    self.sdkConfig.creativeFactoryTimeout = row.value.pbm_toTimeInterval()
            }
            <<< TextRow() {row in
                    row.title = "Pre Render Content"
                    row.value = "\(self.sdkConfig.creativeFactoryTimeoutPreRenderContent)"
                    row.cell.textField.accessibilityIdentifier = "creativeFactoryTimeoutPreRenderContentTextField"
                }
                .onChange { row in
                    self.sdkConfig.creativeFactoryTimeoutPreRenderContent = row.value.pbm_toTimeInterval()
            }
    }
    
    var sectionMisc: Section {
        return Section("Misc")
            <<< SwitchRow() { row in
                    row.title = "Use External Clickthrough Browser"
                    row.value = self.sdkConfig.useExternalClickthroughBrowser
                    row.cell.switchControl.accessibilityIdentifier = "useExternalClickthroughBrowserSwitch"
                }
                .onChange { row in
                    self.sdkConfig.useExternalClickthroughBrowser = row.value ?? false
                }
    }
    
    var sectionAppConfig: Section {
        return Section("App configuration")
            <<< SwitchRow() { row in
                row.title = "Status Bar Hidden"
                row.value = AppConfiguration.shared.isAppStatusBarHidden
                row.cell.switchControl.accessibilityIdentifier = "statusBarHiddenSwitch"
            }
            .onChange { row in
                AppConfiguration.shared.isAppStatusBarHidden = row.value ?? true
                self.setNeedsStatusBarAppearanceUpdate()
            }
    }
}
