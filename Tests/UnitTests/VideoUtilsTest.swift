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

class VideoUtilsTest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuildAdTagUrlByMap() throws {
        var targetingMap = [String: String]()
        targetingMap["key1"] = "value1"
        targetingMap["key2"] = "value2"

        let adTagUrl = VideoUtils.buildAdTagUrl(adUnitId: "adUnitId", adSlotSize: "300x250", targeting: targetingMap)
        XCTAssertTrue(adTagUrl.contains("https://pubads.g.doubleclick.net/gampad/ads?env=vp&gdfp_req=1&unviewed_position_start=1&output=xml_vast4&vpmute=1&iu=adUnitId&sz=300x250&cust_params=key1%3Dvalue1%26key2%3Dvalue2") || adTagUrl.contains("https://pubads.g.doubleclick.net/gampad/ads?env=vp&gdfp_req=1&unviewed_position_start=1&output=xml_vast4&vpmute=1&iu=adUnitId&sz=300x250&cust_params=key2%3Dvalue2%26key1%3Dvalue1"))
    }
    
}
