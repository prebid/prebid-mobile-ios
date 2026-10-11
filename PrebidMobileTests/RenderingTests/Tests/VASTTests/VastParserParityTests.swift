/*   Copyright 2018-2025 Prebid.org, Inc.

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

@_spi(PBMInternal) @testable import PrebidMobile

/// Checks the fully parsed model of every VAST fixture (and a set of synthetic documents) against the output the
/// Objective-C parser produced. See `VastParserParityExpectations`.
class VastParserParityTests: XCTestCase {

    func testParsedModelMatchesObjectiveCParserOutput() {
        let cases = VastParserParityCases.allCases()

        XCTAssertEqual(Set(cases.map { $0.name }), Set(VastParserParityExpectations.expected.keys),
                       "Every case needs an expectation and vice versa")

        for testCase in cases {
            guard let data = testCase.data else {
                XCTFail("Could not load fixture \(testCase.name)")
                continue
            }

            let actual = VastModelDump.dump(VastParser().parseAdsResponse(data))
            XCTAssertEqual(actual, VastParserParityExpectations.expected[testCase.name], "Parsed model differs for \(testCase.name)")
        }
    }
}
