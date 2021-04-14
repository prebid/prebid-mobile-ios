//
//  IABConsentSettingKey.swift
//  OpenXInternalTestApp
//
//  Copyright © 2019 OpenX. All rights reserved.
//

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
