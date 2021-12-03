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

import Foundation
import XCTest

// Use to test equality of values that have type 'Any'
public func PBMAssertEq<T: Equatable>(type: T.Type, actual: Any, expected: Any, file: StaticString = #file, line: UInt = #line) {
    guard let actual = actual as? T, let expected = expected as? T else {
        PBMFail(actual, expected, file:file, line:line)
        return
    }
    
    XCTAssertTrue(actual == expected)
}

public func PBMAssertEq<T:Equatable>(_ actual:T?, _ expected:T?, file: StaticString = #file, line: UInt = #line) {
    if (expected != actual) {
        PBMFail(actual, expected, file:file, line:line)
    }
}

public func PBMAssertEq<T:Equatable>(_ actual:[T]?, _ expected:[T]?, file: StaticString = #file, line: UInt = #line) {
    //If both are nil, test passes.
    if (expected == nil) && (actual == nil) {
        return
    }
    
    //Swift forces an unwrap before comparison to non-explicit nil.
    guard let unwrappedExpected = expected, let unwrappedActual = actual, unwrappedExpected == unwrappedActual else {
        PBMFail(actual, expected, file:file, line:line)
        return
    }
}

public func PBMAssertEq<Key, Value:Equatable>(_ actual: [Key : Value]?, _ expected: [Key : Value]?, file: StaticString = #file, line: UInt = #line) {
    //If both are nil, test passes.
    if (expected == nil) && (actual == nil) {
        return
    }
    
    //Swift forces an unwrap before comparison to non-explicit nil.
    guard let unwrappedExpected = expected, let unwrappedActual = actual, unwrappedExpected == unwrappedActual else {
        PBMFail(expected, actual, file:file, line:line)
        return
    }
}

public func PBMFail(_ actual:Any?, _ expected:Any?, file:StaticString = #file, line:UInt = #line) {
    
    var message = "Expected: \(String(describing: expected)) Got: \(String(describing: actual))"
    
    //If the message is long, break it into multiple lines for easier comparison.
    if message.count > 100 {
        message = "Expected:\n\(String(describing: expected))\n\nGot:\n\(String(describing: actual))"
    }
    
    XCTFail(message, file:file, line:line)
}

