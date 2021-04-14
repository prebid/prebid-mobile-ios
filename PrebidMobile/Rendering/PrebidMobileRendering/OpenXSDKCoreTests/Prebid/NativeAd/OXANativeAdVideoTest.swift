//
//  OXANativeAdVideoTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXANativeAdVideoTest: XCTestCase {
    func testInitFromMarkup_withVastTag() {
        testInitFromMarkup(videoVast: "VAST Tag XML")
    }
    func testInitFromMarkup_noVastTag() {
        testInitFromMarkup(videoVast: nil)
    }
    
    func testInitFromMarkup(videoVast: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<OXANativeAdMarkupAsset, OXANativeAdVideo>, Error)] = [
            (.init(saver: { $0.video = .init(vastTag: videoVast) },
                   checker: { XCTAssertEqual($0.mediaData.mediaAsset.video?.vasttag, videoVast) }),
             OXANativeAdAssetBoxingError.noVideoInsideNativeAdMarkupAsset),
        ]

        let optionalVideoProperties: [Decoding.BaseOptionalCheck<OXANativeAdMarkupAsset, OXANativeAdVideo>] = [
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
            // MARK: - Video properties
        ]

        let markupAssetFactory = { OXANativeAdMarkupAsset(title: .init(text: "")) }
        
        let nativeAdHooks = OXANativeAdMediaHooks(viewControllerProvider: { nil }, clickHandlerOverride: { _ in })
        
        let videoTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                          generator: { try OXANativeAdVideo(nativeAdMarkupAsset: $0,
                                                                            nativeAdHooks: nativeAdHooks) },
                                          requiredPropertyChecks: requiredProperties,
                                          optionalPropertyChecks: optionalVideoProperties)
        videoTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))), NSObject())
        XCTAssertEqual(try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init())),
                       try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init())))
        XCTAssertEqual(try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))),
                       try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))))
        XCTAssertEqual(try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "w2"))),
                       try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "w2"))))
        XCTAssertNotEqual(try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))),
                          try! OXANativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "w2"))))
    }
}


