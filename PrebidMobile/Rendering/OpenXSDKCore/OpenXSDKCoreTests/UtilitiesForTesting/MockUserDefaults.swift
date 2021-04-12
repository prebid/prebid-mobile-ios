//
//  MockUserDefaults.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit

class MockUserDefaults: UserDefaults {

    var mock_subjectToGDPR = false
    var mock_consentString: String? = "consentstring"

    override func bool(forKey defaultName: String) -> Bool {
        return (defaultName == "IABConsent_SubjectToGDPR") ? self.mock_subjectToGDPR : false
    }

    override func object(forKey defaultName: String) -> Any? {
        switch defaultName {
        case "IABConsent_SubjectToGDPR":
            return self.mock_subjectToGDPR
        case "IABConsent_ConsentString":
            return self.mock_consentString
        default:
            return nil
        }
    }

}
