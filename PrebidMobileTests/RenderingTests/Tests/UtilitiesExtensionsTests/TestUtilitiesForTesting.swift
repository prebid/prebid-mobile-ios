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

class TestUtilitiesForTesting: XCTestCase {
    
    //Walk the sample json files we need for running unit tests and expect them all to load as NSData
    func testLoadFuncs() {
        
        let sampleJSONFileNames = ["ACJBanner.json", "ACJInterstitial.json", "ACJNonChainingAdUnit.json", "ACJNonChainingAdUnit.json", "ACJSingleAd.json"]
        
        for jsonFileName in sampleJSONFileNames {
            XCTAssert(UtilitiesForTesting.loadFileAsDataFromBundle(jsonFileName) != nil, "Expected data for file: \(jsonFileName)")
            XCTAssert(UtilitiesForTesting.loadFileAsStringFromBundle(jsonFileName) != nil, "Expected data for file: \(jsonFileName)")
            XCTAssert(UtilitiesForTesting.loadFileAsDictFromBundle(jsonFileName) != nil, "Expected data for file: \(jsonFileName)")
        }
    }
}
