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
}
