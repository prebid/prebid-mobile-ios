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
        UtilitiesForTesting.resetTargeting(.shared)
    }

    override func tearDown() {
        UtilitiesForTesting.resetTargeting(.shared)
        Targeting.shared.forceSdkToChooseWinner = true
    }

    func testDomain() {
        //given
        let domain = "appdomain.com"
        
        //when
        Targeting.shared.domain = domain
        let result = Targeting.shared.domain

        //then
        XCTAssertEqual(domain, result)
    }

    func testItunesID() {
        //given
        let itunesID = "54673893"
        
        //when
        Targeting.shared.itunesID = itunesID
        let result = Targeting.shared.itunesID

        //then
        XCTAssertEqual(itunesID, result)
    }
    
    func testOmidPartnerNameAndVersion() {
        //given
        let partnerName = "PartnerName"
        let partnerVersion = "1.0"
        
        //when
        Targeting.shared.omidPartnerName = partnerName
        Targeting.shared.omidPartnerVersion = partnerVersion
        
        //then
        XCTAssertEqual(partnerName, Targeting.shared.omidPartnerName)
        XCTAssertEqual(partnerVersion, Targeting.shared.omidPartnerVersion)
    }

    func testLocation() {
        //given
        let location = CLLocation(latitude: CLLocationDegrees(100.0), longitude: CLLocationDegrees(100.0))
        
        //when
        Targeting.shared.location = location
        
        //then
        XCTAssertEqual(location, Targeting.shared.location)
    }
    
    func testforceSdkToChooseWinner() {
        //given
        let forceSdkToChooseWinner = false
        
        //when
        Targeting.shared.forceSdkToChooseWinner = forceSdkToChooseWinner
        
        //then
        XCTAssertEqual(forceSdkToChooseWinner, Targeting.shared.forceSdkToChooseWinner)
    }

    //MARK: - COPPA
    func testSubjectToCOPPA() {
        //given
        let subjectToCOPPA = true;
        Targeting.shared.subjectToCOPPA = subjectToCOPPA;
        
        //when
        let result = Targeting.shared.subjectToCOPPA;

        //then
        XCTAssertEqual(subjectToCOPPA, result);
    }
    
    //MARK: - GDPR Subject
    func testSubjectToGDPR_PB() {
        //given
        let subjectToGDPR = true
        
        //when
        Targeting.shared.subjectToGDPR = subjectToGDPR
        let result = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(subjectToGDPR, result)
    }
    
    func testSubjectToGDPR_Undefined() {
        //given
        Targeting.shared.subjectToGDPR = nil
        UserDefaults.standard.set(nil, forKey: UserConsentDataManager.shared.IABTCF_SubjectToGDPR)

        //when
        let gdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(nil, gdprSubject)
    }

    func testSubjectToGDPR_TCFv2() {
        //given
        UserDefaults.standard.set(1, forKey: UserConsentDataManager.shared.IABTCF_SubjectToGDPR)
        
        //when
        let iabGdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(true, iabGdprSubject)
    }
    
    //MARK: - GDPR Consent
    func testGdprConsentStringPB() {
        //given
        let gdprConsentString = "testconsent PB"
        Targeting.shared.gdprConsentString = gdprConsentString
        
        //when
        let result = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(gdprConsentString, result)
    }
    
    func testGdprConsentStringUndefined() {
        //given
        Targeting.shared.gdprConsentString = nil
        UserDefaults.standard.set(nil, forKey: UserConsentDataManager.shared.IABTCF_ConsentString)

        //when
        let gdprConsent = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(nil, gdprConsent)
    }

    func testGdprConsentStringTCFv2() {
        //given
        let gdprConsentString = "testconsent TCFv2"
        UserDefaults.standard.set(gdprConsentString, forKey: UserConsentDataManager.shared.IABTCF_ConsentString)

        //when
        let result = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(gdprConsentString, result)
    }

    //MARK: - PurposeConsents
    
    func testPurposeConsentsPB() throws {
        //given
        let purposeConsents = "test PurposeConsents PB"
        Targeting.shared.purposeConsents = purposeConsents

        //when
        let result = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual(purposeConsents, result)
    }

    func testPurposeConsentsUndefined() throws {
        //given
        Targeting.shared.purposeConsents = nil
        UserDefaults.standard.set(nil, forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents)

        //when
        let purposeConsents = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual(nil, purposeConsents)
    }

    func testPurposeConsentsTCFv2() throws {
        //given
        let purposeConsents = "test PurposeConsents TCFv2"
        UserDefaults.standard.set(purposeConsents, forKey: UserConsentDataManager.shared.IABTCF_PurposeConsents)

        //when
        let result = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual(purposeConsents, result)
    }

    func testGetDeviceAccessConsent() throws {
        //given
        Targeting.shared.purposeConsents = "100000000000000000000000"

        //when
        let deviceAccessConsent = Targeting.shared.getDeviceAccessConsent()

        //then
        XCTAssertEqual(true, deviceAccessConsent)
    }

    func testGetPurposeConsent() throws {
        //given
        Targeting.shared.purposeConsents = "101000000000000000000000"

        //when
        let purpose1 = Targeting.shared.getPurposeConsent(index: 0)
        let purpose2 = Targeting.shared.getPurposeConsent(index: 1)
        let purpose3 = Targeting.shared.getPurposeConsent(index: 2)

        //then
        XCTAssertTrue(purpose1!)
        XCTAssertFalse(purpose2!)
        XCTAssertTrue(purpose3!)
    }
    
    func testGetPurposeConsentEmpty() throws {
        //given
        Targeting.shared.purposeConsents = ""

        //when
        let purpose1 = Targeting.shared.getPurposeConsent(index: 0)

        //then
        XCTAssertNil(purpose1)
    }

    // MARK: - access control list (ext.prebid.data)
    func testAddBidderToAccessControlList() {
        //given
        let bidderName = "test-bidder"
        
        //when
        Targeting.shared.addBidderToAccessControlList(bidderName)
        let set = Targeting.shared.getAccessControlList()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(bidderName))
    }
    
    func testRemoveBidderFromAccessControlList() {
        //given
        let bidderName = "test-bidder"
        Targeting.shared.addBidderToAccessControlList(bidderName)
        
        //when
        Targeting.shared.removeBidderFromAccessControlList(bidderName)
        let set = Targeting.shared.getAccessControlList()

        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearAccessControlList() {
        //given
        let bidderName = "test-bidder"
        Targeting.shared.addBidderToAccessControlList(bidderName)
        
        //when
        Targeting.shared.clearAccessControlList()
        let set = Targeting.shared.getAccessControlList()

        //then
        XCTAssertEqual(0, set.count)
    }
    
    // MARK: - global ext data aka inventory data (app.ext.data)
    
    func testAddExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        
        //when
        Targeting.shared.addAppExtData(key: key1, value: value1)
        let dictionary = Targeting.shared.getAppExtData()
        let set = dictionary[key1]

        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertEqual(1, set?.count)
        XCTAssert((set?.contains(value1))!)
    }

    func testUpdateExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let inputSet: Set = [value1]
        
        //when
        Targeting.shared.updateAppExtData(key: key1, value: inputSet)
        let dictionary = Targeting.shared.getAppExtData()
        let set = dictionary[key1]

        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertEqual(1, set?.count)
        XCTAssert((set?.contains(value1))!)
    }
    
    func testRemoveExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        Targeting.shared.addAppExtData(key: key1, value: value1)
        
        //when
        Targeting.shared.removeAppExtData(for: key1)
        let dictionary = Targeting.shared.getAppExtData()

        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        Targeting.shared.addAppExtData(key: key1, value: value1)
        
        //when
        Targeting.shared.clearAppExtData()
        let dictionary = Targeting.shared.getAppExtData()

        //then
        XCTAssertEqual(0, dictionary.count)
    }
        
    // MARK: - Global app keywords (app.keywords)
    
    func testAddExtKeyword() {
        //given
        let value1 = "value1"
        
        //when
        Targeting.shared.addAppKeyword(value1)
        let set = Targeting.shared.getAppKeywords()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(value1))
    }
    
    func testAddExtKeywords() {
        //given
        let value1 = "value1"
        let inputSet: Set = [value1]
        
        //when
        Targeting.shared.addAppKeywords(inputSet)
        let set = Targeting.shared.getAppKeywords()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(value1))
    }
    
    func testRemoveExtKeyword() {
        //given
        let value1 = "value1"
        Targeting.shared.addAppKeyword(value1)
        
        //when
        Targeting.shared.removeAppKeyword(value1)
        let set = Targeting.shared.getAppKeywords()

        //then
        XCTAssertEqual(0, set.count)
    }

    func testClearExtKeywords() {
        //given
        let value1 = "value1"
        Targeting.shared.addAppKeyword(value1)
        
        //when
        Targeting.shared.clearAppKeywords()
        let set = Targeting.shared.getAppKeywords()

        //then
        XCTAssertEqual(0, set.count)
    }

    // MARK: - global user keywords (user.keywords)
    
    func testAddUserKeyword() {
        //given
        let value1 = "value1"
        
        //when
        Targeting.shared.addUserKeyword(value1)
        let set = Targeting.shared.getUserKeywords()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(value1))
    }
    
    func testAddUserKeywords() {
        //given
        let value1 = "value1"
        let inputSet: Set = [value1]
        
        //when
        Targeting.shared.addUserKeywords(inputSet)
        let set = Targeting.shared.getUserKeywords()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(value1))
    }
    
    func testRemoveUserKeyword() {
        //given
        let value1 = "value1"
        Targeting.shared.addUserKeyword(value1)
        
        //when
        Targeting.shared.removeUserKeyword(value1)
        let set = Targeting.shared.getUserKeywords()

        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearUserKeywords() {
        //given
        let value1 = "value1"
        Targeting.shared.addUserKeyword(value1)
        
        //when
        Targeting.shared.clearUserKeywords()
        let set = Targeting.shared.getUserKeywords()

        //then
        XCTAssertEqual(0, set.count)
    }

    func testShared() {
        UtilitiesForTesting.checkInitialValues(.shared)
    }
    
    func testUserExt() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.userExt)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")

        //Set
        let userExt = ["consent": "dummyConsentString"]
        Targeting.userExt = userExt
        XCTAssertEqual(Targeting.userExt?.count, 1)
    }
    
    func testPublisherName() {
        //Init
        //Note: on init, and it never doesn't send a value via an ad request params.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.publisherName)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        let publisherName = "abc123"
        Targeting.publisherName = publisherName
        XCTAssertEqual(Targeting.publisherName, publisherName)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.publisherName = nil
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
    }
    
    func testStoreURL() {
        
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.storeURL)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        let storeUrl = "foo.com"
        Targeting.storeURL = storeUrl
        XCTAssertEqual(Targeting.storeURL, storeUrl)
        XCTAssert(Targeting.parameterDictionary == ["url":storeUrl], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.storeURL = nil
        XCTAssertNil(Targeting.storeURL)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
    }

    func testLatitudeLongitude() {
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.coordinate)
        
        let lat = 123.0
        let lon = 456.0
        Targeting.setLatitude(lat, longitude: lon)
        XCTAssertEqual(Targeting.coordinate?.mkCoordinateValue.latitude, lat)
        XCTAssertEqual(Targeting.coordinate?.mkCoordinateValue.longitude, lon)
    }
    
    //MARK: - Custom Params
    func testAddParam() {
        
        //Init
        let Targeting = Targeting.shared
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        Targeting.addParam("value", withName: "name")
        XCTAssert(Targeting.parameterDictionary == ["name":"value"], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.addParam("", withName: "name")
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
    }
    
    func testKeywords() {
        //Init
        let Targeting = Targeting.shared
        XCTAssert(Targeting.getUserKeywords().isEmpty)
        
        let keywords1 = "Key"
        let keywords2 = "words"
        Targeting.addUserKeyword(keywords1)
        Targeting.addUserKeyword(keywords2)
        XCTAssertTrue(Targeting.getUserKeywords().allSatisfy([keywords1, keywords2].contains))
    }
}
