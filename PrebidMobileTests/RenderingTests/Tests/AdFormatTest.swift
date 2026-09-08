/*   Copyright 2018-2021 Prebid.org, Inc.

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

class AdFormatTest: XCTestCase {
    
    private let supported: [AdFormat] = [.banner, .video]
    
    func testValidatedAcceptsSupportedSets() {
        XCTAssertEqual(AdFormat.validated([.banner], supported: supported), [.banner])
        XCTAssertEqual(AdFormat.validated([.video], supported: supported), [.video])
        XCTAssertEqual(AdFormat.validated([.banner, .video], supported: supported), [.banner, .video])
        XCTAssertEqual(AdFormat.validated([.native], supported: [.native]), [.native])
    }
    
    func testValidatedRejectsEmptySet() {
        XCTAssertNil(AdFormat.validated([], supported: supported))
    }
    
    func testValidatedRejectsUnsupportedFormats() {
        XCTAssertNil(AdFormat.validated([.native], supported: supported),
                     "Unsupported-only set must be rejected")
        XCTAssertNil(AdFormat.validated([.banner, .native], supported: supported),
                     "Partially unsupported set must be rejected as a whole")
    }
}
