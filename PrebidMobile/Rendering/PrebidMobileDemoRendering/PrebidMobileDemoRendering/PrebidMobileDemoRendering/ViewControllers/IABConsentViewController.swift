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

final class IABConsentViewController : FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createForm()
        
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else {
                return
            }
            self.tcf1_cmpPresentRow.value = UserDefaults.standard.bool(forKey: IABConsentSettingKey.TCF.v1.cmpPresent)
            self.tcf1_subjectToGDPRRow.value = UserDefaults.standard.string(forKey: IABConsentSettingKey.TCF.v1.subjectToGDPR) ?? ""
            self.tcf1_gdprConsentStringRow.value = UserDefaults.standard.string(forKey: IABConsentSettingKey.TCF.v1.consentString) ?? ""
            
            self.tcf2_cmpSdkId.value = UserDefaults.standard.string(forKey: IABConsentSettingKey.TCF.v2.cmpSdkId) ?? ""
            self.tcf2_subjectToGDPRRow.value = UserDefaults.standard.string(forKey: IABConsentSettingKey.TCF.v2.subjectToGDPR) ?? ""
            self.tcf2_gdprConsentStringRow.value = UserDefaults.standard.string(forKey: IABConsentSettingKey.TCF.v2.consentString) ?? ""
            
            self.usPrivacyStringRow.value = UserDefaults.standard.string(forKey: IABConsentSettingKey.usPrivacyString) ?? ""
        }
        
        self.navigationItem.title = "IAB Consent Settings"
    }
    
    // MARK: - Private Methods
    
    private func createForm() {
        title = "IAB Consent Settings"
        
        form
            +++ Section("TCF v1")
            <<< tcf1_cmpPresentRow
            <<< tcf1_subjectToGDPRRow
            <<< tcf1_gdprConsentStringRow
            +++ Section("TCF v2")
            <<< tcf2_cmpSdkId
            <<< tcf2_subjectToGDPRRow
            <<< tcf2_gdprConsentStringRow
            +++ Section("CCPA")
            <<< usPrivacyStringRow
            +++ Section("Testing")
            <<< keepSettingsRow
    }
    
    private static func textRow(for userDefaultsKey: String, title: String) -> TextRow {
        return TextRow() { row in
            row.title = title
            row.value = UserDefaults.standard.string(forKey: userDefaultsKey) ?? ""
            row.cell.accessibilityIdentifier = title
        }.onChange { row in
            if row.value?.isEmpty ?? true {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            } else {
                UserDefaults.standard.set(row.value, forKey: userDefaultsKey)
            }
        }
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
    
    private let tcf1_cmpPresentRow = switchRow(for: IABConsentSettingKey.TCF.v1.cmpPresent, title: "CMP present")
    private let tcf1_subjectToGDPRRow = textRow(for: IABConsentSettingKey.TCF.v1.subjectToGDPR, title: "Subject To GDPR")
    private let tcf1_gdprConsentStringRow = textRow(for: IABConsentSettingKey.TCF.v1.consentString, title: "GDPR Consent String")
    
    private let tcf2_cmpSdkId = textRow(for: IABConsentSettingKey.TCF.v2.cmpSdkId, title: "CMP SDK ID")
    private let tcf2_subjectToGDPRRow = textRow(for: IABConsentSettingKey.TCF.v2.subjectToGDPR, title: "Subject To GDPR")
    private let tcf2_gdprConsentStringRow = textRow(for: IABConsentSettingKey.TCF.v2.consentString, title: "GDPR Consent String")
    
    private let usPrivacyStringRow = textRow(for: IABConsentSettingKey.usPrivacyString, title: "US Privacy String")
    
    private let keepSettingsRow = switchRow(for: IABConsentSettingKey.keepSettings, title: "Keep settings")
}
