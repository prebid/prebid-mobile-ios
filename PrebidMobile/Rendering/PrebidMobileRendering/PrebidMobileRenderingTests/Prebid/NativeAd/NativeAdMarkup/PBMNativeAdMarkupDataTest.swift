//
//  PBMNativeAdMarkupDataTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMNativeAdMarkupDataTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupData>, Error)] = []

        let optionalDataProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupData>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Data value", dicKey: "value", keyPath: \.value),
            JSONDecoding.OptionalPropertyCheck(value: PBMDataAssetType.desc,
                                               writer: { $0["type"] = NSNumber(value: $1.rawValue) },
                                               reader: { (data: PBMNativeAdMarkupData) -> PBMDataAssetType? in
                                                if let rawType = data.dataType?.intValue {
                                                 return PBMDataAssetType(rawValue: rawType)
                                                } else {
                                                 return nil
                                                }
                                               }),
            JSONDecoding.OptionalPropertyCheck(value: 15, dicKey: "len", keyPath: \.length),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]

        let dataTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupData.init(jsonDictionary:),
                                             requiredPropertyChecks: requiredProperties,
                                             optionalPropertyChecks: optionalDataProperties)
        dataTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkupData> =
            Equality.Tester(template: PBMNativeAdMarkupData(value: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.value),
                Equality.Check(values: PBMDataAssetType.desc, .rating) { $0.dataType = NSNumber(value: $1.rawValue) },
                Equality.Check(values: 12, 49, keyPath: \.length),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
