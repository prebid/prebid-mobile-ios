//
//  OXANativeAdMarkupEventTrackerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAdMarkupEventTrackerTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<OXANativeAdMarkupEventTracker>, Error)] = [
            (.init(saver: { $0["event"] = OXANativeEventType.impression.rawValue },
                   checker: { XCTAssertEqual($0.event, .impression) }),
             OXAError.noEventForNativeAdMarkupEventTracker),
            (.init(saver: { $0["method"] = OXANativeEventTrackingMethod.img.rawValue },
                   checker: { XCTAssertEqual($0.method, .img) }),
             OXAError.noMethodForNativeAdMarkupEventTracker),
            (.init(saver: { $0["url"] = "Some Link value" },
                   checker: { XCTAssertEqual($0.url, "Some Link value") }),
             OXAError.noUrlForNativeAdMarkupEventTracker),
        ]

        let optionalLinkProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupEventTracker>] = [
            JSONDecoding.OptionalPropertyCheck(value: ["g": "h"], dicKey: "customdata", keyPath: \.customdata),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]

        let linkTester = JSONDecoding.Tester(generator: OXANativeAdMarkupEventTracker.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalLinkProperties)

        linkTester.run()
    }
    
    func testIsEqual() {
        let templateFactory = { OXANativeAdMarkupEventTracker(event: .MRC50, method: .JS, url: "") }
        
        let tester: Equality.Tester<OXANativeAdMarkupEventTracker> =
            Equality.Tester(factory: templateFactory, checks: [
                Equality.Check(values: OXANativeEventType.impression, .MRC100, keyPath: \.event),
                Equality.Check(values: OXANativeEventTrackingMethod.img, .exchangeSpecific, keyPath: \.method),
                Equality.Check(values: "some url", "other url", keyPath: \.url),
                Equality.Check(values: ["q":1], ["R":"TjHy;"], keyPath: \.customdata),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
