//
//  PBMTrackingRecordTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMTrackingRecordTest: XCTestCase {
    
    func testDefaultValues() {
        let record = TrackingRecord(trackingType:"test", trackingURL:"test")
        XCTAssertEqual(record.trackingURL, "test")
        XCTAssertEqual(record.trackingType, "test")
    }
    
}
