/*   Copyright 2018-2023 Prebid.org, Inc.

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

class StringExtensionsTest: XCTestCase {
    
    func testEncodeURL() {
        let str1 = "https://example.com/search?q=Prebid mobile&page=1"
        let encodedStr1 = str1.encodedURL(with: .urlQueryAllowed)?.absoluteString
        
        XCTAssertNotEqual(str1, encodedStr1)
        XCTAssertTrue(encodedStr1!.contains("%20"))
        
        let str2 = "https://example.com/search?q=Prebid%20mobile&page=1"
        let encodedStr2 = str2.encodedURL(with: .urlQueryAllowed)?.absoluteString
        
        XCTAssertEqual(str2, encodedStr2)
    }
    
    func testRegexMatches() {
        var result = "aaa aaa".matches(for: "^a")
        XCTAssert(result.count == 1)
        XCTAssert(result[0] == "a")
        
        result = "aaa aaa".matches(for: "^b")
        XCTAssert(result.count == 0)
        
        result = "^a".matches(for: "aaa aaa")
        XCTAssert(result.count == 0)
        
        result = "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"1x1\"],moPubResponse:\"hb_size:300x250\" \n }".matches(for: "[0-9]+x[0-9]+")
        XCTAssert(result.count == 3)
        XCTAssert(result[0] == "728x90")
        XCTAssert(result[1] == "1x1")
        XCTAssert(result[2] == "300x250")
        
        result = "{ \n adManagerResponse:\"hb_size\":[\"728x90\"],\"hb_size_rubicon\":[\"1x1\"],moPubResponse:\"hb_size:300x250\" \n }".matches(for: "hb_size\\W+[0-9]+x[0-9]+")
        
        XCTAssert(result.count == 2)
        XCTAssert(result[0] == "hb_size\":[\"728x90")
        XCTAssert(result[1] == "hb_size:300x250")
    }
    
    func testRegexMatchAndCheck() {
        var result = "aaa aaa".matchAndCheck(regex: "^a")
        
        XCTAssertNotNil(result)
        XCTAssert(result == "a")
        
        result = "aaa aaa".matchAndCheck(regex: "^b")
        XCTAssertNil(result)
    }
}
