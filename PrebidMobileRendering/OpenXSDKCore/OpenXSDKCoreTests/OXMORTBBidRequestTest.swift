//
//  OXMORTBBidRequestTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMORTBBidRequestTest: XCTestCase {
    
    func testCombinedProperties() {
        
        // OXMORTBBidRequest
        checkInt(OXMORTBBidRequest(), property: "tmax")
        
        // OXMORTBBanner
        checkInt(OXMORTBBanner(), property: "pos")
        
        // OXMORTBVideo
        checkInt(OXMORTBVideo(), property: "minduration")
        checkInt(OXMORTBVideo(), property: "maxduration")
        checkInt(OXMORTBVideo(), property: "w")
        checkInt(OXMORTBVideo(), property: "h")
        checkInt(OXMORTBVideo(), property: "startdelay")
        checkInt(OXMORTBVideo(), property: "linearity")
        checkInt(OXMORTBVideo(), property: "minbitrate")
        checkInt(OXMORTBVideo(), property: "maxbitrate")
        
        // OXMORTBPmp
        checkInt(OXMORTBPmp(), property: "private_auction")
        
        // OXMORTBDeal
        checkInt(OXMORTBDeal(), property: "at")
        
        // OXMORTBApp
        checkInt(OXMORTBApp(), property: "privacypolicy")
        checkInt(OXMORTBApp(), property: "paid")
        
        // OXMORTBDevice
        checkInt(OXMORTBDevice(), property: "lmt")
        checkInt(OXMORTBDevice(), property: "devicetype")
        checkInt(OXMORTBDevice(), property: "h")
        checkInt(OXMORTBDevice(), property: "w")
        checkInt(OXMORTBDevice(), property: "ppi")
        checkDouble(OXMORTBDevice(), property: "pxratio")
        checkInt(OXMORTBDevice(), property: "js")
        checkInt(OXMORTBDevice(), property: "geofetch")
        checkInt(OXMORTBDevice(), property: "connectiontype")
        
        // OXMORTBGeo
        checkDouble(OXMORTBGeo(), property: "lat")
        checkDouble(OXMORTBGeo(), property: "lon")
        checkInt(OXMORTBGeo(), property: "type")
        checkInt(OXMORTBGeo(), property: "accuracy")
        checkInt(OXMORTBGeo(), property: "lastfix")
        checkInt(OXMORTBGeo(), property: "utcoffset")
        
        // OXMORTBUser
        checkInt(OXMORTBUser(), property: "yob")
    }
    
    // MARK: Test Function
    
    func checkInt(_ object: NSObject, property: String, file: StaticString = #file, line: UInt = #line) {
        check(object, property: property, testValues: [1, 2], file: file, line: line)
    }
    
    func checkDouble(_ object: NSObject, property: String, file: StaticString = #file, line: UInt = #line) {
        check(object, property: property, testValues: [1.1, 2.2], file: file, line: line)
    }
    
    func check<T: Comparable>(_ object: NSObject,
                              property: String,
                              typePrefix: String? = nil,
                              testValues: [T],
                              file: StaticString = #file, line: UInt = #line) {
        
        // Prepare
        var typedProperty = property
        if let type = typePrefix {
            typedProperty = type + String(property.first!).uppercased() + property.dropFirst()
        }

        XCTAssertEqual(testValues.count, 2, file: file, line: line)
        XCTAssertNotEqual(testValues[0], testValues[1], file: file, line: line)

        // Check the property existence
        XCTAssert(object.responds(to: Selector(property)), "There is no property \(property)", file: file, line: line)
        XCTAssert(object.responds(to: Selector(typedProperty)), "There is no property \(typedProperty)", file: file, line: line)
        
        // Default should be nil
        XCTAssertNil(object.value(forKey: property), file: file, line: line)
        XCTAssertNil(object.value(forKey: typedProperty), file: file, line: line)
        
        let v1 = testValues[0]
        object.setValue(v1, forKey: property)
        XCTAssertEqual(object.value(forKey: typedProperty) as! T , v1, file: file, line: line)
        
        let v2 = testValues[1]
        object.setValue(v2, forKey: typedProperty)
        XCTAssertEqual(object.value(forKey: property) as! T, v2, file: file, line: line)
        
        object.setValue(nil, forKey: property)
        XCTAssertNil(object.value(forKey: property), file: file, line: line)
        XCTAssertNil(object.value(forKey: typedProperty), file: file, line: line)
    }
    
}
