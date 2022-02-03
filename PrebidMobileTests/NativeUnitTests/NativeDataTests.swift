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
@testable import PrebidMobile

class NativeDataTests: XCTestCase {
    func testInitFromJson() {
        let dataDict: [String: Any] = [
            "type": 1,
            "len": 5,
            "value": "hello",
            "ext": ["la": "ks"]
        ]
        
        let expectedData = NativeData()
        expectedData.type = 1
        expectedData.length = 5
        expectedData.value = "hello"
        expectedData.ext = ["la": "ks"]
        
        let resultData = NativeData(jsonDictionary: dataDict)
        
        XCTAssertTrue(expectedData == resultData)
    }
}

extension NativeData {
    static func ==(lhs: NativeData, rhs: NativeData) -> Bool {
        return lhs.type == rhs.type &&
        lhs.length == rhs.length &&
        lhs.value == rhs.value &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
