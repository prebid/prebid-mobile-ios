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

class SettingsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        createForm()
    }
    
    private func createForm() {
        title = "App Settings"
        
        form
            +++ Section("HUD Settings")
            <<< showHUDRow
    }

    private static func switchRow(for userDefaultsKey: String, title: String) -> SwitchRow {
        return SwitchRow() { row in
            row.title = title
            row.value = UserDefaults.standard.bool(forKey: userDefaultsKey)
            row.cell.accessibilityIdentifier = title
        }.onChange { row in
            UserDefaults.standard.set(row.value, forKey: userDefaultsKey)
        }
    }
    
    private let showHUDRow = switchRow(for: AppSettingsKeys.showHUD, title: "Show HUD")
}
