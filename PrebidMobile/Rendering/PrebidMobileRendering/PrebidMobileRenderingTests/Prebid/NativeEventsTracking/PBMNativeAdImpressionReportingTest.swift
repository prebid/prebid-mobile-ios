//
//  PBMNativeAdImpressionReportingTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering


class PBMNativeAdImpressionReportingTest: XCTestCase {
    private let trackers: [PBMNativeAdMarkupEventTracker] = [
        .init(event: NativeEventType.impression.rawValue, method: NativeEventTrackingMethod.img.rawValue, url: "Imp-Img"),
        
        .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.img.rawValue, url: "MRC50-ImgA"),
        .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.img.rawValue, url: "MRC50-ImgZ"),
        .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "MRC50-JS"),
        .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.img.rawValue, url: "MRC50-ImgQ"),
        .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod(rawValue: 555)?.rawValue ?? 42, url: "MRC50-OM"),
        
        .init(event: 700, method: NativeEventTrackingMethod.img.rawValue, url: "700-Img"),
    ]
    
    func testSingleTracker() {
        let urlsTracked = expectation(description: "URLs tracked")
        let detectionHandler = PBMNativeAdImpressionReporting.impressionReporter(with: trackers) { urlStrings in
            urlsTracked.fulfill()
            XCTAssertEqual(urlStrings, ["Imp-Img"])
        }
        detectionHandler(NativeEventType.impression.rawValue)
        waitForExpectations(timeout: 1)
        let additionalTimeout = expectation(description: "no more new events")
        additionalTimeout.isInverted = true
        waitForExpectations(timeout: 1)
    }
    
    func testNoTracker() {
        let urlsTracked = expectation(description: "URLs tracked")
        let detectionHandler = PBMNativeAdImpressionReporting.impressionReporter(with: trackers) { urlStrings in
            urlsTracked.fulfill()
            XCTAssertEqual(urlStrings, [])
        }
        detectionHandler(NativeEventType.video50.rawValue)
        waitForExpectations(timeout: 1)
        let additionalTimeout = expectation(description: "no more new events")
        additionalTimeout.isInverted = true
        waitForExpectations(timeout: 1)
    }
    
    func testMultipleTrackers() {
        let urlsTracked = expectation(description: "URLs tracked")
        let detectionHandler = PBMNativeAdImpressionReporting.impressionReporter(with: trackers) { urlStrings in
            urlsTracked.fulfill()
            XCTAssertEqual(urlStrings, ["MRC50-ImgA", "MRC50-ImgZ", "MRC50-ImgQ"])
        }
        detectionHandler(NativeEventType.mrc50.rawValue)
        waitForExpectations(timeout: 1)
        let additionalTimeout = expectation(description: "no more new events")
        additionalTimeout.isInverted = true
        waitForExpectations(timeout: 1)
    }
    
    func testUnknownEvent() {
        // Note:
        // The section being tested should properly handle all events
        // Though such events might never be detected by embedded detectors
        
        let urlsTracked = expectation(description: "URLs tracked")
        let detectionHandler = PBMNativeAdImpressionReporting.impressionReporter(with: trackers) { urlStrings in
            urlsTracked.fulfill()
            XCTAssertEqual(urlStrings, ["700-Img"])
        }
        detectionHandler(700)
        waitForExpectations(timeout: 1)
        let additionalTimeout = expectation(description: "no more new events")
        additionalTimeout.isInverted = true
        waitForExpectations(timeout: 1)
    }
}
