/*   Copyright 2018-2019 Prebid.org, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
f
http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import XCTest
import PrebidMobile

class NativeAdMarkupTest: XCTestCase {
    func testInitFromJson() {
        let linkDic: [String: Any] = [
            "fallback": "fallback-url",
            "clicktrackers": ["first-clicktracker", "Last Clicktracker"],
            "url": "link url",
            "ext": ["la": "lb"],
        ]
        
        let linkObject = NativeLink(jsonDictionary: linkDic)
            
        let markupDict: [String: Any] = [
            "ver": "1.0",
            "assetsurl": "test assetsurl",
            "dcourl": "test dcourl",
            "link" : linkDic,
            "imptrackers": ["imptrackers 1", "imptrackers 2"],
            "jstracker": "test jstracker",
            "privacy": "test privacy",
            "ext": ["ls": "as"]
        ]
        
        let expectedMarkup = NativeAdMarkup()
        expectedMarkup.version = "1.0"
        expectedMarkup.assetsurl = "test assetsurl"
        expectedMarkup.dcourl = "test dcourl"
        expectedMarkup.link = linkObject
        expectedMarkup.imptrackers = ["imptrackers 1", "imptrackers 2"]
        expectedMarkup.jstracker = "test jstracker"
        expectedMarkup.privacy = "test privacy"
        expectedMarkup.ext = ["ls": "as"]
        
        let resultMarkup = NativeAdMarkup(jsonDictionary: markupDict)
        
        XCTAssertTrue(expectedMarkup == resultMarkup)
    }
}


extension NativeAdMarkup {
    static func ==(lhs: NativeAdMarkup, rhs: NativeAdMarkup) -> Bool {
        return lhs.version == rhs.version &&
        lhs.assetsurl == rhs.assetsurl &&
        lhs.dcourl == rhs.dcourl &&
        lhs.link?.url == rhs.link?.url &&
        lhs.link?.clicktrackers == rhs.link?.clicktrackers &&
        lhs.link?.fallback == rhs.link?.fallback &&
        NSDictionary(dictionary: lhs.link?.ext ?? [:]).isEqual(to: rhs.link?.ext ?? [:]) &&
        lhs.imptrackers == rhs.imptrackers &&
        lhs.jstracker == rhs.jstracker &&
        lhs.privacy == rhs.privacy &&
        NSDictionary(dictionary: lhs.ext ?? [:]).isEqual(to: rhs.ext ?? [:])
    }
}
