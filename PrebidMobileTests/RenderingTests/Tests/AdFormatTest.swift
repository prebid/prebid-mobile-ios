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
    
    // MARK: - Equality
    
    func testEqualityIsBasedOnRawValue() {
        XCTAssertEqual(AdFormat(rawValue: 1 << 0), AdFormat.banner)
        XCTAssertEqual(AdFormat(rawValue: 1 << 1), AdFormat.video)
        XCTAssertEqual(AdFormat(rawValue: 1 << 2), AdFormat.native)
        XCTAssertNotEqual(AdFormat.banner, AdFormat.video)
        XCTAssertTrue(AdFormat.banner.isEqual(AdFormat(rawValue: 1 << 0)))
        XCTAssertFalse(AdFormat.banner.isEqual(nil))
        XCTAssertFalse(AdFormat.banner.isEqual(NSNumber(value: 1)))
    }
    
    func testHashMatchesForEqualValues() {
        XCTAssertEqual(AdFormat(rawValue: 1 << 0).hash, AdFormat.banner.hash)
        XCTAssertEqual(AdFormat(rawValue: 1 << 0).hashValue, AdFormat.banner.hashValue)
    }
    
    func testSetTreatsEqualRawValuesAsOneElement() {
        let set: Set<AdFormat> = [AdFormat(rawValue: 1 << 0), AdFormat(rawValue: 1 << 0), .banner]
        XCTAssertEqual(set.count, 1)
        XCTAssertTrue(set.contains(.banner))
        
        let publisherSet: Set<AdFormat> = [AdFormat(rawValue: 1 << 0), AdFormat(rawValue: 1 << 1)]
        XCTAssertTrue(publisherSet.contains(.banner))
        XCTAssertTrue(publisherSet.contains(.video))
        XCTAssertEqual(publisherSet, [.banner, .video])
    }
    
    func testNSSetContainsObjectUsesRawValue() {
        let nsSet = NSSet(array: [AdFormat(rawValue: 1 << 1)])
        XCTAssertTrue(nsSet.contains(AdFormat.video))
        XCTAssertFalse(nsSet.contains(AdFormat.banner))
    }
    
    func testValidatedAcceptsPublisherConstructedFormats() {
        XCTAssertEqual(AdFormat.validated([AdFormat(rawValue: 1 << 1)], supported: supported), [.video])
    }
    
    func testCombinedRawValueIsNotASingleFormat() {
        let combined = AdFormat.banner.union(.video)
        XCTAssertNotEqual(combined, AdFormat.banner)
        XCTAssertNotEqual(combined, AdFormat.video)
        XCTAssertNil(AdFormat.validated([combined], supported: supported),
                     "A combined bitmask is not a supported single format and must be rejected")
    }
}
