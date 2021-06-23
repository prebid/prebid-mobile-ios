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

class PBMNativeAdMarkupDataTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupData>, Error)] = []

        let optionalDataProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupData>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Data value", dicKey: "value", keyPath: \.value),
            JSONDecoding.OptionalPropertyCheck(value: NativeDataAssetType.desc,
                                               writer: { $0["type"] = NSNumber(value: $1.rawValue) },
                                               reader: { (data: PBMNativeAdMarkupData) -> NativeDataAssetType? in
                                                if let rawType = data.dataType?.intValue {
                                                 return NativeDataAssetType(rawValue: rawType)
                                                } else {
                                                 return nil
                                                }
                                               }),
            JSONDecoding.OptionalPropertyCheck(value: 15, dicKey: "len", keyPath: \.length),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]

        let dataTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupData.init(jsonDictionary:),
                                             requiredPropertyChecks: requiredProperties,
                                             optionalPropertyChecks: optionalDataProperties)
        dataTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkupData> =
            Equality.Tester(template: PBMNativeAdMarkupData(value: ""), checks: [
                Equality.Check(values: "some url", "other url", keyPath: \.value),
                Equality.Check(values: NativeDataAssetType.desc, .rating) { $0.dataType = NSNumber(value: $1.rawValue) },
                Equality.Check(values: 12, 49, keyPath: \.length),
                Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
            ])
        tester.run()
    }
}
