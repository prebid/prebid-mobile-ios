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

@testable import PrebidMobile

class NativeAdDataTest: XCTestCase {
    func testInitFromMarkup_withValue() {
        testInitFromMarkup(dataValue: "Some Data value")
    }
    func testInitFromMarkup_noValue() {
        testInitFromMarkup(dataValue: nil)
    }
    
    func testInitFromMarkup(dataValue: String?) {
        let requiredProperties: [(Decoding.PropertyCheck<PBMNativeAdMarkupAsset, NativeAdData>, Error)] = [
            (.init(saver: { $0.data = .init(value: dataValue) },
                   checker: { XCTAssertEqual($0.value, dataValue ?? "") }),
             NativeAdAssetBoxingError.noDataInsideNativeAdMarkupAsset),
        ]
        
        let optionalDataProperties: [Decoding.BaseOptionalCheck<PBMNativeAdMarkupAsset, NativeAdData>] = [
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
            Decoding.OptionalPropertyCheck(value: NSNumber(value: NativeDataAssetType.desc.rawValue),
                                           writer: { $0.data?.dataType = $1 },
                                           reader: { $0.dataType }),
            Decoding.OptionalPropertyCheck(value: 15,
                                           writer: { $0.data?.length = $1 },
                                           reader: { $0.length }),
            Decoding.OptionalPropertyCheck(value: ["x": "y"] as NSDictionary,
                                           writer: { asset, extDic in asset.data?.ext = extDic as? [String: Any] },
                                           reader: { $0.dataExt as NSDictionary? }),
        ]
        
        let markupAssetFactory = { PBMNativeAdMarkupAsset(title: .init(text: "")) }
        
        let dataTester = Decoding.Tester(templateFactory: markupAssetFactory,
                                         generator: NativeAdData.init(nativeAdMarkupAsset:),
                                         requiredPropertyChecks: requiredProperties,
                                         optionalPropertyChecks: optionalDataProperties)
        dataTester.run()
    }
    
    func testIsEqual() {
        XCTAssertNotEqual(try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))), NSObject())
        XCTAssertEqual(try! NativeAdData(nativeAdMarkupAsset: .init(data: .init())),
                       try! NativeAdData(nativeAdMarkupAsset: .init(data: .init())))
        XCTAssertEqual(try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))),
                       try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))))
        XCTAssertEqual(try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "w2"))),
                       try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "w2"))))
        XCTAssertNotEqual(try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "v1"))),
                          try! NativeAdData(nativeAdMarkupAsset: .init(data: .init(value: "w2"))))
    }
}


