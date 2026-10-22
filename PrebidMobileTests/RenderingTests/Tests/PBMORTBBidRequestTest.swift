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
@testable import PrebidMobile

class PBMORTBBidRequestTest: XCTestCase {
    
    func testCombinedProperties() {
        
        // ORTBBidRequest
        checkInt(ORTBBidRequest(), \.tmax)
        
        // ORTBBanner
        checkInt(ORTBBanner(), \.pos)
        
        // ORTBVideo
        checkInt(ORTBVideo(), \.minduration)
        checkInt(ORTBVideo(), \.maxduration)
        checkInt(ORTBVideo(), \.w)
        checkInt(ORTBVideo(), \.h)
        checkInt(ORTBVideo(), \.startdelay)
        checkInt(ORTBVideo(), \.minbitrate)
        checkInt(ORTBVideo(), \.maxbitrate)
        
        // ORTBPmp
        checkInt(ORTBPmp(), \.private_auction)
        
        // ORTBDeal
        checkInt(ORTBDeal(), \.at)
        
        // ORTBApp
        checkInt(ORTBApp(), \.privacypolicy)
        checkInt(ORTBApp(), \.paid)
        
        // ORTBDevice
        checkInt(ORTBDevice(), \.lmt)
        checkInt(ORTBDevice(), \.devicetype)
        checkInt(ORTBDevice(), \.h)
        checkInt(ORTBDevice(), \.w)
        checkInt(ORTBDevice(), \.ppi)
        checkDouble(ORTBDevice(), \.pxratio)
        checkInt(ORTBDevice(), \.js)
        checkInt(ORTBDevice(), \.geofetch)
        checkInt(ORTBDevice(), \.connectiontype)
        
        // ORTBGeo
        checkDouble(ORTBGeo(), \.lat)
        checkDouble(ORTBGeo(), \.lon)
        checkInt(ORTBGeo(), \.type)
        checkInt(ORTBGeo(), \.accuracy)
        checkInt(ORTBGeo(), \.lastfix)
        checkInt(ORTBGeo(), \.utcoffset)
    }
    
    // MARK: Test Function
    
    func checkInt<Model: AnyObject>(_ model: Model, _ keyPath: ReferenceWritableKeyPath<Model, NSNumber?>, file: StaticString = #file, line: UInt = #line) {
        check(model, keyPath, testValues: [NSNumber(value: 1), NSNumber(value: 2)], file: file, line: line)
    }
    
    func checkDouble<Model: AnyObject>(_ model: Model, _ keyPath: ReferenceWritableKeyPath<Model, NSNumber?>, file: StaticString = #file, line: UInt = #line) {
        check(model, keyPath, testValues: [NSNumber(value: 1.1), NSNumber(value: 2.2)], file: file, line: line)
    }
    
    /// A property starts as nil, stores what it is given and can be cleared again.
    /// (Typed key paths replace the former KVC `setValue(_:forKey:)`, which needed `@objc` on every model property.)
    func check<Model: AnyObject>(_ model: Model,
                                 _ keyPath: ReferenceWritableKeyPath<Model, NSNumber?>,
                                 testValues: [NSNumber],
                                 file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(testValues.count, 2, file: file, line: line)
        XCTAssertNotEqual(testValues[0], testValues[1], file: file, line: line)
        
        XCTAssertNil(model[keyPath: keyPath], file: file, line: line)
        
        model[keyPath: keyPath] = testValues[0]
        XCTAssertEqual(model[keyPath: keyPath], testValues[0], file: file, line: line)
        
        model[keyPath: keyPath] = testValues[1]
        XCTAssertEqual(model[keyPath: keyPath], testValues[1], file: file, line: line)
        
        model[keyPath: keyPath] = nil
        XCTAssertNil(model[keyPath: keyPath], file: file, line: line)
    }
}
