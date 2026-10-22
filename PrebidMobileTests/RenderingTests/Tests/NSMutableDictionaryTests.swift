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

class NSMutableDictionaryTests: XCTestCase {

    func testPBMRemoveEmptyVals() {
        let initial = NSMutableDictionary()
        let filtered = initial.pbmCopyWithoutEmptyVals()
        XCTAssertEqual(filtered.count, 0)
        XCTAssertEqual(initial, filtered)
        XCTAssertFalse(filtered === initial)

        let fullValues: [String: Any] = ["1": "1", "2": "2", "3": "3"]
        let initialFullValues = NSMutableDictionary(dictionary: fullValues)
        XCTAssertEqual(initialFullValues.pbmCopyWithoutEmptyVals(), NSMutableDictionary(dictionary: fullValues))

        let filteredFullValues = initialFullValues.mutableCopy() as! NSMutableDictionary
        filteredFullValues.pbmRemoveEmptyVals()
        XCTAssertEqual(filteredFullValues, NSMutableDictionary(dictionary: fullValues))

        // NSNull is an empty value
        let initialValuesWithNull = NSMutableDictionary(dictionary: ["1": "1", "2": NSNull(), "3": "3"])
        XCTAssertEqual(initialValuesWithNull.pbmCopyWithoutEmptyVals(), NSMutableDictionary(dictionary: ["1": "1", "3": "3"]))
        initialValuesWithNull.pbmRemoveEmptyVals()
        XCTAssertEqual(initialValuesWithNull, NSMutableDictionary(dictionary: ["1": "1", "3": "3"]))

        // Arrays are kept, empty or not (playbook Gap 9)
        let valuesWithArray: [String: Any] = ["1": "1", "2": ["2"], "3": "3"]
        XCTAssertEqual(NSMutableDictionary(dictionary: valuesWithArray).pbmCopyWithoutEmptyVals(), NSMutableDictionary(dictionary: valuesWithArray))

        let valuesWithEmptyArray: [String: Any] = ["1": "1", "2": [String](), "3": "3"]
        XCTAssertEqual(NSMutableDictionary(dictionary: valuesWithEmptyArray).pbmCopyWithoutEmptyVals(), NSMutableDictionary(dictionary: valuesWithEmptyArray))
    }
}
