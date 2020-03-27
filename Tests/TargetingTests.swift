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
import CoreLocation
@testable import PrebidMobile

class TargetingTests: XCTestCase {

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testYOB() {
        XCTAssertNoThrow(try Targeting.shared.setYearOfBirth(yob: 1985))
        let value = Targeting.shared.yearOfBirth
        XCTAssertTrue(value == 1985)

    }

    func testInvalidYOB() {
        XCTAssertThrowsError(try Targeting.shared.setYearOfBirth(yob: -1))

        XCTAssertThrowsError(try Targeting.shared.setYearOfBirth(yob: 999))

        XCTAssertThrowsError(try Targeting.shared.setYearOfBirth(yob: 10000))

    }

    func testSetGenderTargeting() {

        Targeting.shared.gender = .female
        XCTAssertEqual(Gender.female, Targeting.shared.gender)
        Targeting.shared.gender = .male
        XCTAssertEqual(Gender.male, Targeting.shared.gender)
        Targeting.shared.gender = .unknown
        XCTAssertEqual(Gender.unknown, Targeting.shared.gender)
    }

    func testSetLocationTargeting() {

        let location = CLLocation(latitude: CLLocationDegrees(100.0), longitude: CLLocationDegrees(100.0))
        Targeting.shared.location = location
        Targeting.shared.locationPrecision = 2
        XCTAssertEqual(location, Targeting.shared.location)
        XCTAssertEqual(2, Targeting.shared.locationPrecision)
    }

    //MARK: - COPPA
    func testSubjectToCOPPA() {
        //given
        let subjectToCOPPA = true;
        Targeting.shared.subjectToCOPPA = subjectToCOPPA;
        
        defer {
            Targeting.shared.subjectToCOPPA = false
        }
        
        //when
        let result = Targeting.shared.subjectToCOPPA;

        //then
        XCTAssertEqual(subjectToCOPPA, result);
        
    }
    
    //MARK: - GDPR Subject
    func testGdprSubjectPB() {
        //given
        Targeting.shared.subjectToGDPR = true
        defer {
            Targeting.shared.subjectToGDPR = nil
        }
        
        //when
        let gdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(true, gdprSubject)
    }
    
    func testGdprSubjectUndefined() {
        //given
        Targeting.shared.subjectToGDPR = nil
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_SubjectToGDPR)

        //when
        let gdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(nil, gdprSubject)
    }

    func testGdprSubjectTCFv1() {
        //given
        UserDefaults.standard.set("1", forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        }
        
        //when
        let gdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(true, gdprSubject)
    }

    func testGdprSubjectTCFv2() {
        //given
        UserDefaults.standard.set(1, forKey: StorageUtils.IABTCF_SubjectToGDPR)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_SubjectToGDPR)
        }
        
        //when
        let iabGdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(true, iabGdprSubject)
    }
    
    //MARK: - GDPR Consent
    func testGdprConsentPB() {
        //given
        Targeting.shared.gdprConsentString = "testconsent PB"
        defer {
            Targeting.shared.gdprConsentString = nil
        }
        
        //when
        let gdprConsent = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual("testconsent PB", gdprConsent)
    }
    
    func testGdprConsentUndefined() {
        //given
        Targeting.shared.gdprConsentString = nil
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABConsent_ConsentStringKey)
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_ConsentString)

        //when
        let gdprConsent = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(nil, gdprConsent)
    }

    func testGdprConsentTCFv1() {
        //given
        UserDefaults.standard.set("testconsent TCFv1", forKey: StorageUtils.IABConsent_ConsentStringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_ConsentStringKey)
        }
        
        //when
        let gdprConsent = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual("testconsent TCFv1", gdprConsent)
    }

    func testGdprConsentTCFv2() {
        //given
        UserDefaults.standard.set("testconsent TCFv2", forKey: StorageUtils.IABTCF_ConsentString)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_ConsentString)
        }

        //when
        let gdprConsent = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual("testconsent TCFv2", gdprConsent)
    }

    //MARK: - PurposeConsents
    func testPurposeConsentsPB() throws {
        //given
        Targeting.shared.purposeConsents = "test PurposeConsents PB"

        defer {
            Targeting.shared.purposeConsents = nil
        }

        //when
        let purposeConsents = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual("test PurposeConsents PB", purposeConsents)
    }

    func testPurposeConsentsUndefined() throws {
        //given
        Targeting.shared.purposeConsents = nil
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_PurposeConsents)

        //when
        let purposeConsents = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual(nil, purposeConsents)
    }

    func testPurposeConsentsTCFv2() throws {
        //given
        UserDefaults.standard.set("test PurposeConsents TCFv2", forKey: StorageUtils.IABTCF_PurposeConsents)

        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_PurposeConsents)
        }

        //when
        let purposeConsents = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual("test PurposeConsents TCFv2", purposeConsents)
    }

    func testGetDeviceAccessConsent() throws {
        //given
        Targeting.shared.purposeConsents = "100000000000000000000000"

        defer {
            Targeting.shared.purposeConsents = nil
        }

        //when
        let deviceAccessConsent = Targeting.shared.getDeviceAccessConsent()

        //then
        XCTAssertEqual(true, deviceAccessConsent)
    }

    func testGetPurposeConsent() throws {
        //given
        Targeting.shared.purposeConsents = "101000000000000000000000"

        defer {
            Targeting.shared.purposeConsents = nil
        }

        //when
        let purpose1 = Targeting.shared.getPurposeConsent(index: 0)
        let purpose2 = Targeting.shared.getPurposeConsent(index: 1)
        let purpose3 = Targeting.shared.getPurposeConsent(index: 2)

        //then
        XCTAssertTrue(purpose1!)
        XCTAssertFalse(purpose2!)
        XCTAssertTrue(purpose3!)
    }

    func testItuneIDTargeting() {
        Targeting.shared.itunesID = "54673893"
        let testItuneID = Targeting.shared.itunesID

        XCTAssertTrue((testItuneID == "54673893"))
    }

    func testStoreURL() {

        Targeting.shared.storeURL = "https://itunes.apple.com/app/id123456789"
        let storeURL = Targeting.shared.storeURL

        XCTAssertTrue((storeURL == "https://itunes.apple.com/app/id123456789"))
    }

    func testDomain() {

        Targeting.shared.domain = "appdomain.com"
        let domain = Targeting.shared.domain

        XCTAssertTrue((domain == "appdomain.com"))
    }

    func testContextData() {
        Targeting.shared.addContextData(key: "key1", value: "value10")
        let dictionary = Targeting.shared.getContextDataDictionary()

        XCTAssert(dictionary.count == 1)

        guard let set = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }

        XCTAssert(set.count == 1)
        XCTAssert(set.contains("value10"))
    }

    func testUserData() {
        Targeting.shared.addUserData(key: "key1", value: "value10")
        let dictionary = Targeting.shared.getUserDataDictionary()

        XCTAssert(dictionary.count == 1)

        guard let set = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }

        XCTAssert(set.count == 1)
        XCTAssert(set.contains("value10"))
    }

    func testContextKeyword() {
        Targeting.shared.addContextKeyword("value10")
        let set = Targeting.shared.getContextKeywordsSet()

        XCTAssert(set.count == 1)
        XCTAssert(set.contains("value10"))
    }

    func testUserKeyword() {
        Targeting.shared.addUserKeyword("value10")
        let set = Targeting.shared.getUserKeywordsSet()

        XCTAssert(set.count == 1)
        XCTAssert(set.contains("value10"))
    }

}
