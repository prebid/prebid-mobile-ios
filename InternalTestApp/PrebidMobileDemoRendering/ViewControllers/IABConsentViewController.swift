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

final class IABConsentViewController: FormTableViewController {
    private var defaultsObserver: NSObjectProtocol?
    private var defaultsRows: [(String, FormRow)] = []

    deinit {
        if let observer = defaultsObserver { NotificationCenter.default.removeObserver(observer) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IAB Consent Settings"
        sections = [
            FormSection("TCF v1", rows: [
                defaultsRow(IABConsentSettingKey.TCF.v1.cmpPresent, title: "CMP present", kind: .toggle),
                defaultsRow(IABConsentSettingKey.TCF.v1.subjectToGDPR, title: "Subject To GDPR"),
                defaultsRow(IABConsentSettingKey.TCF.v1.consentString, title: "GDPR Consent String")
            ]),
            FormSection("TCF v2", rows: [
                defaultsRow(IABConsentSettingKey.TCF.v2.cmpSdkId, title: "CMP SDK ID"),
                defaultsRow(IABConsentSettingKey.TCF.v2.subjectToGDPR, title: "Subject To GDPR"),
                defaultsRow(IABConsentSettingKey.TCF.v2.consentString, title: "GDPR Consent String")
            ]),
            FormSection("CCPA", rows: [defaultsRow(IABConsentSettingKey.usPrivacyString, title: "US Privacy String")]),
            FormSection("Testing", rows: [defaultsRow(IABConsentSettingKey.keepSettings, title: "Keep settings", kind: .toggle)])
        ]
        defaultsObserver = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            for (key, row) in self.defaultsRows {
                row.value = UserDefaults.standard.string(forKey: key) ?? ""
                row.isOn = UserDefaults.standard.bool(forKey: key)
            }
            self.refreshVisibleValues()
        }
    }

    private func defaultsRow(_ key: String, title: String, kind: FormRow.Kind = .text) -> FormRow {
        let row = FormRow(title, kind: kind, value: UserDefaults.standard.string(forKey: key) ?? "", isOn: UserDefaults.standard.bool(forKey: key))
        row.identifier = title
        row.onTextChange = { value in
            if value.isEmpty { UserDefaults.standard.removeObject(forKey: key) }
            else { UserDefaults.standard.set(value, forKey: key) }
        }
        row.onToggle = { UserDefaults.standard.set($0, forKey: key) }
        defaultsRows.append((key, row))
        return row
    }
}
