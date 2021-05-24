//
//  NativeAdAssetTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAdAssetTest: XCTestCase {
    func testInitFromMarkup() {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkupAsset, NativeAdAsset>, Error)] = []
        
        let optionalAssetProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkupAsset, NativeAdAsset>] = [
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
        ]
        
        let markupAssetFactory = { PBMNativeAdMarkupAsset(title: .init(text: "")) }
        
        let assetTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                          generator: NativeAdAsset.init(nativeAdMarkupAsset:),
                                          requiredPropertyChecks: requiredProperties,
                                          optionalPropertyChecks: optionalAssetProperties)
        assetTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "v1"))), NSObject())
        XCTAssertEqual(try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init())),
                       try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init())))
        XCTAssertEqual(try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "v1"))),
                       try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "v1"))))
        XCTAssertEqual(try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "w2"))),
                       try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "w2"))))
        XCTAssertNotEqual(try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "v1"))),
                          try! NativeAdAsset(nativeAdMarkupAsset: .init(data: .init(value: "w2"))))
    }
}


