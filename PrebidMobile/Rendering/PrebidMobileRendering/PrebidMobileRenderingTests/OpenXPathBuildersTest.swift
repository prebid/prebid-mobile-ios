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

class OpenXPathBuildersTest: XCTestCase {
    
    func testBaseURKPathBuilderBase() {
        XCTAssertEqual(PBMPathBuilder.buildBaseURL(forDomain: "d1"), "https://d1")
        XCTAssertEqual(PBMPathBuilder.buildBaseURL(forDomain: ""), "https://")
        XCTAssertEqual(PBMPathBuilder.buildBaseURL(forDomain: "😃"), "https://😃")
    }

    func testURLPathBuilderBase() {
        XCTAssertEqual(PBMPathBuilder.buildURLPath(forDomain: "d1", path: "tt"), "https://d1/tt/1.0/")
        XCTAssertEqual(PBMPathBuilder.buildURLPath(forDomain: "", path: "ma"), "https:///ma/1.0/")
        XCTAssertEqual(PBMPathBuilder.buildURLPath(forDomain: "😃", path: "v"), "https://😃/v/1.0/")
    }

    func testACJPathBuilder() {
        XCTAssertEqual(PBMPathBuilder.buildACJURLPath(forDomain: "d1"), "https://d1/ma/1.0/acj")
        XCTAssertEqual(PBMPathBuilder.buildACJURLPath(forDomain: ""), "https:///ma/1.0/acj")
        XCTAssertEqual(PBMPathBuilder.buildACJURLPath(forDomain: "😃"), "https://😃/ma/1.0/acj")
    }
    
    func testVASTPathBuilder() {
        XCTAssertEqual(PBMPathBuilder.buildVASTURLPath(forDomain: "d1"), "https://d1/v/1.0/av")
        XCTAssertEqual(PBMPathBuilder.buildVASTURLPath(forDomain: ""), "https:///v/1.0/av")
        XCTAssertEqual(PBMPathBuilder.buildVASTURLPath(forDomain: "😃"), "https://😃/v/1.0/av")
    }
}
