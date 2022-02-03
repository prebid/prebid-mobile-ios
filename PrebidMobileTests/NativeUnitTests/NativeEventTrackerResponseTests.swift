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

class NativeEventTrackerResponseTests: XCTestCase {
    func testInitFromJson() {
        let trackersDict: [String: Any] = [
            "event": 1,
            "method": 1,
            "url": "test url",
            "customdata": ["ld": "sk"],
            "ext": ["la": "ks"]
        ]
        
        let expectedTrackers = NativeEventTrackerResponse()
        expectedTrackers.event = 1
        expectedTrackers.method = 1
        expectedTrackers.url = "test url"
        expectedTrackers.customdata = ["ld": "sk"]
        expectedTrackers.ext = ["la": "ks"]
        
        let resultTrackers = NativeEventTrackerResponse(jsonDictionary: trackersDict)
        
        XCTAssertTrue(expectedTrackers == resultTrackers)
    }
}

extension NativeEventTrackerResponse {
    static func ==(lhs: NativeEventTrackerResponse, rhs: NativeEventTrackerResponse) -> Bool {
        return lhs.event == rhs.event &&
        lhs.method == rhs.method &&
        lhs.url == rhs.url &&
        NSDictionary(dictionary: lhs.customdata ?? [:]).isEqual(to: rhs.customdata ?? [:]) &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
