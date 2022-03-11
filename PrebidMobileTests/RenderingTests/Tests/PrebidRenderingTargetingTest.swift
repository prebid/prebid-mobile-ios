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
import MapKit

@testable import PrebidMobile

extension Gender: CaseIterable {
    public static let allCases: [Self] = [
        .unknown,
        .male,
        .female,
        .other,
    ]
    
    fileprivate var paramsDicLetter: String? {
        switch self {
        case .unknown: return nil
        case .male:    return "M"
        case .female:  return "F"
        case .other:   return "O"
        @unknown default:
            XCTFail("Unexpected value: \(self)")
            return nil
        }
    }
}

class PrebidRenderingTargetingTest: XCTestCase {
    
    override func setUp() {
        UtilitiesForTesting.resetTargeting(.shared)
    }
    
    override func tearDown() {
        UtilitiesForTesting.resetTargeting(.shared)
    }
    
    func testShared() {
        UtilitiesForTesting.checkInitialValues(.shared)
    }
    
    func testUserAge() {
        //Init
        let targeting = Targeting.shared
        
        XCTAssertNil(targeting.userAge)
        XCTAssert(targeting.parameterDictionary == [:], "Dict is \(targeting.parameterDictionary)")
        
        //Set
        let age = 30
        targeting.userAge = age as NSNumber
        XCTAssert(targeting.userAge as! Int == age)
        XCTAssert(targeting.parameterDictionary == ["age":"\(age)"], "Dict is \(targeting.parameterDictionary)")
        
        //Unset
        targeting.userAge = 0
        XCTAssert(targeting.userAge == 0)
        XCTAssert(targeting.parameterDictionary == ["age":"0"], "Dict is \(targeting.parameterDictionary)")
    }
    
    func testUserAgeReset() {
        //Init
        let age = 42
        let Targeting = Targeting.shared
        Targeting.userAge = age as NSNumber

        XCTAssert(Targeting.userAge as! Int == age)
        XCTAssert(Targeting.parameterDictionary == ["age":"\(age)"], "Dict is \(Targeting.parameterDictionary)")
        
        // Test reset
        Targeting.resetUserAge()
        XCTAssertNil(Targeting.userAge)
        XCTAssertNil(Targeting.parameterDictionary["age"])
    }

    func testUserGender() {
        
        //Init
        let targeting = Targeting.shared
        XCTAssert(targeting.userGender == .unknown)
        
        //Set
        for gender in Gender.allCases {
            targeting.userGender = gender
            XCTAssertEqual(targeting.userGender, gender)
            
            let expectedDic: [String: String]
            if let letter = gender.paramsDicLetter {
                expectedDic = ["gen": letter]
            } else {
                expectedDic = [:]
            }
            XCTAssertEqual(targeting.parameterDictionary, expectedDic, "Dict is \(targeting.parameterDictionary)")
        }
        
        //Unset
        targeting.userGender = .unknown
        XCTAssert(targeting.userGender == .unknown)
        XCTAssert(targeting.parameterDictionary == [:], "Dict is \(targeting.parameterDictionary)")
    }

    func testUserID() {

        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let Targeting = Targeting.shared
        XCTAssert(Targeting.userID == nil)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        Targeting.userID = "abc123"
        XCTAssert(Targeting.parameterDictionary == ["xid":"abc123"], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.userID = nil
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
    }
    
    func testBuyerUID() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.buyerUID)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        let buyerUID = "abc123"
        Targeting.buyerUID = buyerUID
        XCTAssertEqual(Targeting.buyerUID, buyerUID)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.buyerUID = nil
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
    }
    
    func testUserCustomData() {

        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.userCustomData)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        let customData = "123"
        Targeting.userCustomData = customData
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.userCustomData = nil
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
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
    
    func testUserEids() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.eids)

        //Set
        let eids: [[String: AnyHashable]] = [["key" : "value"], ["key" : "value"]]
        Targeting.eids = eids
        XCTAssertEqual(Targeting.eids?.count, 2)
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
    
    func testAppStoreMarketURL() {
        
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.appStoreMarketURL)
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        let storeUrl = "foo.com"
        Targeting.appStoreMarketURL = storeUrl
        XCTAssertEqual(Targeting.appStoreMarketURL, storeUrl)
        XCTAssert(Targeting.parameterDictionary == ["url":storeUrl], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.appStoreMarketURL = nil
        XCTAssertNil(Targeting.appStoreMarketURL)
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

    func testAddCustomParam() {
        
        //Init
        let Targeting = Targeting.shared
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        Targeting.addCustomParam("value", withName: "name")
        XCTAssert(Targeting.parameterDictionary == ["c.name":"value"], "Dict is \(Targeting.parameterDictionary)")
        
        //Unset
        Targeting.addCustomParam("", withName: "name")
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
    }
    
    func testSetCustomParams() {
        //Init
        let Targeting = Targeting.shared
        XCTAssert(Targeting.parameterDictionary == [:], "Dict is \(Targeting.parameterDictionary)")
        
        //Set
        Targeting.setCustomParams(["name1":"value1", "name2":"value2"])
        XCTAssert(Targeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(Targeting.parameterDictionary)")
        
        //Not currently possible to unset
        Targeting.setCustomParams([:])
        XCTAssert(Targeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(Targeting.parameterDictionary)")
    }
    
    func testKeywords() {
        //Init
        let Targeting = Targeting.shared
        XCTAssertNil(Targeting.keywords)
        
        let keywords = "Key, words"
        Targeting.keywords = keywords
        XCTAssertEqual(Targeting.keywords, keywords)
    }
}
