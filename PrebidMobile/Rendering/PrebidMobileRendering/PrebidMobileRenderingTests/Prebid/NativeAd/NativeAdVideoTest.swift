/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest

@testable import PrebidMobileRendering

class NativeAdVideoTest: XCTestCase {
    func testInitFromMarkup_withVastTag() {
        testInitFromMarkup(videoVast: "VAST Tag XML")
    }
    func testInitFromMarkup_noVastTag() {
        testInitFromMarkup(videoVast: nil)
    }
    
    func testInitFromMarkup(videoVast: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkupAsset, NativeAdVideo>, Error)] = [
            (.init(saver: { $0.video = .init(vastTag: videoVast) },
                   checker: { XCTAssertEqual($0.mediaData.mediaAsset.video?.vasttag, videoVast) }),
             NativeAdAssetBoxingError.noVideoInsideNativeAdMarkupAsset),
        ]

        let optionalVideoProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkupAsset, NativeAdVideo>] = [
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

        let markupAssetFactory = { PBMNativeAdMarkupAsset(title: .init(text: "")) }
        
        let nativeAdHooks = PBMNativeAdMediaHooks(viewControllerProvider: { nil }, clickHandlerOverride: { _ in })
        
        let videoTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                          generator: { try NativeAdVideo(nativeAdMarkupAsset: $0,
                                                                            nativeAdHooks: nativeAdHooks) },
                                          requiredPropertyChecks: requiredProperties,
                                          optionalPropertyChecks: optionalVideoProperties)
        videoTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))), NSObject())
        XCTAssertEqual(try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init())),
                       try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init())))
        XCTAssertEqual(try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))),
                       try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))))
        XCTAssertEqual(try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "w2"))),
                       try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "w2"))))
        XCTAssertNotEqual(try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "v1"))),
                          try! NativeAdVideo(nativeAdMarkupAsset: .init(video: .init(vastTag: "w2"))))
    }
}


