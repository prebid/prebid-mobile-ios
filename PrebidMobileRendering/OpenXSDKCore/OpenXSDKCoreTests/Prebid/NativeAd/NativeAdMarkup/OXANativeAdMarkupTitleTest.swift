//
//  OXANativeAdMarkupTitleTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdMarkupTitleTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<OXANativeAdMarkupTitle>, Error)] = []
        
        let optionalTitleProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupTitle>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Title text", dicKey: "text", keyPath: \.text),
            JSONDecoding.OptionalPropertyCheck(value: 14, dicKey: "len", keyPath: \.length),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let titleTester = JSONDecoding.Tester(generator: OXANativeAdMarkupTitle.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalTitleProperties)
        
        titleTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<OXANativeAdMarkupTitle> =
            Equality.Tester(template: OXANativeAdMarkupTitle(text: ""), checks: [
                Equality.Check(values: "some text", "other text", keyPath: \.text),
                Equality.Check(values: 12, 49, keyPath: \.length),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}

