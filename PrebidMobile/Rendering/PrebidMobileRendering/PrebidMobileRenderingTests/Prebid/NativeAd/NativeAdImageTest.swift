//
//  NativeAdImageTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class NativeAdImageTest: XCTestCase {
    func testInitFromMarkup_withUrl() {
        testInitFromMarkup(imageUrl: "Some Image url")
    }
    func testInitFromMarkup_noUrl() {
        testInitFromMarkup(imageUrl: nil)
    }
    
    func testInitFromMarkup(imageUrl: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkupAsset, NativeAdImage>, Error)] = [
            (.init(saver: { $0.img = .init(url: imageUrl) },
                   checker: { XCTAssertEqual($0.url, imageUrl ?? "") }),
             NativeAdAssetBoxingError.noImageInsideNativeAdMarkupAsset),
        ]
        
        let optionalImageProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkupAsset, NativeAdImage>] = [
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
            Decoding.OptionalPropertyCheck(value: NSNumber(value: NativeImageAssetType.main.rawValue),
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
        
        let markupAssetFactory = { PBMNativeAdMarkupAsset(title: .init(text: "")) }
        
        let imageTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                          generator: NativeAdImage.init(nativeAdMarkupAsset:),
                                          requiredPropertyChecks: requiredProperties,
                                          optionalPropertyChecks: optionalImageProperties)
        imageTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))), NSObject())
        XCTAssertEqual(try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init())),
                       try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init())))
        XCTAssertEqual(try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))),
                       try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))))
        XCTAssertEqual(try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "w2"))),
                       try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "w2"))))
        XCTAssertNotEqual(try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "v1"))),
                          try! NativeAdImage(nativeAdMarkupAsset: .init(image: .init(url: "w2"))))
    }
}


