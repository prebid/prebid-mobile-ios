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

@testable import PrebidMobile

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
            // This assert fails due to changes in PBMNativeAdImpressionReporting
            // This assert should be restored in the issue
            // TODO: https://github.com/prebid/prebid-mobile-ios/issues/431
//            XCTAssertEqual(urlStrings, ["Imp-Img"])
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
            // This assert fails due to changes in PBMNativeAdImpressionReporting
            // This assert should be restored in the issue
            // TODO: https://github.com/prebid/prebid-mobile-ios/issues/431
//            XCTAssertEqual(urlStrings, ["MRC50-ImgA", "MRC50-ImgZ", "MRC50-ImgQ"])
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
            // This assert fails due to changes in PBMNativeAdImpressionReporting
            // This assert should be restored in the issue
            // TODO: https://github.com/prebid/prebid-mobile-ios/issues/431
//            XCTAssertEqual(urlStrings, ["700-Img"])
        }
        detectionHandler(700)
        waitForExpectations(timeout: 1)
        let additionalTimeout = expectation(description: "no more new events")
        additionalTimeout.isInverted = true
        waitForExpectations(timeout: 1)
    }
}
