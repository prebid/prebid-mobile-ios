//
//  OXANativeAdMarkupDataTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdMarkupDataTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<OXANativeAdMarkupData>, Error)] = []

        let optionalDataProperties: [JSONDecoding.BaseOptionalCheck<OXANativeAdMarkupData>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Data value", dicKey: "value", keyPath: \.value),
            JSONDecoding.OptionalPropertyCheck(value: OXADataAssetType.desc,
                                               writer: { $0["type"] = NSNumber(value: $1.rawValue) },
                                               reader: { (data: OXANativeAdMarkupData) -> OXADataAssetType? in
                                                if let rawType = data.dataType?.intValue {
                                                 return OXADataAssetType(rawValue: rawType)
                                                } else {
                                                 return nil
                                                }
                                               }),
            JSONDecoding.OptionalPropertyCheck(value: 15, dicKey: "len", keyPath: \.length),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]

        let dataTester = JSONDecoding.Tester(generator: OXANativeAdMarkupData.init(jsonDictionary:),
                                             requiredPropertyChecks: requiredProperties,
                                             optionalPropertyChecks: optionalDataProperties)
        dataTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<OXANativeAdMarkupData> =
            Equality.Tester(template: OXANativeAdMarkupData(value: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.value),
                Equality.Check(values: OXADataAssetType.desc, .rating) { $0.dataType = NSNumber(value: $1.rawValue) },
                Equality.Check(values: 12, 49, keyPath: \.length),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
