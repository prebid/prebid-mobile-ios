//
//  OXANativeAdDataTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdDataTest: XCTestCase {
    func testInitFromMarkup_withValue() {
        testInitFromMarkup(dataValue: "Some Data value")
    }
    func testInitFromMarkup_noValue() {
        testInitFromMarkup(dataValue: nil)
    }
    
    func testInitFromMarkup(dataValue: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<OXANativeAdMarkupAsset, OXANativeAdData>, Error)] = [
            (.init(saver: { $0.data = .init(value: dataValue) },
                   checker: { XCTAssertEqual($0.value, dataValue ?? "") }),
             OXANativeAdAssetBoxingError.noDataInsideNativeAdMarkupAsset),
        ]

        let optionalDataProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkupAsset, OXANativeAdData>] = [
            // MARK: - Asset properties
            Decoding.OptionalPropertyCheck(value: 149578,
                                           writer: { $0.assetID = $1 },
                                           reader: { $0.assetID }),
            Decoding.OptionalPropertyCheck(value: true,
                                           writer: { $0.required = $1 },
                                           reader: { $0.required }),
            Decoding.OptionalPropertyCheck(value: ["a": "b"] as NSDictionary,
                                           writer: { asset, extDic in asset.ext = extDic as? [String: Any] },
                                           reader: { $0.assetExt as NSDictionary? }),
            // MARK: - Data properties
            Decoding.OptionalPropertyCheck(value: NSNumber(value: OXADataAssetType.desc.rawValue),
                                           writer: { $0.data?.dataType = $1 },
                                           reader: { $0.dataType }),
            Decoding.OptionalPropertyCheck(value: 15,
                                           writer: { $0.data?.length = $1 },
                                           reader: { $0.length }),
            Decoding.OptionalPropertyCheck(value: ["x": "y"] as NSDictionary,
                                           writer: { asset, extDic in asset.data?.ext = extDic as? [String: Any] },
                                           reader: { $0.dataExt as NSDictionary? }),
        ]

        let markupAssetFactory = { OXANativeAdMarkupAsset(title: .init(text: "")) }
        
        let dataTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                         generator: OXANativeAdData.init(nativeAdMarkupAsset:),
                                         requiredPropertyChecks: requiredProperties,
                                         optionalPropertyChecks: optionalDataProperties)
        dataTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))), NSObject())
        XCTAssertEqual(try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init())),
                       try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init())))
        XCTAssertEqual(try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))),
                       try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))))
        XCTAssertEqual(try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "w2"))),
                       try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "w2"))))
        XCTAssertNotEqual(try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))),
                          try! OXANativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "w2"))))
    }
}


