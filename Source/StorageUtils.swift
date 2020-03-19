/*   Copyright 2018-2019 Prebid.org, Inc.

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

class StorageUtils {
    //COPPA
    static let PB_COPPAKey = "kPBCoppaSubjectToConsent"
    
    //GDPR - publisher set local
    static let PBConsent_SubjectToGDPRKey = "kPBGdprSubjectToConsent"
    
    static let PBConsent_ConsentStringKey = "kPBGDPRConsentString"
    
    static let PBConsent_PurposeConsentsStringKey = "kPBGDPRPurposeConsents"

    //TCF 1.1
    static let IABConsent_SubjectToGDPRKey = "IABConsent_SubjectToGDPR"

    static let IABConsent_ConsentStringKey = "IABConsent_ConsentString"
    
    //TCF 2.0 variables
    static let IABTCF_ConsentString = "IABTCF_TCString"
    
    static let IABTCF_SubjectToGDPR = "IABTCF_gdprApplies"
    
    static let IABTCF_PurposeConsents = "IABTCF_PurposeConsents"
    
    //CCPA
    static let IABUSPrivacy_StringKey = "IABUSPrivacy_String"
    
    //MARK: - getters and setters
    
    //COPPA
    static func pbCoppa() -> Bool {
        return UserDefaults.standard.bool(forKey: StorageUtils.PB_COPPAKey)
    }
    
    static func setPbCoppa(value: Bool) {
        setUserDefaults(value: value, forKey: StorageUtils.PB_COPPAKey)
    }
    
    //GDPR
    static func pbGdprSubject() -> Bool? {
        return getObjectFromUserDefaults(forKey: StorageUtils.PBConsent_SubjectToGDPRKey)
    }
    
    static func setPbGdprSubject(value: Bool?) {
        setUserDefaults(value: value, forKey: StorageUtils.PBConsent_SubjectToGDPRKey)
    }
    
    static func iabGdprSubject() -> Bool? {
        var gdprSubject: Bool? = nil
        
        let gdprSubjectTcf2: NSNumber? = getObjectFromUserDefaults(forKey: StorageUtils.IABTCF_SubjectToGDPR)
        
        if let gdprSubjectTcf2 = gdprSubjectTcf2 {
            if gdprSubjectTcf2 == 1 {
                gdprSubject = true
            } else if gdprSubjectTcf2 == 0 {
                gdprSubject = false
            }
        } else {
            let gdprSubjectTcf1: String? = getObjectFromUserDefaults(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)

            if let gdprSubjectTcf1 = gdprSubjectTcf1 {
                
                if gdprSubjectTcf1 == "1" {
                    gdprSubject = true
                } else if gdprSubjectTcf1 == "0" {
                    gdprSubject = false
                }
            }
        }

        return gdprSubject
    }
    
    static func pbGdprConsent() -> String? {
        return getObjectFromUserDefaults(forKey: StorageUtils.PBConsent_ConsentStringKey)
    }
    
    static func setPbGdprConsent(value: String?) {
        setUserDefaults(value: value, forKey: StorageUtils.PBConsent_ConsentStringKey)
    }
    
    static func iabGdprConsent() -> String? {
        var gdprConsentString: String? = getObjectFromUserDefaults(forKey: StorageUtils.IABTCF_ConsentString)
        
        if (gdprConsentString ?? "").isEmpty {
            gdprConsentString = getObjectFromUserDefaults(forKey: StorageUtils.IABConsent_ConsentStringKey)
        }

        return gdprConsentString
        
    }
    
    static func setPbPurposeConsents(value: String?) {
        setUserDefaults(value: value, forKey: StorageUtils.PBConsent_PurposeConsentsStringKey)
    }
    
    static func pbPurposeConsents() -> String? {
        return getObjectFromUserDefaults(forKey: StorageUtils.PBConsent_PurposeConsentsStringKey)
    }
    
    static func iabPurposeConsents() -> String? {
        return getObjectFromUserDefaults(forKey: StorageUtils.IABTCF_PurposeConsents)
    }
    
    //CCPA
    static func iabCcpa() -> String? {
        return getObjectFromUserDefaults(forKey: StorageUtils.IABUSPrivacy_StringKey)
    }
    
    //MARK: - private zone
    private static func setUserDefaults(value: Any?, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    private static func getObjectFromUserDefaults<T>(forKey: String) -> T? {
        return UserDefaults.standard.object(forKey: forKey) as? T
    }
}
