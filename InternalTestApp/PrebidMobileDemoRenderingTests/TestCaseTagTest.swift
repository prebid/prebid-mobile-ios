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

@testable import InternalTestApp

class TestCaseTagTest: XCTestCase {
    
    let testEmptyTags: [TestCaseTag] = []
    
    func testExtractAppearances() {
        XCTAssertEqual(TestCaseTag.extractAppearances(from: testEmptyTags), testEmptyTags)
        XCTAssertEqual(TestCaseTag.extractAppearances(from: TestCaseTag.appearance), TestCaseTag.appearance.sorted(by: <=))
        
        XCTAssertEqual(TestCaseTag.extractAppearances(from: [.banner, .interstitial, .video]), [.banner, .interstitial, .video])
        XCTAssertEqual(TestCaseTag.extractAppearances(from: [.banner]), [.banner])
        XCTAssertEqual(TestCaseTag.extractAppearances(from: [.server]), testEmptyTags)
    }
    
    func testExtractConnections() {
        XCTAssertEqual(TestCaseTag.extractConnections(from: testEmptyTags), testEmptyTags)
        XCTAssertEqual(TestCaseTag.extractConnections(from: TestCaseTag.connections), TestCaseTag.connections.sorted(by: <=))
        
        XCTAssertEqual(TestCaseTag.extractConnections(from: [.server, .interstitial]), [.server])
        XCTAssertEqual(TestCaseTag.extractConnections(from: [.banner, .interstitial]), testEmptyTags)
    }
    
    func testExtractIntegrations() {
        XCTAssertEqual(TestCaseTag.extractIntegrations(from: [.inapp, .gam]), [.gam, .inapp])
    }
    
    func testCollectTags() {
        XCTAssertEqual(TestCaseTag.collectTags(from: testEmptyTags, in: testEmptyTags), testEmptyTags)
        XCTAssertEqual(TestCaseTag.collectTags(from: [], in: testEmptyTags), testEmptyTags)
        XCTAssertEqual(TestCaseTag.collectTags(from: [.banner], in: [.server] ), testEmptyTags)
    }
}
