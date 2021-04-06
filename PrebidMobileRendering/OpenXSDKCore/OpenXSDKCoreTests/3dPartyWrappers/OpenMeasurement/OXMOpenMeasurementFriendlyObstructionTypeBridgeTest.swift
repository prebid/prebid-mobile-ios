//
//  OXMOpenMeasurementFriendlyObstructionTypeBridgeTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

class OXMOpenMeasurementFriendlyObstructionTypeBridgeTest: XCTestCase {
    
    func testDetailedPurposeStrings() {
        for i: UInt in 0..<OXMOpenMeasurementFriendlyObstructionPurpose._PurposesCount.rawValue {
            guard let purpose = OXMOpenMeasurementFriendlyObstructionPurpose(rawValue: i) else {
                break
            }
            guard let detailedPurpose = (OXMOpenMeasurementFriendlyObstructionTypeBridge.describe(purpose) as String?), !detailedPurpose.isEmpty else {
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
