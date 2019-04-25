/*   Copyright 2018-2019 Prebid.org, Inc.

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

class InterstItialAdUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInterstitialAdUnitCreation() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        XCTAssertTrue(adUnit.prebidConfigId == Constants.configID1)
        XCTAssertNil(adUnit.dispatcher)
    }

    func testSetUserKeyword() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        adUnit.addUserKeyword(key: "key1", value: "value1")
        adUnit.addUserKeyword(key: "key2", value: "value2")
        XCTAssertTrue(2 == adUnit.userKeywords.count)
        
        guard let key1Set = adUnit.userKeywords["key1"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key1Set.count == 1)
        XCTAssert(key1Set.contains("value1"))
        
        guard let key2Set = adUnit.userKeywords["key2"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key2Set.count == 1)
        XCTAssert(key2Set.contains("value2"))
        
        adUnit.removeUserKeyword(forKey: "key1")
        XCTAssertTrue(1 == adUnit.userKeywords.count)
        XCTAssertNil(adUnit.userKeywords["key1"])
        adUnit.removeUserKeyword(forKey: "key2")
        XCTAssertTrue(0 == adUnit.userKeywords.count)
        XCTAssertNil(adUnit.userKeywords["key2"])
    }

    func testSetUserKeywords() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        
        let arrValues: Set = ["value1", "value2"]
        
        adUnit.addUserKeyword(key: "key1", value: "value1")
        adUnit.addUserKeywords(key: "key2", value: arrValues)
        XCTAssertTrue(2 == adUnit.userKeywords.count)
        
        guard let key1Set = adUnit.userKeywords["key1"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key1Set.count == 1)
        XCTAssert(key1Set.contains("value1"))
        
        guard let key2Set = adUnit.userKeywords["key2"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssert(key2Set.count == 2)
        XCTAssert(key2Set.contains("value1") && key2Set.contains("value2"))

        adUnit.addUserKeywords(key: "key1", value: arrValues)
        
        guard let key1SetChanged = adUnit.userKeywords["key1"] else {
            XCTFail("set is nil")
            return
        }
        XCTAssertTrue(adUnit.userKeywords.count == 2)
        XCTAssert(key1SetChanged.count == 2)
        XCTAssert(key1SetChanged.contains("value1") && key1SetChanged.contains("value2"))

        XCTAssertTrue(2 == adUnit.userKeywords.count)
        adUnit.clearUserKeywords()
        XCTAssertTrue(0 == adUnit.userKeywords.count)
        XCTAssertNil(adUnit.userKeywords["key1"])
        XCTAssertNil(adUnit.userKeywords["key2"])
    }

}
