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

class NativeAssetImageTest: XCTestCase {
    func testDesignatedInitAndToJsonString() {
        let image = NativeAssetImage()
        image.imageType = NativeImageAssetType.main.rawValue as NSNumber
        image.width = 120
        image.height = 240
        image.widthMin = 96
        image.heightMin = 128
        image.mimeTypes = ["image/png","image/jpeg"]
        image.required = 1
        try! image.setAssetExt(["topKey": "topVal"])
        try! image.setImageExt(["boxedKey": "boxedVal"])
        image.assetID = 42
        let clone = image.copy() as! NativeAssetImage
        XCTAssertEqual(clone.jsonDictionary as NSDictionary?, [
            "id": 42,
            "required": 1,
            "img": [
                "type": 3,
                "w": 120,
                "h": 240,
                "wmin": 96,
                "hmin": 128,
                "mimes": [
                    "image/png",
                    "image/jpeg",
                ],
                "ext": ["boxedKey": "boxedVal"],
            ],
            "ext": ["topKey": "topVal"],
        ] as NSDictionary)
        XCTAssertEqual(try? clone.toJsonString(), """
{"ext":{"topKey":"topVal"},"id":42,"img":{"ext":{"boxedKey":"boxedVal"},"h":240,"hmin":128,"mimes":["image\\/png","image\\/jpeg"],"type":3,"w":120,"wmin":96},"required":1}
""")
    }
}
