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
import PrebidMobile

final class PrebidMobileXSDKConfigurationController: FormTableViewController {
    var sdkConfig: Prebid { Prebid.shared }

    override func viewDidLoad() {
        super.viewDidLoad()
        createForm()
    }

    func createForm() {
        title = "PrebidMobile SDK Configuration"
        let general = FormRow("General", kind: .text, value: "\(sdkConfig.creativeFactoryTimeout)")
        general.controlIdentifier = "creativeFactoryTimeoutTextField"
        general.onTextChange = { [weak self] in self?.sdkConfig.creativeFactoryTimeout = TimeInterval($0.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        let preRender = FormRow("Pre Render Content", kind: .text, value: "\(sdkConfig.creativeFactoryTimeoutPreRenderContent)")
        preRender.controlIdentifier = "creativeFactoryTimeoutPreRenderContentTextField"
        preRender.onTextChange = { [weak self] in self?.sdkConfig.creativeFactoryTimeoutPreRenderContent = TimeInterval($0.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0 }
        let statusBar = FormRow("Status Bar Hidden", kind: .toggle, isOn: AppConfiguration.shared.isAppStatusBarHidden)
        statusBar.controlIdentifier = "statusBarHiddenSwitch"
        statusBar.onToggle = { [weak self] in
            AppConfiguration.shared.isAppStatusBarHidden = $0
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        sections = [FormSection("Creative Factory Timeouts", rows: [general, preRender]), FormSection("App configuration", rows: [statusBar])]
    }
}
