//
//  OXANativeAdMarkupImageTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAdMarkupImageTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<OXANativeAdMarkupImage>, Error)] = []
        
        let optionalImageProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupImage>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Image value", dicKey: "url", keyPath: \.url),
            JSONDecoding.OptionalPropertyCheck(value: OXAImageAssetType.main,
                                               writer: { $0["type"] = NSNumber(value: $1.rawValue) },
                                               reader: { (image: OXANativeAdMarkupImage) -> OXAImageAssetType? in
                                                if let rawType = image.imageType?.intValue {
                                                    return OXAImageAssetType(rawValue: rawType)
                                                } else {
                                                    return nil
                                                }
                                               }),
            JSONDecoding.OptionalPropertyCheck(value: 640, dicKey: "w", keyPath: \.width),
            JSONDecoding.OptionalPropertyCheck(value: 480, dicKey: "h", keyPath: \.height),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let imageTester = JSONDecoding.Tester(generator: OXANativeAdMarkupImage.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalImageProperties)
        
        imageTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<OXANativeAdMarkupImage> =
            Equality.Tester(template: OXANativeAdMarkupImage(url: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.url),
                Equality.Check(values: 320, 640, keyPath: \.width),
                Equality.Check(values: 240, 480, keyPath: \.height),
                Equality.Check(values: OXAImageAssetType.main, .icon) { $0.imageType = NSNumber(value: $1.rawValue) },
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
