//
//  OXANativeAdMarkupLinkTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdMarkupLinkTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<OXANativeAdMarkupLink>, Error)] = []
        
        let optionalLinkProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupLink>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Link value", dicKey: "url", keyPath: \.url),
            JSONDecoding.OptionalPropertyCheck(value: "Some Fallback URL", dicKey: "fallback", keyPath: \.fallback),
            JSONDecoding.OptionalPropertyCheck(value: ["Some clicktracker", "Another clicktracker"],
                                               dicKey: "clicktrackers",
                                               keyPath: \.clicktrackers),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let linkTester = JSONDecoding.Tester(generator: OXANativeAdMarkupLink.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalLinkProperties)
        
        linkTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<OXANativeAdMarkupLink> =
            Equality.Tester(template: OXANativeAdMarkupLink(url: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.url),
                Equality.Check(values: "some fallback", "other fallback", keyPath: \.fallback),
                Equality.Check(values: ["some clicktracker"], ["other clicktracker"], keyPath: \.clicktrackers),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
