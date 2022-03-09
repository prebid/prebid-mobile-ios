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

extension PBRGender: CaseIterable {
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
        let targeting = PrebidRenderingTargeting.shared
        
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
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        PrebidRenderingTargeting.userAge = age as NSNumber

        XCTAssert(PrebidRenderingTargeting.userAge as! Int == age)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["age":"\(age)"], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        // Test reset
        PrebidRenderingTargeting.resetUserAge()
        XCTAssertNil(PrebidRenderingTargeting.userAge)
        XCTAssertNil(PrebidRenderingTargeting.parameterDictionary["age"])
    }

    func testUserGender() {
        
        //Init
        let targeting = PrebidRenderingTargeting.shared
        XCTAssert(targeting.userGender == .unknown)
        
        //Set
        for gender in PBRGender.allCases {
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
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssert(PrebidRenderingTargeting.userID == nil)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        PrebidRenderingTargeting.userID = "abc123"
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["xid":"abc123"], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.userID = nil
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }
    
    func testBuyerUID() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.buyerUID)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        let buyerUID = "abc123"
        PrebidRenderingTargeting.buyerUID = buyerUID
        XCTAssertEqual(PrebidRenderingTargeting.buyerUID, buyerUID)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.buyerUID = nil
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }
    
    func testUserCustomData() {

        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.userCustomData)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        let customData = "123"
        PrebidRenderingTargeting.userCustomData = customData
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.userCustomData = nil
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }
    
    func testUserExt() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.userExt)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")

        //Set
        let userExt = ["consent": "dummyConsentString"]
        PrebidRenderingTargeting.userExt = userExt
        XCTAssertEqual(PrebidRenderingTargeting.userExt?.count, 1)
    }
    
    func testUserEids() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.eids)

        //Set
        let eids: [[String: AnyHashable]] = [["key" : "value"], ["key" : "value"]]
        PrebidRenderingTargeting.eids = eids
        XCTAssertEqual(PrebidRenderingTargeting.eids?.count, 2)
    }
    
    func testPublisherName() {
        //Init
        //Note: on init, and it never doesn't send a value via an ad request params.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.publisherName)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        let publisherName = "abc123"
        PrebidRenderingTargeting.publisherName = publisherName
        XCTAssertEqual(PrebidRenderingTargeting.publisherName, publisherName)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.publisherName = nil
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }
    
    func testAppStoreMarketURL() {
        
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.appStoreMarketURL)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        let storeUrl = "foo.com"
        PrebidRenderingTargeting.appStoreMarketURL = storeUrl
        XCTAssertEqual(PrebidRenderingTargeting.appStoreMarketURL, storeUrl)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["url":storeUrl], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.appStoreMarketURL = nil
        XCTAssertNil(PrebidRenderingTargeting.appStoreMarketURL)
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }

    func testLatitudeLongitude() {
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.coordinate)
        
        let lat = 123.0
        let lon = 456.0
        PrebidRenderingTargeting.setLatitude(lat, longitude: lon)
        XCTAssertEqual(PrebidRenderingTargeting.coordinate?.mkCoordinateValue.latitude, lat)
        XCTAssertEqual(PrebidRenderingTargeting.coordinate?.mkCoordinateValue.longitude, lon)
    }
    
    //MARK: - Custom Params
    func testAddParam() {
        
        //Init
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        PrebidRenderingTargeting.addParam("value", withName: "name")
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["name":"value"], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.addParam("", withName: "name")
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }

    func testAddCustomParam() {
        
        //Init
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        PrebidRenderingTargeting.addCustomParam("value", withName: "name")
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["c.name":"value"], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Unset
        PrebidRenderingTargeting.addCustomParam("", withName: "name")
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }
    
    func testSetCustomParams() {
        //Init
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == [:], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Set
        PrebidRenderingTargeting.setCustomParams(["name1":"value1", "name2":"value2"])
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
        
        //Not currently possible to unset
        PrebidRenderingTargeting.setCustomParams([:])
        XCTAssert(PrebidRenderingTargeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(PrebidRenderingTargeting.parameterDictionary)")
    }
    
    func testKeywords() {
        //Init
        let PrebidRenderingTargeting = PrebidRenderingTargeting.shared
        XCTAssertNil(PrebidRenderingTargeting.keywords)
        
        let keywords = "Key, words"
        PrebidRenderingTargeting.keywords = keywords
        XCTAssertEqual(PrebidRenderingTargeting.keywords, keywords)
    }
}
