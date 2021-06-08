//
//  NativeAdEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAdEventTrackerTest: XCTestCase {
    func testInitFromMarkup() {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkupEventTracker, NativeAdEventTracker>, Error)] = []

        let optionalEventTrackerProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkupEventTracker, NativeAdEventTracker>] = [
            // MARK: - EventTracker properties
            Decoding.OptionalPropertyCheck(value: .impression,
                                           writer: { $0.event = $1.rawValue },
                                           reader: { ($0.event == NativeEventType.mrc50) ? nil : $0.event }),
            Decoding.OptionalPropertyCheck(value: NativeEventTrackingMethod.img.rawValue,
                                           writer: { $0.method = $1 },
                                           reader: { ($0.method == NativeEventTrackingMethod.js.rawValue) ? nil : $0.method }),
            Decoding.OptionalPropertyCheck(value: "some url",
                                           writer: { $0.url = $1 },
                                           reader: { ($0.url == "") ? nil : $0.url }),
            Decoding.OptionalPropertyCheck(value: ["a": "b"] as NSDictionary,
                                           writer: { $0.customdata = $1 as? [String: Any] },
                                           reader: { $0.customdata as NSDictionary? }),
            Decoding.OptionalPropertyCheck(value: ["x": "y"] as NSDictionary,
                                           writer: { $0.ext = $1 as? [String: Any] },
                                           reader: { $0.ext as NSDictionary? }),
        ]
        
        let eventTrackerTester = Decoding.Tester(template: PBMNativeAdMarkupEventTracker(event: NativeEventType.mrc50.rawValue,
                                                                                         method: NativeEventTrackingMethod.js.rawValue,
                                                                                         url: ""),
                                                 generator: NativeAdEventTracker.init(nativeAdMarkupEventTracker:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalEventTrackerProperties)
        eventTrackerTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")),
                          NSObject())
        XCTAssertEqual(NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")),
                       NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")))
        XCTAssertEqual(NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc100.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")),
                       NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc100.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")))
        XCTAssertNotEqual(NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")),
                          NativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: NativeEventType.mrc100.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "")))
    }
}


