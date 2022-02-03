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

class NativeTitleTests: XCTestCase {
    func testInitFromJson() {
        let titleDict: [String: Any] = [
            "text": "test text",
            "len": 9,
            "ext": ["la": "ks"]
        ]
        
        let expectedTitle = NativeTitle()
        expectedTitle.text = "test text"
        expectedTitle.length = 9
        expectedTitle.ext = ["la": "ks"]
        
        let resultTitle = NativeTitle(jsonDictionary: titleDict)
        
        XCTAssertTrue(expectedTitle == resultTitle)
    }
}

extension NativeTitle {
    static func ==(lhs: NativeTitle, rhs: NativeTitle) -> Bool {
        return lhs.text == rhs.text &&
        lhs.length == rhs.length &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
