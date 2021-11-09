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

import Foundation
import XCTest
@testable import PrebidMobile

class PBMURLComponentsTest: XCTestCase {
    
    //Demonstrate PBMURLComponents will overwrite and append key-val pairs, then sort them.
    func testPositive() {
        let traceParamDict = ["overwritekey" : "overwriteval", "appendkey" : "appendval"]
        let strURL = "https://foo.com/?overwritekey=bar"
        
        let urlComponents = PBMURLComponents.init(url:strURL, paramsDict:traceParamDict)!
        
        let expected = "https://foo.com/?appendkey=appendval&overwritekey=overwriteval"
        let actual = urlComponents.fullURL
        XCTAssert(expected == actual as String, "expected \(expected), got \(actual)")
    }
    
    //URLComponents and NSURLComponents treat square brackets as a malformed URL.
    //Since PBMURLComponents depends on them, it will fail as well.
    func testNegativeFailOnSquareBrackets() {
        let traceParamDict = ["key1" : "val1", "key2" : "val2"]
        let strURL = "https://foo.com?ad_mt=[AD_MT]"
        
        let urlComponents = PBMURLComponents.init(url:strURL, paramsDict:traceParamDict)
        XCTAssert(urlComponents == nil)
    }
}
