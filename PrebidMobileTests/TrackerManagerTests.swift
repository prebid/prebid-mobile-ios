/*   Copyright 2019-2020 Prebid.org, Inc.

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

class TrackerManagerTests: XCTestCase {

    var firedImpressionTrackerExpectation: XCTestExpectation?
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        firedImpressionTrackerExpectation = nil
    }

    func testTrackerManagerWithFireTrackerURL() {
        firedImpressionTrackerExpectation = expectation(description: "\(#function)")
        let urlString = "https://acdn.adnxs.com/mobile/native_test/empty_response.json"
        TrackerManager.shared.fireTrackerURLArray(arrayWithURLs: [urlString]) { [weak self] (isTrackerURLFired) in
            if isTrackerURLFired{
                self?.firedImpressionTrackerExpectation?.fulfill()
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
        
    }


}
