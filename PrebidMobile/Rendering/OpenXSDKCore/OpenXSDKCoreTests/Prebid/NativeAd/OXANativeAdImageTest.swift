//
//  OXANativeAdImageTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXANativeAdImageTest: XCTestCase {
    func testInitFromMarkup_withUrl() {
        testInitFromMarkup(imageUrl: "Some Image url")
    }
    func testInitFromMarkup_noUrl() {
        testInitFromMarkup(imageUrl: nil)
    }
    
    func testInitFromMarkup(imageUrl: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<OXANativeAdMarkupAsset, OXANativeAdImage>, Error)] = [
            (.init(saver: { $0.img = .init(url: imageUrl) },
                   checker: { XCTAssertEqual($0.url, imageUrl ?? "") }),
             OXANativeAdAssetBoxingError.noImageInsideNativeAdMarkupAsset),
        ]
        
        let optionalImageProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkupAsset, OXANativeAdImage>] = [
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
            // MARK: - Image properties
            Decoding.OptionalPropertyCheck(value: NSNumber(value: OXAImageAssetType.main.rawValue),
                                           writer: { $0.img?.imageType = $1 },
                                           reader: { $0.imageType }),
            Decoding.OptionalPropertyCheck(value: 320,
                                           writer: { $0.img?.width = $1 },
                                           reader: { $0.width }),
            Decoding.OptionalPropertyCheck(value: 240,
                                           writer: { $0.img?.height = $1 },
                                           reader: { $0.height }),
            Decoding.OptionalPropertyCheck(value: ["x": "y"] as NSDictionary,
                                           writer: { asset, extDic in asset.img?.ext = extDic as? [String: Any] },
                                           reader: { $0.imageExt as NSDictionary? }),
        ]
        
        let markupAssetFactory = { OXANativeAdMarkupAsset(title: .init(text: "")) }
        
        let imageTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                          generator: OXANativeAdImage.init(nativeAdMarkupAsset:),
                                          requiredPropertyChecks: requiredProperties,
                                          optionalPropertyChecks: optionalImageProperties)
        imageTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))), NSObject())
        XCTAssertEqual(try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init())),
                       try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init())))
        XCTAssertEqual(try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))),
                       try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))))
        XCTAssertEqual(try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "w2"))),
                       try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "w2"))))
        XCTAssertNotEqual(try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))),
                          try! OXANativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "w2"))))
    }
}


