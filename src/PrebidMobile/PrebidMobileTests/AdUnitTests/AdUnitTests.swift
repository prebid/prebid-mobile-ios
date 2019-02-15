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

class AdUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchDemandSuccess() {
        let adUnit:AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidDemandFetchSuccess
        let testObject:AnyObject = () as AnyObject
        
        adUnit.fetchDemand(adObject: testObject) { (ResultCode) in
            XCTAssertEqual(ResultCode.name(), "Prebid Demand Fetch Successful")
        }
    }
    
    func testFetchDemandNoBid() {
        let adUnit:AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidDemandNoBids
        let testObject:AnyObject = () as AnyObject
        
        adUnit.fetchDemand(adObject: testObject) { (ResultCode) in
            XCTAssertEqual(ResultCode.name(), "Prebid Server did not return bids")
        }
    }
    
    func testFetchDemandNetworkError() {
        let adUnit:AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidNetworkError
        let testObject:AnyObject = () as AnyObject
        
        adUnit.fetchDemand(adObject: testObject) { (ResultCode) in
            XCTAssertEqual(ResultCode.name(), "Network Error")
        }
    }
    
    func testFetchDemandTimedOut() {
        let adUnit:AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidDemandTimedOut
        let testObject:AnyObject = () as AnyObject
        
        adUnit.fetchDemand(adObject: testObject) { (ResultCode) in
            XCTAssertEqual(ResultCode.name(), "Prebid server TimedOut")
        }
    }
    
    func testInvalidSize() {
        let adUnit:AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidInvalidSize
        let testObject:AnyObject = () as AnyObject
        
        adUnit.fetchDemand(adObject: testObject) { (ResultCode) in
            XCTAssertEqual(ResultCode.name(), "Prebid server does not recognize the size requested")
        }
    }

}
