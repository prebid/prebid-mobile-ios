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


