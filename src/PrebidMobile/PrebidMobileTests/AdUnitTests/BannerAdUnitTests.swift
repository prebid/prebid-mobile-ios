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

class BannerAdUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBannerAdUnitCreation() {
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2))
        XCTAssertTrue(1 == adUnit.adSizes.count)
        XCTAssertTrue(adUnit.prebidConfigId == Constants.configID1)
        XCTAssertTrue(0 == adUnit.refreshTime)
    }

    func testBannerAdUnitAddSize() {
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width1, height: Constants.height1))
        adUnit.adSizes = [CGSize(width: Constants.width1, height: Constants.height1), CGSize(width: Constants.width2, height: Constants.height2)]
        XCTAssertNotNil(adUnit.adSizes)
        XCTAssertTrue(2 == adUnit.adSizes.count)
    }

}
