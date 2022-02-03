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

class NativeImageTests: XCTestCase {
    func testInitFromJson() {
        let imageDict: [String: Any] = [
            "type": 1,
            "url": "test url",
            "w": 320,
            "h": 50,
            "ext": ["la": "ks"]
        ]
        
        let expectedImage = NativeImage()
        expectedImage.type = 1
        expectedImage.url = "test url"
        expectedImage.width = 320
        expectedImage.height = 50
        expectedImage.ext = ["la": "ks"]
        
        let resultImage = NativeImage(jsonDictionary: imageDict)
        
        XCTAssertTrue(expectedImage == resultImage)
    }
}

extension NativeImage {
    static func ==(lhs: NativeImage, rhs: NativeImage) -> Bool {
        return lhs.type == rhs.type &&
        lhs.url == rhs.url &&
        lhs.width == rhs.width &&
        lhs.height == rhs.height &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
