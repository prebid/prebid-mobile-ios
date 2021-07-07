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

@testable import PrebidMobileRendering

class NativeAssetVideoTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let title = NativeAssetVideo(mimeTypes: ["image/png","image/jpeg"],
                                        minDuration: 29,
                                        maxDuration: 42,
                                        protocols: [1,2,5])
        title.required = 1
        try! title.setAssetExt(["topKey": "topVal"])
        try! title.setVideoExt(["boxedKey": "boxedVal"])
        title.assetID = 42
        let clone = title.copy() as! NativeAssetVideo
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "video": [
                "mimes": ["image/png","image/jpeg"],
                "minDuration": 29,
                "maxDuration": 42,
                "protocols": [1,2,5],
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertEqual(try? clone.toJsonString(), """
{"ext":{"topKey":"topVal"},"id":42,"required":1,"video":{"ext":{"boxedKey":"boxedVal"},"maxDuration":42,"mimes":["image\\/png","image\\/jpeg"],"minDuration":29,"protocols":[1,2,5]}}
""")
    }
}
