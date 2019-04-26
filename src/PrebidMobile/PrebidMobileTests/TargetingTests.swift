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

            XCTAssertTrue((value == 1985))

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

    func testGDPRConsentString() {
        Targeting.shared.gdprConsentString = "testconsent"
        let value = Targeting.shared.gdprConsentString

        XCTAssertTrue((value == "testconsent"))
    }

    func testGDPREnable() {
        Targeting.shared.subjectToGDPR = false
        let testGDPR = Targeting.shared.subjectToGDPR

        XCTAssertFalse(testGDPR)
    }

    func testItuneIDTargeting() {
        Targeting.shared.itunesID = "54673893"
        let testItuneID = Targeting.shared.itunesID

        XCTAssertTrue((testItuneID == "54673893"))
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
        Targeting.shared.addContextKeyword(key: "key1", value: "value10")
        let dictionary = Targeting.shared.getContextKeywordsDictionary()
        
        XCTAssert(dictionary.count == 1)
        
        guard let set = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }
        
        XCTAssert(set.count == 1)
        XCTAssert(set.contains("value10"))
    }
    
    func testUserKeyword() {
        Targeting.shared.addUserKeyword(key: "key1", value: "value10")
        let dictionary = Targeting.shared.getUserKeywordsDictionary()
        
        XCTAssert(dictionary.count == 1)
        
        guard let set = dictionary["key1"] else {
            XCTFail("set is nil")
            return
        }
        
        XCTAssert(set.count == 1)
        XCTAssert(set.contains("value10"))
    }

}
