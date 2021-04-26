//
//  PBMTargetingTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
import MapKit

@testable import PrebidMobileRendering

class PBMTargetingTest: XCTestCase {
    func testShared() {
        testInitialValues(targeting: .shared())
    }
    func testInit() {
        testInitialValues(targeting: .withDisabledLock)
    }
    
    func testInitialValues(targeting: PBMTargeting) {
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
        
        XCTAssertEqual(PBMAgeUtils.yob(forAge:age), yob)
    }
    
    func testUserAge() {
        //Init
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssert(pbmTargeting.userAge == 0)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        let age = 30
        pbmTargeting.userAge = age
        XCTAssert(pbmTargeting.userAge == age)
        XCTAssert(pbmTargeting.parameterDictionary == ["age":"\(age)"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.userAge = 0
        XCTAssert(pbmTargeting.userAge == 0)
        XCTAssert(pbmTargeting.parameterDictionary == ["age":"0"], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testUserAgeReset() {
        //Init
        let age = 42
        let pbmTargeting = PBMTargeting.withDisabledLock
        pbmTargeting.userAge = age

        XCTAssert(pbmTargeting.userAge == age)
        XCTAssert(pbmTargeting.parameterDictionary == ["age":"\(age)"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        // Test reset
        pbmTargeting.resetUserAge()
        XCTAssert(pbmTargeting.userAge == 0)
        XCTAssert(pbmTargeting.parameterDictionary["age"] == nil)
    }
}

extension PBMGender: CaseIterable {
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
 
extension PBMTargetingTest {
    func testUserGender() {
        
        //Init
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssert(pbmTargeting.userGender == .unknown)
        
        //Set
        for gender in PBMGender.allCases {
            pbmTargeting.userGender = gender
            XCTAssertEqual(pbmTargeting.userGender, gender)
            
            let expectedDic: [String: String]
            if let letter = gender.paramsDicLetter {
                expectedDic = ["gen": letter]
            } else {
                expectedDic = [:]
            }
            XCTAssertEqual(pbmTargeting.parameterDictionary, expectedDic as NSDictionary, "Dict is \(pbmTargeting.parameterDictionary)")
        }
        
        //Unset
        pbmTargeting.userGender = .unknown
        XCTAssert(pbmTargeting.userGender == .unknown)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }

    func testUserID() {

        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssert(pbmTargeting.userID == nil)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        pbmTargeting.userID = "abc123"
        XCTAssert(pbmTargeting.parameterDictionary == ["xid":"abc123"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.userID = nil
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testBuyerUID() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.buyerUID)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        let buyerUID = "abc123"
        pbmTargeting.buyerUID = buyerUID
        XCTAssertEqual(pbmTargeting.buyerUID, buyerUID)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.buyerUID = nil
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testUserCustomData() {

        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.userCustomData)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        let customData = "123"
        pbmTargeting.userCustomData = customData
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.userCustomData = nil
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testUserExt() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.userExt)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")

        //Set
        let userExt:NSMutableDictionary = ["consent": "dummyConsentString"]
        pbmTargeting.userExt = userExt
        XCTAssertEqual(pbmTargeting.userExt?.count, 1)
    }
    
    func testUserEids() {
        //Init
        //Note: on init, and it never sends a value via an odinary ad request params.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.eids)

        //Set
        let eids: NSArray = [["key" : "value"], ["key" : "value"]]
        pbmTargeting.eids = eids as? [[String : Any]]
        XCTAssertEqual(pbmTargeting.eids?.count, 2)
    }
    
    func testPublisherName() {
        //Init
        //Note: on init, and it never doesn't send a value via an ad request params.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.publisherName)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        let publisherName = "abc123"
        pbmTargeting.publisherName = publisherName
        XCTAssertEqual(pbmTargeting.publisherName, publisherName)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.publisherName = nil
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testAppStoreMarketURL() {
        
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.appStoreMarketURL)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        let storeUrl = "foo.com"
        pbmTargeting.appStoreMarketURL = storeUrl
        XCTAssertEqual(pbmTargeting.appStoreMarketURL, storeUrl)
        XCTAssert(pbmTargeting.parameterDictionary == ["url":storeUrl], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.appStoreMarketURL = nil
        XCTAssertNil(pbmTargeting.appStoreMarketURL)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }

    func testLatitudeLongitude() {
        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.coordinate)
        
        let lat = 123.0
        let lon = 456.0
        pbmTargeting.setLatitude(lat, longitude: lon)
        XCTAssertEqual(pbmTargeting.coordinate?.mkCoordinateValue.latitude, lat)
        XCTAssertEqual(pbmTargeting.coordinate?.mkCoordinateValue.longitude, lon)
    }
    
    //MARK: - Network
    func testCarrier() {
        
        //Init (the default is nil but it doesn't send a value)
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.carrier)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        let carrier = "AT&T"
        pbmTargeting.carrier = carrier
        XCTAssertEqual(pbmTargeting.carrier, carrier)
        XCTAssert(pbmTargeting.parameterDictionary == ["crr":carrier], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.carrier = nil
        XCTAssertNil(pbmTargeting.carrier)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testIP() {

        //Init
        //Note: on init, the default is nil but it doesn't send a value.
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.IP)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        pbmTargeting.IP = "127.0.0.1"
        XCTAssertEqual(pbmTargeting.IP, "127.0.0.1")
        XCTAssert(pbmTargeting.parameterDictionary == ["ip":"127.0.0.1"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.IP = nil
        XCTAssertNil(pbmTargeting.IP)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    //Note: no way to currently un-set networkType
    func testNetworkType() {
        let pbmTargeting = PBMTargeting.withDisabledLock
        
        //Note: on init, the default is cell but it doesn't send a value.
        XCTAssert(pbmTargeting.networkType == .unknown)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        

        pbmTargeting.networkType = .cell
        XCTAssert(pbmTargeting.parameterDictionary == ["net":"cell"], "Dict is \(pbmTargeting.parameterDictionary)")

        pbmTargeting.networkType = .wifi
        XCTAssert(pbmTargeting.parameterDictionary == ["net":"wifi"], "Dict is \(pbmTargeting.parameterDictionary)")
 
        pbmTargeting.networkType = .offline
        XCTAssert(pbmTargeting.parameterDictionary == ["net":"offline"], "Dict is \(pbmTargeting.parameterDictionary)")

        pbmTargeting.networkType = .unknown
        XCTAssert(pbmTargeting.networkType == .unknown)
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    //MARK: - Custom Params
    func testAddParam() {
        
        //Init
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        pbmTargeting.addParam("value", withName: "name")
        XCTAssert(pbmTargeting.parameterDictionary == ["name":"value"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.addParam("", withName: "name")
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }

    func testAddCustomParam() {
        
        //Init
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        pbmTargeting.addCustomParam("value", withName: "name")
        XCTAssert(pbmTargeting.parameterDictionary == ["c.name":"value"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Unset
        pbmTargeting.addCustomParam("", withName: "name")
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testSetCustomParams() {
        //Init
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssert(pbmTargeting.parameterDictionary == [:], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Set
        pbmTargeting.setCustomParams(["name1":"value1", "name2":"value2"])
        XCTAssert(pbmTargeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(pbmTargeting.parameterDictionary)")
        
        //Not currently possible to unset
        pbmTargeting.setCustomParams([:])
        XCTAssert(pbmTargeting.parameterDictionary == ["c.name1":"value1", "c.name2":"value2"], "Dict is \(pbmTargeting.parameterDictionary)")
    }
    
    func testKeywords() {
        //Init
        let pbmTargeting = PBMTargeting.withDisabledLock
        XCTAssertNil(pbmTargeting.keywords)
        
        let keywords = "Key, words"
        pbmTargeting.keywords = keywords
        XCTAssertEqual(pbmTargeting.keywords, keywords)
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
        
        
        let pbmTargeting = PBMTargeting.withDisabledLock
        pbmTargeting.buyerUID = buyerUID
        pbmTargeting.coppa = NSNumber(value: 1)
        pbmTargeting.keywords = keywords
        pbmTargeting.userCustomData = userCustomData
        pbmTargeting.contentUrl = contentUrl
        pbmTargeting.publisherName = publisherName
        pbmTargeting.networkType = .wifi
        pbmTargeting.sourceapp = sourceApp
        
        pbmTargeting.eids = eids as? [[String : Any]]
        pbmTargeting.userExt = userExt
        XCTAssertEqual(pbmTargeting.coppa, 1)
        XCTAssertEqual(pbmTargeting.sourceapp, sourceApp)
        
        let copyTargering = pbmTargeting.copy() as! PBMTargeting
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
