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

class SettingsViewController: FormTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "App Settings"
        let row = FormRow("Show HUD", kind: .toggle, isOn: UserDefaults.standard.bool(forKey: AppSettingsKeys.showHUD))
        row.identifier = "Show HUD"
        row.onToggle = { UserDefaults.standard.set($0, forKey: AppSettingsKeys.showHUD) }
        sections = [FormSection("HUD Settings", rows: [row])]
    }
}
