/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http:www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import Foundation
import XCTest

class PBMOpenMeasurementFriendlyObstructionTypeBridgeTest: XCTestCase {
    
    func testDetailedPurposeStrings() {
        for i: UInt in 0..<OpenMeasurementFriendlyObstructionPurpose.purposesCount.rawValue {
            guard let purpose = OpenMeasurementFriendlyObstructionPurpose(rawValue: i) else {
                break
            }
            guard let detailedPurpose = (PBMOpenMeasurementFriendlyObstructionTypeBridge.describe(purpose) as String?), !detailedPurpose.isEmpty else {
                XCTFail("No detailedPurpose for purpose \(i)");
                continue
            }
            validate(detailedPurpose: detailedPurpose)
        }
    }
    
    private func validate(detailedPurpose: String) {
        XCTAssert(detailedPurpose.count <= 50, "\"\(detailedPurpose)\" is too long (\(detailedPurpose.count))! May only be no longer than 50 characters!")
        for char in Set(detailedPurpose) {
            switch char {
            case "a"..."z", "A"..."Z", "0"..."9", " ":
                break;
            default:
                XCTFail("Character '\(char)' is not allowed in detailed purpose (\"\(detailedPurpose)\")!")
            }
        }
    }
}
