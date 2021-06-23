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

class NativeAssetTitleTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let title = NativeAssetTitle(length: 25)
        title.required = true
        try! title.setAssetExt(["topKey": "topVal"])
        try! title.setTitleExt(["boxedKey": "boxedVal"])
        title.assetID = 42
        let clone = title.copy() as! NativeAssetTitle
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "title": [
                "len": 25,
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertNoThrow {
            XCTAssertEqual(try clone.toJsonString(), """
{"ext":{"topKey":"topVal"},"id":42,"required":1,"title":{"ext":{"boxedKey":"boxedVal"},"len":25}}
""")
        }
    }
}
