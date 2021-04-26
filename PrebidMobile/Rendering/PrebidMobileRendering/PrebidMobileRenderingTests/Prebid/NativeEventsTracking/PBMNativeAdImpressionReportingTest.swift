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
        .init(event: .impression, method: .img, url: "Imp-Img"),
        
        .init(event: .MRC50, method: .img, url: "MRC50-ImgA"),
        .init(event: .MRC50, method: .img, url: "MRC50-ImgZ"),
        .init(event: .MRC50, method: .JS, url: "MRC50-JS"),
        .init(event: .MRC50, method: .img, url: "MRC50-ImgQ"),
        .init(event: .MRC50, method: PBMNativeEventTrackingMethod(rawValue: 555)!, url: "MRC50-OM"),
        
        .init(event: PBMNativeEventType(rawValue: 700)!, method: .img, url: "700-Img"),
    ]
    
    func testSingleTracker() {
        let urlsTracked = expectation(description: "URLs tracked")
        let detectionHandler = PBMNativeAdImpressionReporting.impressionReporter(with: trackers) { urlStrings in
            urlsTracked.fulfill()
            XCTAssertEqual(urlStrings, ["Imp-Img"])
        }
        detectionHandler(.impression)
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
        detectionHandler(.video50)
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
        detectionHandler(.MRC50)
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
        detectionHandler(PBMNativeEventType(rawValue: 700)!)
        waitForExpectations(timeout: 1)
        let additionalTimeout = expectation(description: "no more new events")
        additionalTimeout.isInverted = true
        waitForExpectations(timeout: 1)
    }
}
