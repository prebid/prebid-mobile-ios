//
//  PBMNativeAdMarkupEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdMarkupEventTrackerTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupEventTracker>, Error)] = [
            (.init(saver: { $0["event"] = NativeEventType.impression.rawValue },
                   checker: { XCTAssertEqual($0.event, NativeEventType.impression.rawValue) }),
             PBMError.noEventForNativeAdMarkupEventTracker),
            (.init(saver: { $0["method"] = NativeEventTrackingMethod.img.rawValue },
                   checker: { XCTAssertEqual($0.method, NativeEventTrackingMethod.img.rawValue) }),
             PBMError.noMethodForNativeAdMarkupEventTracker),
            (.init(saver: { $0["url"] = "Some Link value" },
                   checker: { XCTAssertEqual($0.url, "Some Link value") }),
             PBMError.noUrlForNativeAdMarkupEventTracker),
        ]

        let optionalLinkProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupEventTracker>] = [
            JSONDecoding.OptionalPropertyCheck(value: ["g": "h"], dicKey: "customdata", keyPath: \.customdata),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]

        let linkTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupEventTracker.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalLinkProperties)

        linkTester.run()
    }
    
    func testIsEqual() {
        let templateFactory = { PBMNativeAdMarkupEventTracker(event: NativeEventType.mrc50.rawValue, method: NativeEventTrackingMethod.js.rawValue, url: "") }
        
        let tester: Equality.Tester<PBMNativeAdMarkupEventTracker> =
            Equality.Tester(factory: templateFactory, checks: [
                Equality.Check(values: NativeEventType.impression.rawValue, NativeEventType.mrc50.rawValue, keyPath: \.event),
                Equality.Check(values: NativeEventTrackingMethod.img.rawValue, NativeEventType.exchangeSpecific.rawValue, keyPath: \.method),
                Equality.Check(values: "some url", "other url", keyPath: \.url),
                Equality.Check(values: ["q":1], ["R":"TjHy;"], keyPath: \.customdata),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
