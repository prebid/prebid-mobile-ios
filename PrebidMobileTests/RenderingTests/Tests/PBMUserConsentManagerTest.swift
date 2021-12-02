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
    var cmpSDKIDKey: String? { get }
    var subjectToGDPRKey: String { get }
    var consentStringKey: String { get }
    var purposeConsentsStringKey : String? { get }
}

class PBMUserConsentDataManagerTest: XCTestCase {
    
    var userDefaults: UserDefaults!
    
    enum TCF {
        static let v1 = TCF1()
        static let v2 = TCF2()
        
        struct TCF1: TCFEdition {
            let cmpSDKIDKey: String? = nil
            let subjectToGDPRKey = "IABConsent_SubjectToGDPR"
            let consentStringKey = "IABConsent_ConsentString"
            let purposeConsentsStringKey: String? = nil
        }
        
        struct TCF2: TCFEdition {
            let cmpSDKIDKey: String? = "IABTCF_CmpSdkID"
            let subjectToGDPRKey = "IABTCF_gdprApplies"
            let consentStringKey = "IABTCF_TCString"
            let purposeConsentsStringKey: String? = "IABTCF_PurposeConsents"
        }
    }
    
    let consentString1 = "consentstring1"
    let consentString2 = "consentstring2"
    
    let purposeConsentsString0 = "00000000"
    let purposeConsentsString1 = "11111111"
    
    let usPrivacyStringKey = "IABUSPrivacy_String"
    
    let usPrivacyStringNotASubject = "1---"
    let usPrivacyStringNoOptOut = "1YNN"
    
    override func setUp() {
        super.setUp()
        self.userDefaults = UserDefaults()
    }
    
    override func tearDown() {
        self.userDefaults.removeObject(forKey: TCF.v1.subjectToGDPRKey)
        self.userDefaults.removeObject(forKey: TCF.v1.consentStringKey)
        
        self.userDefaults.removeObject(forKey: TCF.v2.cmpSDKIDKey!)
        self.userDefaults.removeObject(forKey: TCF.v2.subjectToGDPRKey)
        self.userDefaults.removeObject(forKey: TCF.v2.consentStringKey)
        self.userDefaults.removeObject(forKey: TCF.v2.purposeConsentsStringKey!)
        
        self.userDefaults.removeObject(forKey: usPrivacyStringKey)
        super.tearDown()
    }
    
    // MARK: IABConsent_SubjectToGDPR values
    func testIABConsent_NilSubjectToGDPR() {
        self.assertExpectedConsent(subjectToGDPR: .unknown, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withString() {
        self.setSubjectToGDPR(string: "1")
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withString() {
        self.setSubjectToGDPR(string: "0")
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withStringBool() {
        self.setSubjectToGDPR(string: "YES")
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withStringBool() {
        self.setSubjectToGDPR(string: "NO")
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withInt() {
        self.setSubjectToGDPR(int: 1)
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withInt() {
        self.setSubjectToGDPR(int: 0)
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: nil)
    }
    
    func testIABConsent_IsSubjectToGDPR_withBool() {
        self.setSubjectToGDPR(bool: true)
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_withBool() {
        self.setSubjectToGDPR(bool: false)
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: nil)
    }
    
    // MARK: IABConsent_ConsentString values
    func testIABConsent_IsSubjectToGDPR_MissingConsentString() {
        self.setSubjectToGDPR(string: "1")
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: nil)
    }
    
    func testIABConsent_IsNotSubjectToGDPR_IncludesConsentString() {
        self.setSubjectToGDPR(string: "0")
        self.setGDPRConsentString(val: self.consentString1)
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: self.consentString1)
    }
    
    func testIABConsent_IsSubjectToGDPR_IncludesConsentString() {
        self.setSubjectToGDPR(string: "1")
        self.setGDPRConsentString(val: self.consentString1)
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: self.consentString1)
    }
    
    // MARK: IABConsent_ConsentString values
    func testUSPrivacy_Unset() {
        setAndLoadPrivacyString(usPrivacyString: nil)
    }
    
    func testUSPrivacy_NotASubject() {
        setAndLoadPrivacyString(usPrivacyString: usPrivacyStringNotASubject)
    }
    
    func testUSPrivacy_NoOptOut() {
        setAndLoadPrivacyString(usPrivacyString: usPrivacyStringNoOptOut)
    }
    
    func setAndLoadPrivacyString(usPrivacyString: String?, file: StaticString = #file, line: UInt = #line) {
        self.setUSPrivacyString(val: usPrivacyString)
        assertUSPrivacyString(usPrivacyString)
    }
    
    // MARK: TCFv2
    func testTCFv2_Empty() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        assertExpectedConsent(subjectToGDPR: .unknown, consentString: nil)
    }
    
    func testTCFv2_EmptyOverV1() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        setSubjectToGDPR(tcf: TCF.v1, bool: true)
        setGDPRConsentString(tcf: TCF.v1, val: consentString1)
        assertExpectedConsent(subjectToGDPR: .unknown, consentString: nil)
    }
    
    func testTCFv2_IsSubject() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        setSubjectToGDPR(tcf: TCF.v2, bool: true)
        assertExpectedConsent(subjectToGDPR: .yes, consentString: nil)
    }
    
    func testTCFv2_ConsentString() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        setSubjectToGDPR(tcf: TCF.v2, bool: true)
        setGDPRConsentString(tcf: TCF.v2, val: consentString1)
        assertExpectedConsent(subjectToGDPR: .yes, consentString: consentString1)
    }
    
    func testTCFv2_PurposeConsentsString() {
        self.setPurposeConsentsString(val: purposeConsentsString1)
        assertPurposeConsentsString(purposeConsentsString1)
    }
    
    // MARK: User defaults changes
    func testIABConsent_ConsentString_Changed() {
        self.setSubjectToGDPR(string: "1")
        self.setGDPRConsentString(val: self.consentString1)
        
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: self.consentString1)
        
        self.setGDPRConsentString(val: self.consentString2)
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: self.consentString2)
    }
    
    func testIABConsent_isSubjectToGDPR_Changed_TCF1() {
        self.setSubjectToGDPR(string: "1")
        self.setGDPRConsentString(val: self.consentString1)
        
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: consentString1)
        
        self.setSubjectToGDPR(string: "0")
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: self.consentString1)
    }
    
    func testIABConsent_isSubjectToGDPR_Changed_TCF2() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        self.setSubjectToGDPR(tcf: TCF.v2, string: "1")
        self.setGDPRConsentString(tcf: TCF.v2, val: self.consentString1)
        
        self.assertExpectedConsent(subjectToGDPR: .yes, consentString: consentString1)
        
        self.setSubjectToGDPR(tcf: TCF.v2, string: "0")
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertExpectedConsent(subjectToGDPR: .no, consentString: self.consentString1)
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
    
    func testIABConsent_usPrivacyString_Changed() {
        self.setUSPrivacyString(val: usPrivacyStringNotASubject)
        self.assertUSPrivacyString(usPrivacyStringNotASubject)
        
        self.setUSPrivacyString(val: usPrivacyStringNoOptOut)
        
        let exp = self.expectation(description: "notificationwaiter")
        exp.isInverted = true
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.assertUSPrivacyString(usPrivacyStringNoOptOut)
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
        setCMPSDKID(tcf: TCF.v2, val: 42)
        self.setSubjectToGDPR(tcf: TCF.v2, bool: false)
        
        let userConsentManager = PBMUserConsentDataManager(userDefaults: self.userDefaults)
        let resolver = PBMUserConsentResolver(consentDataManager: userConsentManager)
        
        // deviceAccessConsent undefined -> YES
        XCTAssertTrue(resolver.canAccessDeviceData)
        
        // deviceAccessConsent 0 -> NO
        self.setPurposeConsentsString(val: purposeConsentsString0)
        XCTAssertFalse(resolver.canAccessDeviceData)
        
        // deviceAccessConsent 1 -> YES
        self.setPurposeConsentsString(val: purposeConsentsString1)
        XCTAssertTrue(resolver.canAccessDeviceData)
    }
    
    func testCanAccessDeviceDataGDPRTrue() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        self.setSubjectToGDPR(tcf: TCF.v2, bool: true)
        
        let userConsentManager = PBMUserConsentDataManager(userDefaults: self.userDefaults)
        let resolver = PBMUserConsentResolver(consentDataManager: userConsentManager)
        
        // deviceAccessConsent undefined -> NO
        XCTAssertFalse(resolver.canAccessDeviceData)
        
        // deviceAccessConsent 0 -> NO
        self.setPurposeConsentsString(val: purposeConsentsString0)
        XCTAssertFalse(resolver.canAccessDeviceData)
        
        // deviceAccessConsent 1 -> YES
        self.setPurposeConsentsString(val: purposeConsentsString1)
        XCTAssertTrue(resolver.canAccessDeviceData)
    }
    
    func testCanAccessDeviceDataGDPRUndefined() {
        setCMPSDKID(tcf: TCF.v2, val: 42)
        
        let userConsentManager = PBMUserConsentDataManager(userDefaults: self.userDefaults)
        let resolver = PBMUserConsentResolver(consentDataManager: userConsentManager)
        
        // deviceAccessConsent undefined -> YES
        XCTAssertTrue(resolver.canAccessDeviceData)
        
        // deviceAccessConsent 0 -> NO
        self.setPurposeConsentsString(val: purposeConsentsString0)
        XCTAssertFalse(resolver.canAccessDeviceData)
        
        // deviceAccessConsent 1 -> YES
        self.setPurposeConsentsString(val: purposeConsentsString1)
        XCTAssertTrue(resolver.canAccessDeviceData)
    }
    
    // MARK: Helpers
    func setSubjectToGDPR(tcf: TCFEdition = TCF.v1, string: String) {
        self.userDefaults.set(string, forKey: tcf.subjectToGDPRKey)
    }
    
    func setSubjectToGDPR(tcf: TCFEdition = TCF.v1, int: Int) {
        self.userDefaults.set(int, forKey: tcf.subjectToGDPRKey)
    }
    
    func setSubjectToGDPR(tcf: TCFEdition = TCF.v1, bool: Bool) {
        self.userDefaults.set(bool, forKey: tcf.subjectToGDPRKey)
    }
    
    func setGDPRConsentString(tcf: TCFEdition = TCF.v1, val: String) {
        self.userDefaults.set(val, forKey: tcf.consentStringKey)
    }
    
    func setGDPRPurposeConsentsString(tcf: TCFEdition = TCF.v2, val: String) {
        if let key = tcf.purposeConsentsStringKey {
            self.userDefaults.set(val, forKey: key)
        }
    }
    
    func setCMPSDKID(tcf: TCFEdition, val: Int?) {
        if let key = tcf.cmpSDKIDKey {
            self.userDefaults.set(val, forKey: key)
        }
    }
    
    func setUSPrivacyString(val: String?) {
        self.userDefaults.set(val, forKey: usPrivacyStringKey)
    }
    
    func setPurposeConsentsString(val: String?) {
        self.userDefaults.set(val, forKey: TCF.v2.purposeConsentsStringKey!)
    }
    
    func assertExpectedConsent(subjectToGDPR: PBMIABConsentSubjectToGDPR, consentString: String?, file: StaticString = #file, line: UInt = #line) {
        let userConsentManager = PBMUserConsentDataManager(userDefaults: self.userDefaults)
        let resolver = PBMUserConsentResolver(consentDataManager: userConsentManager)
        let gdrpNumberValue: NSNumber? = {
            switch subjectToGDPR {
            case .yes: return NSNumber(value: 1)
            case .no: return NSNumber(value: 0)
            case .unknown: return nil
            }
        }()
        XCTAssertEqual(resolver.subjectToGDPR, gdrpNumberValue, file: file, line: line)
        XCTAssertEqual(resolver.gdprConsentString, consentString, file: file, line: line)
    }
    
    func assertUSPrivacyString(_ usPrivacyString: String?, file: StaticString = #file, line: UInt = #line) {
        let userConsentManager = PBMUserConsentDataManager(userDefaults: self.userDefaults)
        XCTAssertEqual(userConsentManager.usPrivacyString, usPrivacyString)
    }
    
    func assertPurposeConsentsString(_ purposeConsentsString: String?) {
        let userConsentManager = PBMUserConsentDataManager(userDefaults: self.userDefaults)
        XCTAssertEqual(userConsentManager.tcf2purposeConsentsString, purposeConsentsString)
    }
}
