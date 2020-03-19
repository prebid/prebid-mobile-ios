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


import XCTest

@testable import PrebidMobile

class StorageUtilsTests: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func testPB_COPPAKey() {
        XCTAssertEqual("kPBCoppaSubjectToConsent", StorageUtils.PB_COPPAKey)
    }
    
    func testPBConsent_SubjectToGDPRKey() {
        XCTAssertEqual("kPBGdprSubjectToConsent", StorageUtils.PBConsent_SubjectToGDPRKey)
    }
    
    func testPBConsent_ConsentStringKey() {
        XCTAssertEqual("kPBGDPRConsentString", StorageUtils.PBConsent_ConsentStringKey)
    }
    
    func testPBConsent_PurposeConsentsStringKey() {
        XCTAssertEqual("kPBGDPRPurposeConsents", StorageUtils.PBConsent_PurposeConsentsStringKey)
    }
    
    func testIABConsent_SubjectToGDPRKey() {
        XCTAssertEqual("IABConsent_SubjectToGDPR", StorageUtils.IABConsent_SubjectToGDPRKey)
    }
    
    func testIABConsent_ConsentStringKey() {
        XCTAssertEqual("IABConsent_ConsentString", StorageUtils.IABConsent_ConsentStringKey)
    }
    
    func testIABTCF_ConsentString() {
        XCTAssertEqual("IABTCF_TCString", StorageUtils.IABTCF_ConsentString)
    }
    
    func testIABTCF_SubjectToGDPR() {
        XCTAssertEqual("IABTCF_gdprApplies", StorageUtils.IABTCF_SubjectToGDPR)
    }
    
    func testIABTCF_PurposeConsents() {
        XCTAssertEqual("IABTCF_PurposeConsents", StorageUtils.IABTCF_PurposeConsents)
    }
    
    func testIABUSPrivacy_StringKey() {
        XCTAssertEqual("IABUSPrivacy_String", StorageUtils.IABUSPrivacy_StringKey)
    }
    
    // MARK: - COPPA
    func testPbCoppa() {
        //given
        StorageUtils.setPbCoppa(value: true)
        defer {
            StorageUtils.setPbCoppa(value: false)
        }
        
        //when
        let coppa = StorageUtils.pbCoppa()
        
        //then
        XCTAssertEqual(true, coppa)
    }
    
    // MARK: - GDPR Subject
    
    func testGdprSubjectPb() {
        //given
        StorageUtils.setPbGdprSubject(value: true)
        defer {
            StorageUtils.setPbGdprSubject(value: nil)
        }
        
        //when
        let gdprSubject = StorageUtils.pbGdprSubject()
        
        //then
        XCTAssertEqual(true, gdprSubject)
    }
    
    func testGdprSubjectPbUndefined() {
        //given
        StorageUtils.setPbGdprSubject(value: nil)
        
        //when
        let gdprSubject = StorageUtils.pbGdprSubject()
        
        //then
        XCTAssertNil(gdprSubject)
    }
    
    func testGdprSubjectIabUndefined() {
        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_SubjectToGDPR)
        
        //when
        let gdprSubject = StorageUtils.pbGdprSubject()
        
        //then
        XCTAssertNil(gdprSubject)
    }
    
    func testGdprSubjectTCFv1Filled() {
        UserDefaults.standard.set("1", forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        }
        
        //when
        let gdprSubject = StorageUtils.iabGdprSubject()
        
        //then
        XCTAssertEqual(true, gdprSubject)
    }
    
    func testGdprSubjectTCFv2Filled() {
        UserDefaults.standard.set(1, forKey: StorageUtils.IABTCF_SubjectToGDPR)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_SubjectToGDPR)
        }
        
        //when
        let gdprSubject = StorageUtils.iabGdprSubject()
        
        //then
        XCTAssertEqual(true, gdprSubject)
    }
    
    //MARK: - GDPR Consent
    func testGdprConsentPb() {
        //given
        StorageUtils.setPbGdprConsent(value: "testPbGdprConsent")
        defer {
            StorageUtils.setPbGdprConsent(value: nil)
        }
        
        //when
        let gdprConsent = StorageUtils.pbGdprConsent()
        
        //then
        XCTAssertEqual("testPbGdprConsent", gdprConsent)
    }
    
    func testGdprConsentPbUndefined() {
        //given
        StorageUtils.setPbGdprConsent(value: nil)
        
        //when
        let gdprConsent = StorageUtils.pbGdprConsent()
        
        //then
        XCTAssertNil(gdprConsent)
    }
    
    func testGdprConsentIabUndefined() {
        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_ConsentStringKey)
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_ConsentString)
        
        //when
        let gdprConsent = StorageUtils.iabGdprSubject()
        
        //then
        XCTAssertNil(gdprConsent)
    }
    
    func testGdprConsentTCFv1Filled() {
        UserDefaults.standard.set("testIabGdprConsentFilled", forKey: StorageUtils.IABConsent_ConsentStringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_ConsentStringKey)
        }
        
        //when
        let gdprConsent = StorageUtils.iabGdprConsent()
        
        //then
        XCTAssertEqual("testIabGdprConsentFilled", gdprConsent)
    }
    
    func testGdprConsentTCFv2Filled() {
        UserDefaults.standard.set("testIabGdprConsentFilled", forKey: StorageUtils.IABTCF_ConsentString)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_ConsentString)
        }
        
        //when
        let gdprConsent = StorageUtils.iabGdprConsent()
        
        //then
        XCTAssertEqual("testIabGdprConsentFilled", gdprConsent)
    }
    
    //MARK: - Purpose Consent
    
    func testPurposeConsentPb() {
        //given
        StorageUtils.setPbPurposeConsents(value: "PurposeConsents")
        defer {
            StorageUtils.setPbPurposeConsents(value: nil)
        }
        
        //when
        let purposeConsent = StorageUtils.pbPurposeConsents()
        
        //then
        XCTAssertEqual("PurposeConsents", purposeConsent)
    }
    
    func testPurposeConsentPbUndefined() {
        //given
        StorageUtils.setPbPurposeConsents(value: nil)
        
        //when
        let purposeConsent = StorageUtils.pbPurposeConsents()
        
        //then
        XCTAssertEqual(nil, purposeConsent)
    }
    
    func testPurposeConsentIab() {
        //given
        UserDefaults.standard.set("testPurposeConsentIab", forKey: StorageUtils.IABTCF_PurposeConsents)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_PurposeConsents)
        }
        
        //when
        let purposeConsent = StorageUtils.iabPurposeConsents()
        
        //then
        XCTAssertEqual("testPurposeConsentIab", purposeConsent)
    }
    
    func testPurposeConsentIabUndefined() {
        //given
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_PurposeConsents)
        
        //when
        let purposeConsent = StorageUtils.pbPurposeConsents()
        
        //then
        XCTAssertEqual(nil, purposeConsent)
    }
    
    //MARK: - CCPA
    func testCcpaNotExist() {
        
        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        
        //when
        let ccpa = StorageUtils.iabCcpa()
        
        //then
        XCTAssertNil(ccpa)
    }
    
    func testCcpaFilled() {
        
        //given
        UserDefaults.standard.set("testCCPA", forKey: StorageUtils.IABUSPrivacy_StringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        }
        
        //when
        let ccpa = StorageUtils.iabCcpa()
        
        //then
        XCTAssertEqual("testCCPA", ccpa)
    }
    
    func testCcpaEmpty() {
        
        //given
        UserDefaults.standard.set("", forKey: StorageUtils.IABUSPrivacy_StringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        }
        
        //when
        let ccpa = StorageUtils.iabCcpa()
        
        //then
        XCTAssertEqual("", ccpa)
    }
    
}
