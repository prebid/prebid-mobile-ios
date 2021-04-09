//
//  OXANativeAdMarkupVideoTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdMarkupVideoTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<OXANativeAdMarkupVideo>, Error)] = []
        
        let optionalVideoProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupVideo>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Vast XML", dicKey: "vasttag", keyPath: \.vasttag),
        ]
        
        let videoTester = JSONDecoding.Tester(generator: OXANativeAdMarkupVideo.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalVideoProperties)
        
        videoTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<OXANativeAdMarkupVideo> =
            Equality.Tester(template: OXANativeAdMarkupVideo(vastTag: ""), checks: [
                Equality.Check(values: "some vasttag", "other vasttag", keyPath: \.vasttag),
            ])
        tester.run()
    }
}
