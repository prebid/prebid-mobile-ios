//
//  PBMNativeAdMarkupVideoTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdMarkupVideoTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupVideo>, Error)] = []
        
        let optionalVideoProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupVideo>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Vast XML", dicKey: "vasttag", keyPath: \.vasttag),
        ]
        
        let videoTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupVideo.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalVideoProperties)
        
        videoTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkupVideo> =
            Equality.Tester(template: PBMNativeAdMarkupVideo(vastTag: ""), checks: [
                Equality.Check(values: "some vasttag", "other vasttag", keyPath: \.vasttag),
            ])
        tester.run()
    }
}
