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

enum IABConsentSettingKey {
    enum TCF {
        enum v1 {
            static let cmpPresent = "IABConsent_CMPPresent"
            static let subjectToGDPR = "IABConsent_SubjectToGDPR"
            static let consentString = "IABConsent_ConsentString"
        }
        enum v2 {
            static let cmpSdkId = "IABTCF_CmpSdkID"
            static let subjectToGDPR = "IABTCF_gdprApplies"
            static let consentString = "IABTCF_TCString"
        }
    }
    
    // MARK: - CCPA
    static let usPrivacyString = "IABUSPrivacy_String"
    
    // MARK: - Internal
    static let keepSettings = "IABConsent__KeepSettings"
    
    // MARK: - Cumulative
    static let allowedPrefixes = [
        "IABConsent_",
        "IABTCF_",
        "IABUSPrivacy_",
    ]
}
