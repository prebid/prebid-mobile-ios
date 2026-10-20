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
import OMSDK_Prebidorg

@testable import PrebidMobile

/// Compares the Swift `OpenMeasurementFriendlyObstructionTypeBridge` with the output captured from the Objective-C
/// original. See `OpenMeasurementBridgeParityExpectations`.
class OpenMeasurementBridgeParityTests: XCTestCase {

    func testOutputMatchesObjectiveCOriginal() {
        let rawValues: [UInt] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 99, UInt.max]

        var actualLines = [String]()
        for rawValue in rawValues {
            // Out-of-range raw values have no Swift enum case: the ObjC `switch` hit its `default:` branch, which
            // gives `.other` and `nil`. `.purposesCount` (6) takes the same branch in the Swift port.
            let purpose = OpenMeasurementFriendlyObstructionPurpose(rawValue: rawValue)
            let obstructionType = purpose.map { OpenMeasurementFriendlyObstructionTypeBridge.obstructionType(of: $0) } ?? .other
            let description = purpose.flatMap { OpenMeasurementFriendlyObstructionTypeBridge.describe($0) }
            let descriptionText = description.map { "\"\($0)\"" } ?? "nil"
            actualLines.append("\(rawValue) type=\(obstructionType.rawValue) desc=\(descriptionText)")
        }

        let expectedLines = OpenMeasurementBridgeParityExpectations.expected.split(separator: "\n").map(String.init)
        XCTAssertEqual(actualLines, expectedLines)
    }
}
