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

class PBMORTBBidRequestTest: XCTestCase {
    
    func testCombinedProperties() {
        
        // ORTBBidRequest
        checkInt(ORTBBidRequest(), property: "tmax")
        
        // ORTBBanner
        checkInt(ORTBBanner(), property: "pos")
        
        // ORTBVideo
        checkInt(ORTBVideo(), property: "minduration")
        checkInt(ORTBVideo(), property: "maxduration")
        checkInt(ORTBVideo(), property: "w")
        checkInt(ORTBVideo(), property: "h")
        checkInt(ORTBVideo(), property: "startdelay")
        checkInt(ORTBVideo(), property: "minbitrate")
        checkInt(ORTBVideo(), property: "maxbitrate")
        
        // ORTBPmp
        checkInt(ORTBPmp(), property: "private_auction")
        
        // ORTBDeal
        checkInt(ORTBDeal(), property: "at")
        
        // ORTBApp
        checkInt(ORTBApp(), property: "privacypolicy")
        checkInt(ORTBApp(), property: "paid")
        
        // ORTBDevice
        checkInt(ORTBDevice(), property: "lmt")
        checkInt(ORTBDevice(), property: "devicetype")
        checkInt(ORTBDevice(), property: "h")
        checkInt(ORTBDevice(), property: "w")
        checkInt(ORTBDevice(), property: "ppi")
        checkDouble(ORTBDevice(), property: "pxratio")
        checkInt(ORTBDevice(), property: "js")
        checkInt(ORTBDevice(), property: "geofetch")
        checkInt(ORTBDevice(), property: "connectiontype")
        
        // ORTBGeo
        checkDouble(ORTBGeo(), property: "lat")
        checkDouble(ORTBGeo(), property: "lon")
        checkInt(ORTBGeo(), property: "type")
        checkInt(ORTBGeo(), property: "accuracy")
        checkInt(ORTBGeo(), property: "lastfix")
        checkInt(ORTBGeo(), property: "utcoffset")
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
