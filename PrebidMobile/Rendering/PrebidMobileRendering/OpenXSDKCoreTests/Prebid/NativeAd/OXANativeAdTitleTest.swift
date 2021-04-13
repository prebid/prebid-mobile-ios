//
//  OXANativeAdTitleTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAdTitleTest: XCTestCase {
    func testInitFromMarkup_withText() {
        testInitFromMarkup(titleText: "Some Title value")
    }
    func testInitFromMarkup_noText() {
        testInitFromMarkup(titleText: nil)
    }
    
    func testInitFromMarkup(titleText: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<OXANativeAdMarkupAsset, OXANativeAdTitle>, Error)] = [
            (.init(saver: { $0.title = .init(text: titleText)},
                   checker: { XCTAssertEqual($0.text, titleText ?? "") }),
             OXANativeAdAssetBoxingError.noTitleInsideNativeAdMarkupAsset),
        ]

        let optionalTitleProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkupAsset, OXANativeAdTitle>] = [
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
            // MARK: - Title properties
            Decoding.OptionalPropertyCheck(value: 15,
                                           writer: { $0.title?.length = $1 },
                                           reader: { $0.length }),
            Decoding.OptionalPropertyCheck(value: ["x": "y"] as NSDictionary,
                                           writer: { asset, extDic in asset.title?.ext = extDic as? [String: Any] },
                                           reader: { $0.titleExt as NSDictionary? }),
        ]

        let markupAssetFactory = { OXANativeAdMarkupAsset(data: .init(value: "")) }
        
        let titleTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                         generator: OXANativeAdTitle.init(nativeAdMarkupAsset:),
                                         requiredPropertyChecks: requiredProperties,
                                         optionalPropertyChecks: optionalTitleProperties)
        titleTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "v1"))), NSObject())
        XCTAssertEqual(try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init())),
                       try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init())))
        XCTAssertEqual(try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "v1"))),
                       try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "v1"))))
        XCTAssertEqual(try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "w2"))),
                       try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "w2"))))
        XCTAssertNotEqual(try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "v1"))),
                          try! OXANativeAdTitle(nativeAdMarkupAsset: .init(title: .init(text: "w2"))))
    }
}


