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

class PBMNativeAdMarkupLinkTest: XCTestCase {
    func testInitFromJson() {
        let requiredProperties: [(JSONDecoding.PropertyCheck<PBMNativeAdMarkupLink>, Error)] = []
        
        let optionalLinkProperties: [JSONDecoding.BaseOptionalCheck<PBMNativeAdMarkupLink>] = [
            JSONDecoding.OptionalPropertyCheck(value: "Some Link value", dicKey: "url", keyPath: \.url),
            JSONDecoding.OptionalPropertyCheck(value: "Some Fallback URL", dicKey: "fallback", keyPath: \.fallback),
            JSONDecoding.OptionalPropertyCheck(value: ["Some clicktracker", "Another clicktracker"],
                                               dicKey: "clicktrackers",
                                               keyPath: \.clicktrackers),
            JSONDecoding.OptionalPropertyCheck(value: ["a": "b"], dicKey: "ext", keyPath: \.ext),
        ]
        
        let linkTester = JSONDecoding.Tester(generator: PBMNativeAdMarkupLink.init(jsonDictionary:),
                                             requiredPropertyChecks: requiredProperties,
                                             optionalPropertyChecks: optionalLinkProperties)
        
        linkTester.run()
    }
    
    func testIsEqual() {
        let tester: Equality.Tester<PBMNativeAdMarkupLink> =
        Equality.Tester(template: PBMNativeAdMarkupLink(url: ""), checks: [
            Equality.Check(values: "some url", "other url", keyPath: \.url),
            Equality.Check(values: "some fallback", "other fallback", keyPath: \.fallback),
            Equality.Check(values: ["some clicktracker"], ["other clicktracker"], keyPath: \.clicktrackers),
            Equality.Check(values: ["a":"b"], ["c":1]) { $0.ext = $1 },
        ])
        tester.run()
    }
}
