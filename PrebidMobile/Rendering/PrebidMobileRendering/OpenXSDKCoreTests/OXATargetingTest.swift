//
//  OXATargetingTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
import MapKit

@testable import PrebidMobileRendering

class OXATargetingTest: XCTestCase {
    func testShared() {
        testInitialValues(targeting: .shared())
    }
    func testInit() {
        testInitialValues(targeting: .withDisabledLock)
    }
    
    func testInitialValues(targeting: OXATargeting) {
        XCTAssertEqual(targeting.userAge, 0)
        XCTAssertEqual(targeting.userGender, .unknown)
        XCTAssertNil(targeting.userID)
        XCTAssertNil(targeting.buyerUID)
        XCTAssertNil(targeting.publisherName)
        XCTAssertNil(targeting.appStoreMarketURL)
        XCTAssertNil(targeting.userCustomData)
        XCTAssertNil(targeting.userExt)
        XCTAssertNil(targeting.eids)
        XCTAssertNil(targeting.IP)
        XCTAssertEqual(targeting.networkType, .unknown)
        XCTAssert(targeting.parameterDictionary == [:])
    }
    
    func testYobForAge() {
        let age = 42
        let date = Date()
        let calendar = Calendar.current
        let yob = calendar.component(.year, from: date) - age
        
        XCTAssertEqual(OXAAgeUtils.yob(forAge:age), yob)
    }
    
    func testUserAge() {
        //Init
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssert(oxaTargeting.userAge == 0)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        let age = 30
        oxaTargeting.userAge = age
        XCTAssert(oxaTargeting.userAge == age)
        XCTAssert(oxaTargeting.parameterDictionary == ["age":"\(age)"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.userAge = 0
        XCTAssert(oxaTargeting.userAge == 0)
        XCTAssert(oxaTargeting.parameterDictionary == ["age":"0"], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testUserAgeReset() {
        //Init
        let age = 42
        let oxaTargeting = OXATargeting.withDisabledLock
        oxaTargeting.userAge = age

        XCTAssert(oxaTargeting.userAge == age)
        XCTAssert(oxaTargeting.parameterDictionary == ["age":"\(age)"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        // Test reset
        oxaTargeting.resetUserAge()
        XCTAssert(oxaTargeting.userAge == 0)
        XCTAssert(oxaTargeting.parameterDictionary["age"] == nil)
    }
}

extension OXAGender: CaseIterable {
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
 
extension OXATargetingTest {
    func testUserGender() {
        
        //Init
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssert(oxaTargeting.userGender == .unknown)
        
        //Set
        for gender in OXAGender.allCases {
            oxaTargeting.userGender = gender
            XCTAssertEqual(oxaTargeting.userGender, gender)
            
            let expectedDic: [String: String]
            if let letter = gender.paramsDicLetter {
                expectedDic = ["gen": letter]
            } else {
                expectedDic = [:]
            }
            XCTAssertEqual(oxaTargeting.parameterDictionary, expectedDic as NSDictionary, "Dict is \(oxaTargeting.parameterDictionary)")
        }
        
        //Unset
        oxaTargeting.userGender = .unknown
        XCTAssert(oxaTargeting.userGender == .unknown)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }

    func testUserID() {

        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssert(oxaTargeting.userID == nil)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        oxaTargeting.userID = "abc123"
        XCTAssert(oxaTargeting.parameterDictionary == ["xid":"abc123"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.userID = nil
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testBuyerUID() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.buyerUID)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        let buyerUID = "abc123"
        oxaTargeting.buyerUID = buyerUID
        XCTAssertEqual(oxaTargeting.buyerUID, buyerUID)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.buyerUID = nil
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testUserCustomData() {

        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.userCustomData)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        let customData = "123"
        oxaTargeting.userCustomData = customData
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.userCustomData = nil
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testUserExt() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.userExt)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")

        //Set
        let userExt:NSMutableDictionary = ["consent": "dummyConsentString"]
        oxaTargeting.userExt = userExt
        XCTAssertEqual(oxaTargeting.userExt?.count, 1)
    }
    
    func testUserEids() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.eids)

        //Set
        let eids: NSArray = [["key" : "value"], ["key" : "value"]]
        oxaTargeting.eids = eids as? [[String : Any]]
        XCTAssertEqual(oxaTargeting.eids?.count, 2)
    }
    
    func testPublisherName() {
        //Init
        //Note: on init, and it never doesn't send a value via an ad request params.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.publisherName)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        let publisherName = "abc123"
        oxaTargeting.publisherName = publisherName
        XCTAssertEqual(oxaTargeting.publisherName, publisherName)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.publisherName = nil
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testAppStoreMarketURL() {
        
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.appStoreMarketURL)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        let storeUrl = "foo.com"
        oxaTargeting.appStoreMarketURL = storeUrl
        XCTAssertEqual(oxaTargeting.appStoreMarketURL, storeUrl)
        XCTAssert(oxaTargeting.parameterDictionary == ["url":storeUrl], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.appStoreMarketURL = nil
        XCTAssertNil(oxaTargeting.appStoreMarketURL)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }

    func testLatitudeLongitude() {
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.coordinate)
        
        let lat = 123.0
        let lon = 456.0
        oxaTargeting.setLatitude(lat, longitude: lon)
        XCTAssertEqual(oxaTargeting.coordinate?.mkCoordinateValue.latitude, lat)
        XCTAssertEqual(oxaTargeting.coordinate?.mkCoordinateValue.longitude, lon)
    }
    
    //MARK: - Network
    func testCarrier() {
        
        //Init (the default is nil but it doesn't send a value)
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.carrier)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        let carrier = "AT&T"
        oxaTargeting.carrier = carrier
        XCTAssertEqual(oxaTargeting.carrier, carrier)
        XCTAssert(oxaTargeting.parameterDictionary == ["crr":carrier], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.carrier = nil
        XCTAssertNil(oxaTargeting.carrier)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testIP() {

        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.IP)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        oxaTargeting.IP = "127.0.0.1"
        XCTAssertEqual(oxaTargeting.IP, "127.0.0.1")
        XCTAssert(oxaTargeting.parameterDictionary == ["ip":"127.0.0.1"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.IP = nil
        XCTAssertNil(oxaTargeting.IP)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    //Note: no way to currently un-set networkType
    func testNetworkType() {
        let oxaTargeting = OXATargeting.withDisabledLock
        
        //Note: on init, the default is cell but it doesn't send a value.
        XCTAssert(oxaTargeting.networkType == .unknown)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        

        oxaTargeting.networkType = .cell
        XCTAssert(oxaTargeting.parameterDictionary == ["net":"cell"], "Dict is \(oxaTargeting.parameterDictionary)")

        oxaTargeting.networkType = .wifi
        XCTAssert(oxaTargeting.parameterDictionary == ["net":"wifi"], "Dict is \(oxaTargeting.parameterDictionary)")
 
        oxaTargeting.networkType = .offline
        XCTAssert(oxaTargeting.parameterDictionary == ["net":"offline"], "Dict is \(oxaTargeting.parameterDictionary)")

        oxaTargeting.networkType = .unknown
        XCTAssert(oxaTargeting.networkType == .unknown)
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    //MARK: - Custom Params
    func testAddParam() {
        
        //Init
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        oxaTargeting.addParam("value", withName: "name")
        XCTAssert(oxaTargeting.parameterDictionary == ["name":"value"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.addParam("", withName: "name")
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }

    func testAddCustomParam() {
        
        //Init
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        oxaTargeting.addCustomParam("value", withName: "name")
        XCTAssert(oxaTargeting.parameterDictionary == ["c.name":"value"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Unset
        oxaTargeting.addCustomParam("", withName: "name")
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testSetCustomParams() {
        //Init
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssert(oxaTargeting.parameterDictionary == [:], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Set
        oxaTargeting.setCustomParams(["name1":"value1", "name2":"value2"])
        XCTAssert(oxaTargeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(oxaTargeting.parameterDictionary)")
        
        //Not currently possible to unset
        oxaTargeting.setCustomParams([:])
        XCTAssert(oxaTargeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(oxaTargeting.parameterDictionary)")
    }
    
    func testKeywords() {
        //Init
        let oxaTargeting = OXATargeting.withDisabledLock
        XCTAssertNil(oxaTargeting.keywords)
        
        let keywords = "Key, words"
        oxaTargeting.keywords = keywords
        XCTAssertEqual(oxaTargeting.keywords, keywords)
    }
    
    func testCopy() {
        let buyerUID = "buyerID"
        let keywords = "word1, word2"
        let userCustomData = "customData"
        let sourceApp = "openx.InternalApp"
        let contentUrl = "https://openx.com"
        let publisherName = "OpenX"
        let eids: NSArray = [["key" : "value"], ["key" : "value"]]
        let userExt:NSMutableDictionary = ["consent": "dummyConsentString"]
        
        
        let oxaTargeting = OXATargeting.withDisabledLock
        oxaTargeting.buyerUID = buyerUID
        oxaTargeting.coppa = NSNumber(value: 1)
        oxaTargeting.keywords = keywords
        oxaTargeting.userCustomData = userCustomData
        oxaTargeting.contentUrl = contentUrl
        oxaTargeting.publisherName = publisherName
        oxaTargeting.networkType = .wifi
        oxaTargeting.sourceapp = sourceApp
        
        oxaTargeting.eids = eids as? [[String : Any]]
        oxaTargeting.userExt = userExt
        XCTAssertEqual(oxaTargeting.coppa, 1)
        XCTAssertEqual(oxaTargeting.sourceapp, sourceApp)
        
        let copyTargering = oxaTargeting.copy() as! OXATargeting
        XCTAssertEqual(copyTargering.networkType, .wifi)
        XCTAssertEqual(copyTargering.coppa, 1)
        XCTAssertEqual(copyTargering.sourceapp, sourceApp)
        XCTAssertEqual(copyTargering.buyerUID, buyerUID)
        XCTAssertEqual(copyTargering.keywords, keywords)
        XCTAssertEqual(copyTargering.userCustomData, userCustomData)
        XCTAssertEqual(copyTargering.contentUrl, contentUrl)
        XCTAssertEqual(copyTargering.publisherName, publisherName)
        XCTAssertEqual(copyTargering.eids?.count, 2)
        XCTAssertEqual(copyTargering.userExt?["consent"] as? String, "dummyConsentString")
    }
}
