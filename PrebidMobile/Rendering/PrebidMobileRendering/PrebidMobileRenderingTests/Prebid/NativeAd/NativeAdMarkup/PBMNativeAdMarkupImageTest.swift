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

class PBMNativeAdMarkupImageTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupImage>, Error)] = []
        
        let optionalImageProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupImage>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Image value", dicKey: "url", keyPath: \.url),
            JSONDecoding.OptionalPropertyCheck(value: NativeImageAssetType.main,
                                               writer: { $0["type"] = NSNumber(value: $1.rawValue) },
                                               reader: { (image: PBMNativeAdMarkupImage) -> NativeImageAssetType? in
                                                if let rawType = image.imageType?.intValue {
                                                    return NativeImageAssetType(rawValue: rawType)
                                                } else {
                                                    return nil
                                                }
                                               }),
            JSONDecoding.OptionalPropertyCheck(value: 640, dicKey: "w", keyPath: \.width),
            JSONDecoding.OptionalPropertyCheck(value: 480, dicKey: "h", keyPath: \.height),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let imageTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupImage.init(jsonDictionary:),
                                              requiredPropertyChecks: requiredProperties,
                                              optionalPropertyChecks: optionalImageProperties)
        
        imageTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkupImage> =
            Equality.Tester(template: PBMNativeAdMarkupImage(url: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.url),
                Equality.Check(values: 320, 640, keyPath: \.width),
                Equality.Check(values: 240, 480, keyPath: \.height),
                Equality.Check(values: NativeImageAssetType.main, .icon) { $0.imageType = NSNumber(value: $1.rawValue) },
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
