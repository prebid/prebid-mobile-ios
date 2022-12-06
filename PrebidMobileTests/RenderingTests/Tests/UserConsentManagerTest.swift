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

import XCTest
@testable import PrebidMobile

protocol TCFEdition {
    var subjectToGDPRKey: String { get }
    var consentStringKey: String { get }
    var purposeConsentsStringKey : String { get }
}

class UserConsentDataManagerTest: XCTestCase {
    
    enum TCF {
        static let v2 = TCF2()
        
        struct TCF2: TCFEdition {
            let subjectToGDPRKey = "IABTCF_gdprApplies"
            let consentStringKey = "IABTCF_TCString"
            let purposeConsentsStringKey: String = "IABTCF_PurposeConsents"
        }
    }
    
    let consentString1 = "consentstring1"
    let consentString2 = "consentstring2"
    
    let purposeConsentsString0 = "00000000"
    let purposeConsentsString1 = "11111111"
    
    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: TCF.v2.subjectToGDPRKey)
        UserDefaults.standard.removeObject(forKey: TCF.v2.consentStringKey)
        UserDefaults.standard.removeObject(forKey: TCF.v2.purposeConsentsStringKey)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABGPP_HDR_GppString)
        UserDefaults.standard.removeObject(forKey: InternalUserConsentDataManager.IABGPP_GppSID)
        
        UserConsentDataManager.shared.subjectToCOPPA = nil
        UserConsentDataManager.shared.gdprConsentString = nil
        UserConsentDataManager.shared.purposeConsents = nil
        UserConsentDataManager.shared.subjectToGDPR = nil
    }
    
    func testIABTCF_ConsentString() {
        XCTAssertEqual("IABTCF_TCString", UserConsentDataManager.shared.IABTCF_ConsentString)
    }
    
    func testIABTCF_SubjectToGDPR() {
        XCTAssertEqual("IABTCF_gdprApplies", UserConsentDataManager.shared.IABTCF_SubjectToGDPR)
    }
    
    func testIABTCF_PurposeConsents() {
        XCTAssertEqual("IABTCF_PurposeConsents", UserConsentDataManager.shared.IABTCF_PurposeConsents)
    }
    
    func testPB_COPPA() {
        //given
        UserConsentDataManager.shared.subjectToCOPPA = true
        
        defer {
            UserConsentDataManager.shared.subjectToCOPPA = false
        }
        
        //when
        let coppa = UserConsentDataManager.shared.subjectToCOPPA
        
        //then
        XCTAssertEqual(true, coppa)
    }
    
    func testAPIProvidedOverIAB_subjectToGDPR() {
        self.setSubjectToGDPR(bool: true)
        
        UserConsentDataManager.shared.subjectToGDPR = false
        self.assertExpectedConsent(subjectToGDPR: false, consentString: nil)
    }
    
    func testAPIProvidedOverIAB_gdprConsentString() {
        self.setGDPRConsentString(val: self.consentString1)
        
        UserConsentDataManager.shared.gdprConsentString = consentString2
        self.assertExpectedConsent(subjectToGDPR: nil, consentString: consentString2)
    }
    
    func testAPIProvidedOverIAB_purposeConsents() {
        self.setPurposeConsentsString(val: purposeConsentsString1)
        
        UserConsentDataManager.shared.purposeConsents = purposeConsentsString0
        self.assertPurposeConsentsString(purposeConsentsString0)
    }
    
    // MARK: IABConsent_SubjectToGDPR values
    func testIABConsent_NilSubjectToGDPR() {
        self.assertExpectedConsent(subjectToGDPR: nil, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withString() {
        self.setSubjectToGDPR(string: "1")
        self.assertExpectedConsent(subjectToGDPR: true, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withString() {
        self.setSubjectToGDPR(string: "0")
        self.assertExpectedConsent(subjectToGDPR: false, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withStringBool() {
        self.setSubjectToGDPR(string: "YES")
        self.assertExpectedConsent(subjectToGDPR: true, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withStringBool() {
        self.setSubjectToGDPR(string: "NO")
        self.assertExpectedConsent(subjectToGDPR: false, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withInt() {
        self.setSubjectToGDPR(int: 1)
        self.assertExpectedConsent(subjectToGDPR: true, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withInt() {
        self.setSubjectToGDPR(int: 0)
        self.assertExpectedConsent(subjectToGDPR: false, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withBool() {
        self.setSubjectToGDPR(bool: true)
        self.assertExpectedConsent(subjectToGDPR: true, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withBool() {
        self.setSubjectToGDPR(bool: false)
        self.assertExpectedConsent(subjectToGDPR: false, consentString: nil)
    }
    
    // MARK: IABConsent_ConsentString values
    func testIABConsent_IsSubjectToGDPR_MissingConsentString() {
        self.setSubjectToGDPR(string: "1")
        self.assertExpectedConsent(subjectToGDPR: true, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_IncludesConsentString() {
        self.setSubjectToGDPR(string: "0")
        self.setGDPRConsentString(val: self.consentString1)
        self.assertExpectedConsent(subjectToGDPR: false, consentString: self.consentString1)
    }
    
    func testIABConsent_IsSubjectToGDPR_IncludesConsentString() {
        self.setSubjectToGDPR(string: "1")
        self.setGDPRConsentString(val: self.consentString1)
        self.assertExpectedConsent(subjectToGDPR: true, consentString: self.consentString1)
    }
    
    // MARK: TCFv2
    func testTCFv2_Empty() {
        assertExpectedConsent(subjectToGDPR: nil, consentString: nil)
    }
    
    func testTCFv2_IsSubject() {
        setSubjectToGDPR(tcf: TCF.v2, bool: true)
        assertExpectedConsent(subjectToGDPR: true, consentString: nil)
    }
    
    func testTCFv2_ConsentString() {
        setSubjectToGDPR(tcf: TCF.v2, bool: true)
        setGDPRConsentString(tcf: TCF.v2, val: consentString1)
        assertExpectedConsent(subjectToGDPR: true, consentString: consentString1)
    }
    
    func testTCFv2_PurposeConsentsString() {
        self.setPurposeConsentsString(val: purposeConsentsString1)
        assertPurposeConsentsString(purposeConsentsString1)
    }
    
    // MARK: User defaults changes
    func testIABConsent_ConsentString_Changed() {
        self.setSubjectToGDPR(string: "1")
        self.setGDPRConsentString(val: self.consentString1)
        
        self.assertExpectedConsent(subjectToGDPR: true, consentString: self.consentString1)
        
        self.setGDPRConsentString(val: self.consentString2)
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertExpectedConsent(subjectToGDPR: true, consentString: self.consentString2)
    }
    
    func testIABConsent_isSubjectToGDPR_Changed_TCF2() {
        self.setSubjectToGDPR(tcf: TCF.v2, string: "1")
        self.setGDPRConsentString(tcf: TCF.v2, val: self.consentString1)
        
        self.assertExpectedConsent(subjectToGDPR: true, consentString: consentString1)
        
        self.setSubjectToGDPR(tcf: TCF.v2, string: "0")
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertExpectedConsent(subjectToGDPR: false, consentString: self.consentString1)
    }
    
    func testIABConsent_PurposeConsentsString_Changed() {
        self.setPurposeConsentsString(val: purposeConsentsString1)
        self.assertPurposeConsentsString(purposeConsentsString1)
        
        self.setPurposeConsentsString(val: purposeConsentsString0)
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertPurposeConsentsString(purposeConsentsString0)
    }
    
    //fetch advertising identifier based TCF 2.0 Purpose1 value
    //truth table
    /*
     deviceAccessConsent=true   deviceAccessConsent=false  deviceAccessConsent undefined
     gdprApplies=false        Yes, read IDFA             No, don’t read IDFA           Yes, read IDFA
     gdprApplies=true         Yes, read IDFA             No, don’t read IDFA           No, don’t read IDFA
     gdprApplies=undefined    Yes, read IDFA             No, don’t read IDFA           Yes, read IDFA
     */
    func testCanAccessDeviceDataGDPRFalse() {
        self.setSubjectToGDPR(tcf: TCF.v2, bool: false)
        
        let userConsentManager = UserConsentDataManager.shared
        
        // deviceAccessConsent undefined -> YES
        XCTAssertTrue(userConsentManager.isAllowedAccessDeviceData())
        
        // deviceAccessConsent 0 -> NO
        self.setPurposeConsentsString(val: purposeConsentsString0)
        XCTAssertFalse(userConsentManager.isAllowedAccessDeviceData())
        
        // deviceAccessConsent 1 -> YES
        self.setPurposeConsentsString(val: purposeConsentsString1)
        XCTAssertTrue(userConsentManager.isAllowedAccessDeviceData())
    }
    
    func testCanAccessDeviceDataGDPRTrue() {
        self.setSubjectToGDPR(tcf: TCF.v2, bool: true)
        
        let userConsentManager = UserConsentDataManager.shared
        
        // deviceAccessConsent undefined -> NO
        XCTAssertFalse(userConsentManager.isAllowedAccessDeviceData())
        
        // deviceAccessConsent 0 -> NO
        self.setPurposeConsentsString(val: purposeConsentsString0)
        XCTAssertFalse(userConsentManager.isAllowedAccessDeviceData())
        
        // deviceAccessConsent 1 -> YES
        self.setPurposeConsentsString(val: purposeConsentsString1)
        XCTAssertTrue(userConsentManager.isAllowedAccessDeviceData())
    }
    
    func testCanAccessDeviceDataGDPRUndefined() {
        let userConsentManager = UserConsentDataManager.shared
        
        // deviceAccessConsent undefined -> YES
        XCTAssertTrue(userConsentManager.isAllowedAccessDeviceData())
        
        // deviceAccessConsent 0 -> NO
        self.setPurposeConsentsString(val: purposeConsentsString0)
        XCTAssertFalse(userConsentManager.isAllowedAccessDeviceData())
        
        // deviceAccessConsent 1 -> YES
        self.setPurposeConsentsString(val: purposeConsentsString1)
        XCTAssertTrue(userConsentManager.isAllowedAccessDeviceData())
    }
    
    // MARK: - PurposeConsents
    func testPurposeConsentsPB() throws {
        //given
        let purposeConsents = "test PurposeConsents PB"
        UserConsentDataManager.shared.purposeConsents = purposeConsents

        //when
        let result = UserConsentDataManager.shared.purposeConsents

        //then
        XCTAssertEqual(purposeConsents, result)
    }

    func testPurposeConsentsUndefined() throws {
        //given
        UserConsentDataManager.shared.purposeConsents = nil
        UserDefaults.standard.set(nil, forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents)

        //when
        let purposeConsents = UserConsentDataManager.shared.purposeConsents

        //then
        XCTAssertEqual(nil, purposeConsents)
    }

    func testPurposeConsentsTCFv2() throws {
        //given
        let purposeConsents = "test PurposeConsents TCFv2"
        UserDefaults.standard.set(purposeConsents, forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents)

        //when
        let result = UserConsentDataManager.shared.purposeConsents

        //then
        XCTAssertEqual(purposeConsents, result)
    }

    func testGetDeviceAccessConsent() throws {
        //given
        UserConsentDataManager.shared.purposeConsents = "100000000000000000000000"

        //when
        let deviceAccessConsent = UserConsentDataManager.shared.getDeviceAccessConsent()

        //then
        XCTAssertEqual(true, deviceAccessConsent)
    }

    func testGetPurposeConsent() throws {
        //given
        UserConsentDataManager.shared.purposeConsents = "101000000000000000000000"

        //when
        let purpose1 = UserConsentDataManager.shared.getPurposeConsent(index: 0)
        let purpose2 = UserConsentDataManager.shared.getPurposeConsent(index: 1)
        let purpose3 = UserConsentDataManager.shared.getPurposeConsent(index: 2)

        //then
        XCTAssertTrue(purpose1!)
        XCTAssertFalse(purpose2!)
        XCTAssertTrue(purpose3!)
    }
    
    func testGetPurposeConsentEmpty() throws {
        //given
        UserConsentDataManager.shared.purposeConsents = ""

        //when
        let purpose1 = UserConsentDataManager.shared.getPurposeConsent(index: 0)

        //then
        XCTAssertNil(purpose1)
    }
    
    // MARK: Helpers
    func setSubjectToGDPR(tcf: TCFEdition = TCF.v2, string: String) {
        UserDefaults.standard.set(string, forKey: tcf.subjectToGDPRKey)
    }
    
    func setSubjectToGDPR(tcf: TCFEdition = TCF.v2, int: Int) {
        UserDefaults.standard.set(int, forKey: tcf.subjectToGDPRKey)
    }
    
    func setSubjectToGDPR(tcf: TCFEdition = TCF.v2, bool: Bool) {
        UserDefaults.standard.set(bool, forKey: tcf.subjectToGDPRKey)
    }
    
    func setGDPRConsentString(tcf: TCFEdition = TCF.v2, val: String) {
        UserDefaults.standard.set(val, forKey: tcf.consentStringKey)
    }
    
    func setGDPRPurposeConsentsString(tcf: TCFEdition = TCF.v2, val: String) {
        UserDefaults.standard.set(val, forKey: tcf.purposeConsentsStringKey)
    }
    
    func setPurposeConsentsString(val: String?) {
        UserDefaults.standard.set(val, forKey: TCF.v2.purposeConsentsStringKey)
    }
        
    func assertExpectedConsent(subjectToGDPR: Bool?, consentString: String?, file: StaticString = #file, line: UInt = #line) {
        let userConsentManager = UserConsentDataManager.shared
        
        XCTAssertEqual(userConsentManager.subjectToGDPR, subjectToGDPR, file: file, line: line)
        XCTAssertEqual(userConsentManager.gdprConsentString, consentString, file: file, line: line)
    }
    
    func assertPurposeConsentsString(_ purposeConsentsString: String?) {
        let userConsentManager = UserConsentDataManager.shared
        XCTAssertEqual(userConsentManager.purposeConsents, purposeConsentsString)
    }

}
