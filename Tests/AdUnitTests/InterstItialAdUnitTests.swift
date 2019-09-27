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
    
    func testAdvancedInterstitialAdUnitCreation() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        XCTAssertTrue(adUnit.minSizePerc?.width == 50 && adUnit.minSizePerc?.height == 70)
    }

}
