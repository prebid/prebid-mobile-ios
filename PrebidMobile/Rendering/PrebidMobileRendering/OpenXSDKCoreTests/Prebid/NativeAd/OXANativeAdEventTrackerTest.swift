//
//  OXANativeAdEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAdEventTrackerTest: XCTestCase {
    func testInitFromMarkup() {
        let requiredProperties: [(Decoding.PropertyCheck<OXANativeAdMarkupEventTracker, OXANativeAdEventTracker>, Error)] = []

        let optionalEventTrackerProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkupEventTracker, OXANativeAdEventTracker>] = [
            // MARK: - EventTracker properties
            Decoding.OptionalPropertyCheck(value: .impression,
                                           writer: { $0.event = $1 },
                                           reader: { ($0.event == .MRC50) ? nil : $0.event }),
            Decoding.OptionalPropertyCheck(value: .img,
                                           writer: { $0.method = $1 },
                                           reader: { ($0.method == .JS) ? nil : $0.method }),
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
        
        let eventTrackerTester = Decoding.Tester(template: OXANativeAdMarkupEventTracker(event: .MRC50,
                                                                                         method: .JS,
                                                                                         url: ""),
                                                 generator: OXANativeAdEventTracker.init(nativeAdMarkupEventTracker:),
                                                 requiredPropertyChecks: requiredProperties,
                                                 optionalPropertyChecks: optionalEventTrackerProperties)
        eventTrackerTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC50, method: .JS, url: "")),
                          NSObject())
        XCTAssertEqual(OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC50, method: .JS, url: "")),
                       OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC50, method: .JS, url: "")))
        XCTAssertEqual(OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC100, method: .JS, url: "")),
                       OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC100, method: .JS, url: "")))
        XCTAssertNotEqual(OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC50, method: .JS, url: "")),
                          OXANativeAdEventTracker(nativeAdMarkupEventTracker: .init(event: .MRC100, method: .JS, url: "")))
    }
}


