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

class NativeAssetDataTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let data = NativeAssetData(dataType: .desc)
        data.length = 25
        data.required = true
        try! data.setAssetExt(["topKey": "topVal"])
        try! data.setDataExt(["boxedKey": "boxedVal"])
        data.assetID = 42
        let clone = data.copy() as! NativeAssetData
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "data": [
                "type": 2,
                "len": 25,
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertNoThrow {
            XCTAssertEqual(try clone.toJsonString(), """
{"data":{"ext":{"boxedKey":"boxedVal"},"len":25,"type":2},"ext":{"topKey":"topVal"},"id":42,"required":1}
""")
        }
    }
}
