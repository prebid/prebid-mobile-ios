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

import AppTrackingTransparency
import UIKit

class UtilitiesViewController: FormTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Utilities"
        let rows = [
            navigationRow("PrebidMobile Configuration") { AboutViewController() },
            navigationRow("IAB Consent Settings") { IABConsentViewController() },
            navigationRow("Command Line Args") { CommandArgsViewController() },
            navigationRow("App Settings") { SettingsViewController() }
        ]
        let tracking = FormRow("Request Tracking Authorization", kind: .action)
        tracking.onSelect = { [weak self] in
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                DispatchQueue.main.async { [weak self] in
                    let dialog = UIAlertController(title: "AT Tracking", message: "Authorization status: \(status.rawValue)", preferredStyle: .alert)
                    dialog.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(dialog, animated: true)
                }
            }
        }
        sections = [FormSection(rows: rows + [tracking])]
    }

    private func navigationRow(_ title: String, destination: @escaping () -> UIViewController) -> FormRow {
        let row = FormRow(title, kind: .action)
        row.accessoryType = .disclosureIndicator
        row.onSelect = { [weak self] in self?.navigationController?.pushViewController(destination(), animated: true) }
        return row
    }
}
