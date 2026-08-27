/*   Copyright 2018-2026 Prebid.org, Inc.

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
@testable @_spi(PBMInternal) import PrebidMobile

class FunctionsTests: XCTestCase {

    // MARK: - Decimal preservation

    func testDictionaryPreservingDecimals_keepsTwoDigitDecimals() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": 0.05}"#)
        XCTAssertEqual(dict["v"] as? NSDecimalNumber, NSDecimalNumber(string: "0.05"))
    }

    func testDictionaryPreservingDecimals_keepsOneDigitDecimals() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": 0.1}"#)
        XCTAssertEqual(dict["v"] as? NSDecimalNumber, NSDecimalNumber(string: "0.1"))
    }

    func testDictionaryPreservingDecimals_keepsExactlyRepresentableDecimals() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": 0.5}"#)
        XCTAssertEqual(dict["v"] as? NSDecimalNumber, NSDecimalNumber(string: "0.5"))
    }

    func testDictionaryPreservingDecimals_preservesIntegers() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": 42}"#)
        XCTAssertEqual(dict["v"] as? NSDecimalNumber, NSDecimalNumber(value: 42))
    }

    func testDictionaryPreservingDecimals_preservesNegativeDecimals() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": -0.05}"#)
        XCTAssertEqual(dict["v"] as? NSDecimalNumber, NSDecimalNumber(string: "-0.05"))
    }

    func testDictionaryPreservingDecimals_preservesScientificNotation() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": 1e-3}"#)
        XCTAssertEqual(dict["v"] as? NSDecimalNumber, NSDecimalNumber(string: "0.001"))
    }

    // MARK: - Booleans, nulls, strings

    func testDictionaryPreservingDecimals_preservesBooleansAsBool() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"t": true, "f": false}"#)
        XCTAssertEqual(dict["t"] as? Bool, true)
        XCTAssertEqual(dict["f"] as? Bool, false)
        // Critical: must NOT be decoded as NSDecimalNumber 1/0
        XCTAssertNil(dict["t"] as? NSDecimalNumber)
        XCTAssertNil(dict["f"] as? NSDecimalNumber)
    }

    func testDictionaryPreservingDecimals_preservesNulls() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": null}"#)
        XCTAssertTrue(dict["v"] is NSNull)
    }

    func testDictionaryPreservingDecimals_preservesStrings() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"v": "hello"}"#)
        XCTAssertEqual(dict["v"] as? String, "hello")
    }

    // MARK: - Nesting

    func testDictionaryPreservingDecimals_preservesNestedArraysOfDecimals() throws {
        let dict = try Functions.dictionaryPreservingDecimals(from: #"{"a": [0.05, 0.1, 0.5]}"#)
        let array = dict["a"] as? [NSDecimalNumber]
        XCTAssertEqual(array, [
            NSDecimalNumber(string: "0.05"),
            NSDecimalNumber(string: "0.1"),
            NSDecimalNumber(string: "0.5"),
        ])
    }

    func testDictionaryPreservingDecimals_preservesDeeplyNestedObjects() throws {
        let json = """
        { "a": { "b": { "c": [ { "increment": 0.05 } ] } } }
        """
        let dict = try Functions.dictionaryPreservingDecimals(from: json)
        let a = dict["a"] as? [String: Any]
        let b = a?["b"] as? [String: Any]
        let c = b?["c"] as? [[String: Any]]
        XCTAssertEqual(c?.first?["increment"] as? NSDecimalNumber, NSDecimalNumber(string: "0.05"))
    }

    // MARK: - Error handling

    func testDictionaryPreservingDecimals_throwsOnInvalidJSON() {
        XCTAssertThrowsError(try Functions.dictionaryPreservingDecimals(from: #"{"v":"#))
    }

    func testDictionaryPreservingDecimals_throwsOnNonObjectRoot() {
        XCTAssertThrowsError(try Functions.dictionaryPreservingDecimals(from: "[1, 2, 3]"))
    }

    // MARK: - Round-trip through Functions.jsonString

    func testDictionaryPreservingDecimals_roundTripPreservesDecimalsInJSONString() throws {
        let input = """
        {
          "ranges": [
            { "min": 0, "max": 1, "increment": 0.05 },
            { "min": 1, "max": 5, "increment": 0.1 },
            { "min": 5, "max": 20, "increment": 0.5 }
          ]
        }
        """
        let parsed = try Functions.dictionaryPreservingDecimals(from: input)
        let written = try Functions.jsonString(from: parsed)

        XCTAssertTrue(written.contains("\"increment\":0.05"), written)
        XCTAssertTrue(written.contains("\"increment\":0.1"), written)
        XCTAssertTrue(written.contains("\"increment\":0.5"), written)

        XCTAssertFalse(written.contains("0.050000000000000003"), written)
        XCTAssertFalse(written.contains("0.10000000000000001"), written)
    }
}
