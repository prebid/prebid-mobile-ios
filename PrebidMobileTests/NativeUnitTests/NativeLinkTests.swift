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

class NativeLinkTests: XCTestCase {
    func testInitFromJson() {
        let linkDict = [
            "fallback": "fallback-url",
            "clicktrackers": ["first-clicktracker", "Last Clicktracker"],
            "url": "link url",
            "ext": ["la": "lb"],
        ] as [String : Any]
        
        let expectedLinkObject = NativeLink()
        expectedLinkObject.fallback = "fallback-url"
        expectedLinkObject.clicktrackers = ["first-clicktracker", "Last Clicktracker"]
        expectedLinkObject.url = "link url"
        expectedLinkObject.ext = ["la": "lb"]
        
        let resultLinkObject = NativeLink(jsonDictionary: linkDict)
        
        XCTAssertTrue(expectedLinkObject == resultLinkObject)
    }
}

extension NativeLink {
    static func ==(lhs: NativeLink, rhs: NativeLink) -> Bool {
        return lhs.url == rhs.url &&
        lhs.clicktrackers == rhs.clicktrackers &&
        lhs.fallback == rhs.fallback &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
