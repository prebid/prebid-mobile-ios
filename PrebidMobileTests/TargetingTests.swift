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
        Targeting.shared.subjectToCOPPA = false
        Targeting.shared.subjectToGDPR = nil
        Targeting.shared.gdprConsentString = nil
        Targeting.shared.purposeConsents = nil
        
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_SubjectToGDPR)
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABConsent_ConsentStringKey)
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_ConsentString)
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABTCF_PurposeConsents)
        
        Targeting.shared.clearContextData()
        Targeting.shared.clearUserData()
        Targeting.shared.clearYearOfBirth()
        Targeting.shared.clearAccessControlList()
        Targeting.shared.clearContextKeywords()
        Targeting.shared.clearUserKeywords()
    }

    func testStoreURL() {
        //given
        let storeURL = "https://itunes.apple.com/app/id123456789"
        
        //when
        Targeting.shared.storeURL = storeURL
        let result = Targeting.shared.storeURL

        //then
        XCTAssertEqual(storeURL, result)
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
    
    func testGender() {
        //given
        let female = Gender.female
        
        //when
        Targeting.shared.gender = female
        
        //then
        XCTAssertEqual(female, Targeting.shared.gender)
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
        Targeting.shared.locationPrecision = 2
        
        //then
        XCTAssertEqual(location, Targeting.shared.location)
        XCTAssertEqual(2, Targeting.shared.locationPrecision)
    }
    
    func testLocationPrecision() {
        //given
        let locationPrecision = 2
        
        //when
        Targeting.shared.locationPrecision = locationPrecision
        
        //then
        XCTAssertEqual(locationPrecision, Targeting.shared.locationPrecision)
    }
    
    // MARK: - Year Of Birth
    func testYearOfBirth() {
        //given
        let yearOfBirth = 1985
        Targeting.shared.setYearOfBirth(yob: yearOfBirth)
        //when
        XCTAssertTrue(Targeting.shared.yearOfBirth != 0)
        let result = Targeting.shared.yearOfBirth
        
        //then
        XCTAssertEqual(yearOfBirth, result)
    }

    func testYearOfBirthInvalid() {
        Targeting.shared.setYearOfBirth(yob: -1)
        XCTAssertTrue(Targeting.shared.yearOfBirth == 0)
        Targeting.shared.setYearOfBirth(yob: 999)
        XCTAssertTrue(Targeting.shared.yearOfBirth == 0)
        Targeting.shared.setYearOfBirth(yob: 10000)
        XCTAssertTrue(Targeting.shared.yearOfBirth == 0)
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
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_SubjectToGDPR)

        //when
        let gdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(nil, gdprSubject)
    }

    func testSubjectToGDPR_TCFv1() {
        //given
        UserDefaults.standard.set("1", forKey: StorageUtils.IABConsent_SubjectToGDPRKey)
        
        //when
        let gdprSubject = Targeting.shared.subjectToGDPR

        //then
        XCTAssertEqual(true, gdprSubject)
    }

    func testSubjectToGDPR_TCFv2() {
        //given
        UserDefaults.standard.set(1, forKey: StorageUtils.IABTCF_SubjectToGDPR)
        
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
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABConsent_ConsentStringKey)
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_ConsentString)

        //when
        let gdprConsent = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(nil, gdprConsent)
    }

    func testGdprConsentStringTCFv1() {
        //given
        let gdprConsentString = "testconsent TCFv1"
        UserDefaults.standard.set(gdprConsentString, forKey: StorageUtils.IABConsent_ConsentStringKey)
        
        //when
        let result = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(gdprConsentString, result)
    }

    func testGdprConsentStringTCFv2() {
        //given
        let gdprConsentString = "testconsent TCFv2"
        UserDefaults.standard.set(gdprConsentString, forKey: StorageUtils.IABTCF_ConsentString)

        //when
        let result = Targeting.shared.gdprConsentString

        //then
        XCTAssertEqual(gdprConsentString, result)
    }
    
    //MARK: - External UserIds
    func testPbExternalUserIds() {
        //given
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "netid.de", identifier: "999888777"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "criteo.com", identifier: "_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "liveramp.com", identifier: "AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "sharedid.org", identifier: "111111111111", atype: 1, ext: ["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"]))
        
        defer {
            Targeting.shared.removeStoredExternalUserIds()
        }

        //when
        let externalUserIdAdserver = Targeting.shared.fetchStoredExternalUserId("adserver.org")
        let externalUserIdNetID = Targeting.shared.fetchStoredExternalUserId("netid.de")
        let externalUserIdCriteo = Targeting.shared.fetchStoredExternalUserId("criteo.com")
        let externalUserIdLiveRamp = Targeting.shared.fetchStoredExternalUserId("liveramp.com")
        let externalUserIdSharedId = Targeting.shared.fetchStoredExternalUserId("sharedid.org")

        //then
        XCTAssertEqual("adserver.org", externalUserIdAdserver!.source)
        XCTAssertEqual("111111111111", externalUserIdAdserver!.identifier)
        XCTAssertEqual(["rtiPartner" : "TDID"], externalUserIdAdserver!.ext as! [String : String])
        
        XCTAssertEqual("netid.de", externalUserIdNetID!.source)
        XCTAssertEqual("999888777", externalUserIdNetID!.identifier)

        XCTAssertEqual("criteo.com", externalUserIdCriteo!.source)
        XCTAssertEqual("_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N", externalUserIdCriteo!.identifier)

        XCTAssertEqual("liveramp.com", externalUserIdLiveRamp!.source)
        XCTAssertEqual("AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg", externalUserIdLiveRamp!.identifier)

        XCTAssertEqual("sharedid.org", externalUserIdSharedId!.source)
        XCTAssertEqual("111111111111", externalUserIdSharedId!.identifier)
        XCTAssertEqual(1, externalUserIdSharedId!.atype)
        XCTAssertEqual(["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"], externalUserIdSharedId!.ext as! [String : String])

    }
    
    func testPbExternalUserIdsOverRiding() {
        //given
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "adserver.org", identifier: "222222222222", ext: ["rtiPartner" : "LFTD"]))
        
        defer {
            Targeting.shared.removeStoredExternalUserIds()
        }

        //when
        let externalUserIdAdserver = Targeting.shared.fetchStoredExternalUserId("adserver.org")

        //then
        XCTAssertEqual("adserver.org", externalUserIdAdserver!.source)
        XCTAssertEqual("222222222222", externalUserIdAdserver!.identifier)
        XCTAssertEqual(["rtiPartner" : "LFTD"], externalUserIdAdserver!.ext as! [String : String])


    }

    func testPbExternalUserIdsRemoveSpecificID() {
        //given
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))

        //when
        Targeting.shared.removeStoredExternalUserId("adserver.org")

        //then
        let externalUserIdAdserver = Targeting.shared.fetchStoredExternalUserId("adserver.org")
        XCTAssertNil(externalUserIdAdserver)

    }
    
    func testPbExternalUserIdsGetAllExternalUserIDs() {
        //given
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "netid.de", identifier: "999888777"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "criteo.com", identifier: "_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "liveramp.com", identifier: "AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "sharedid.org", identifier: "111111111111", atype: 1, ext: ["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"]))
        
        defer {
            Targeting.shared.removeStoredExternalUserIds()
        }

        //when
        let externalUserIdsArray = Targeting.shared.fetchStoredExternalUserIds()
        let externalUserIdAdserver = externalUserIdsArray![0]
        let externalUserIdNetID = externalUserIdsArray![1]
        let externalUserIdCriteo = externalUserIdsArray![2]
        let externalUserIdLiveRamp = externalUserIdsArray![3]
        let externalUserIdSharedId = externalUserIdsArray![4]

        //then
        XCTAssertEqual("adserver.org", externalUserIdAdserver.source)
        XCTAssertEqual("111111111111", externalUserIdAdserver.identifier)
        XCTAssertEqual(["rtiPartner" : "TDID"], externalUserIdAdserver.ext as! [String : String])
        
        XCTAssertEqual("netid.de", externalUserIdNetID.source)
        XCTAssertEqual("999888777", externalUserIdNetID.identifier)

        XCTAssertEqual("criteo.com", externalUserIdCriteo.source)
        XCTAssertEqual("_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N", externalUserIdCriteo.identifier)

        XCTAssertEqual("liveramp.com", externalUserIdLiveRamp.source)
        XCTAssertEqual("AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg", externalUserIdLiveRamp.identifier)

        XCTAssertEqual("sharedid.org", externalUserIdSharedId.source)
        XCTAssertEqual("111111111111", externalUserIdSharedId.identifier)
        XCTAssertEqual(1, externalUserIdSharedId.atype)
        XCTAssertEqual(["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"], externalUserIdSharedId.ext as! [String : String])

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
        UserDefaults.standard.set(nil, forKey: StorageUtils.IABTCF_PurposeConsents)

        //when
        let purposeConsents = Targeting.shared.purposeConsents

        //then
        XCTAssertEqual(nil, purposeConsents)
    }

    func testPurposeConsentsTCFv2() throws {
        //given
        let purposeConsents = "test PurposeConsents TCFv2"
        UserDefaults.standard.set(purposeConsents, forKey: StorageUtils.IABTCF_PurposeConsents)

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
        let bidderNameRubicon = Prebid.bidderNameRubiconProject
        
        //when
        Targeting.shared.addBidderToAccessControlList(bidderNameRubicon)
        let set = Targeting.shared.getAccessControlList()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(bidderNameRubicon))
    }
    
    func testRemoveBidderFromAccessControlList() {
        //given
        let bidderNameRubicon = Prebid.bidderNameRubiconProject
        Targeting.shared.addBidderToAccessControlList(bidderNameRubicon)
        
        //when
        Targeting.shared.removeBidderFromAccessControlList(bidderNameRubicon)
        let set = Targeting.shared.getAccessControlList()

        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearAccessControlList() {
        //given
        let bidderNameRubicon = Prebid.bidderNameRubiconProject
        Targeting.shared.addBidderToAccessControlList(bidderNameRubicon)
        
        //when
        Targeting.shared.clearAccessControlList()
        let set = Targeting.shared.getAccessControlList()

        //then
        XCTAssertEqual(0, set.count)
    }
    
    // MARK: - global context data aka inventory data (app.ext.data)
     func testAddContextData() {
         //given
         let key1 = "key1"
         let value1 = "value1"
         
         //when
         Targeting.shared.addContextData(key: key1, value: value1)
         let dictionary = Targeting.shared.getContextData()
         let set = dictionary[key1]

         //then
         XCTAssertEqual(1, dictionary.count)
         XCTAssertEqual(1, set?.count)
         XCTAssert((set?.contains(value1))!)
     }

     func testUpdateContextData() {
         //given
         let key1 = "key1"
         let value1 = "value1"
         let inputSet: Set = [value1]
         
         //when
         Targeting.shared.updateContextData(key: key1, value: inputSet)
         let dictionary = Targeting.shared.getContextData()
         let set = dictionary[key1]

         //then
         XCTAssertEqual(1, dictionary.count)
         XCTAssertEqual(1, set?.count)
         XCTAssert((set?.contains(value1))!)
     }
     
     func testRemoveContextData() {
         //given
         let key1 = "key1"
         let value1 = "value1"
         Targeting.shared.addContextData(key: key1, value: value1)
         
         //when
         Targeting.shared.removeContextData(for: key1)
         let dictionary = Targeting.shared.getContextData()

         //then
         XCTAssertEqual(0, dictionary.count)
     }
     
     func testClearContextData() {
         //given
         let key1 = "key1"
         let value1 = "value1"
         Targeting.shared.addContextData(key: key1, value: value1)
         
         //when
         Targeting.shared.clearContextData()
         let dictionary = Targeting.shared.getContextData()

         //then
         XCTAssertEqual(0, dictionary.count)
     }
    
    // MARK: - global user data aka visitor data (user.ext.data)
       func testAddUserData() {
           //given
           let key1 = "key1"
           let value1 = "value1"
           
           //when
           Targeting.shared.addUserData(key: key1, value: value1)
           let dictionary = Targeting.shared.getUserData()
           let set = dictionary[key1]

           //then
           XCTAssertEqual(1, dictionary.count)
           XCTAssertEqual(1, set?.count)
           XCTAssert((set?.contains(value1))!)
       }
       
       func testupdateUserData() {
           //given
           let key1 = "key1"
           let value1 = "value1"
           let inputSet: Set = [value1]
           
           //when
           Targeting.shared.updateUserData(key: key1, value: inputSet)
           let dictionary = Targeting.shared.getUserData()
           let set = dictionary[key1]

           //then
           XCTAssertEqual(1, dictionary.count)
           XCTAssertEqual(1, set?.count)
           XCTAssert((set?.contains(value1))!)
       }
       
       func testRemoveUserData() {
           //given
           let key1 = "key1"
           let value1 = "value1"
           Targeting.shared.addUserData(key: key1, value: value1)
           
           //when
           Targeting.shared.removeUserData(for: key1)
           let dictionary = Targeting.shared.getUserData()

           //then
           XCTAssertEqual(0, dictionary.count)
       }

       func testClearUserData() {
           //given
           let key1 = "key1"
           let value1 = "value1"
           Targeting.shared.addUserData(key: key1, value: value1)
           
           //when
           Targeting.shared.clearUserData()
           let dictionary = Targeting.shared.getUserData()

           //then
           XCTAssertEqual(0, dictionary.count)
       }

    // MARK: - global context keywords (app.keywords)
    func testAddContextKeyword() {
        //given
        let value1 = "value1"
        
        //when
        Targeting.shared.addContextKeyword(value1)
        let set = Targeting.shared.getContextKeywords()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(value1))
    }
    
    func testAddContextKeywords() {
        //given
        let value1 = "value1"
        let inputSet: Set = [value1]
        
        //when
        Targeting.shared.addContextKeywords(inputSet)
        let set = Targeting.shared.getContextKeywords()

        //then
        XCTAssertEqual(1, set.count)
        XCTAssert(set.contains(value1))
    }
    
    func testRemoveContextKeyword() {
        //given
        let value1 = "value1"
        Targeting.shared.addContextKeyword(value1)
        
        //when
        Targeting.shared.removeContextKeyword(value1)
        let set = Targeting.shared.getContextKeywords()

        //then
        XCTAssertEqual(0, set.count)
    }

    func testClearContextKeywords() {
        //given
        let value1 = "value1"
        Targeting.shared.addContextKeyword(value1)
        
        //when
        Targeting.shared.clearContextKeywords()
        let set = Targeting.shared.getContextKeywords()

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

}
