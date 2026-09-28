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
@testable import PrebidMobile

class RawExtendedIdTests: XCTestCase {

    func testValidJSON() throws {
        let json: [String: Any] = [
            "source": "id5-sync.com",
            "uids": [["id": "abc", "atype": 1]]
        ]

        let eid = try XCTUnwrap(RawExtendedId(json: json))

        XCTAssertEqual(eid.source, "id5-sync.com")
        XCTAssertEqual(eid.toJSONDictionary() as NSDictionary, json as NSDictionary)
    }

    func testMissingSourceFails() {
        XCTAssertNil(RawExtendedId(json: ["uids": [["id": "abc", "atype": 1]]]))
    }

    func testEmptySourceFails() {
        XCTAssertNil(RawExtendedId(json: ["source": ""]))
    }

    func testNonStringSourceFails() {
        XCTAssertNil(RawExtendedId(json: ["source": NSNull()]))
        XCTAssertNil(RawExtendedId(json: ["source": 123]))
    }

    func testJSONThatCantBeEncodedFails() {
        XCTAssertNil(RawExtendedId(json: ["source": "id5-sync.com", "uids": [["id": Date()]]]))
    }
}
