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
        let adUnit: AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidDemandFetchSuccess
        let testObject: AnyObject = () as AnyObject

        adUnit.fetchDemand(adObject: testObject) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode.name(), "Prebid Demand Fetch Successful")
        }
    }

    func testFetchDemandNoBid() {
        let adUnit: AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidDemandNoBids
        let testObject: AnyObject = () as AnyObject

        adUnit.fetchDemand(adObject: testObject) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode.name(), "Prebid Server did not return bids")
        }
    }

    func testFetchDemandNetworkError() {
        let adUnit: AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidNetworkError
        let testObject: AnyObject = () as AnyObject

        adUnit.fetchDemand(adObject: testObject) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode.name(), "Network Error")
        }
    }

    func testFetchDemandTimedOut() {
        let adUnit: AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidDemandTimedOut
        let testObject: AnyObject = () as AnyObject

        adUnit.fetchDemand(adObject: testObject) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode.name(), "Prebid demand timedout")
        }
    }

    func testInvalidSize() {
        let adUnit: AdUnit = AdUnit.shared
        adUnit.testScenario = ResultCode.prebidInvalidSize
        let testObject: AnyObject = () as AnyObject

        adUnit.fetchDemand(adObject: testObject) { (resultCode: ResultCode) in
            XCTAssertEqual(resultCode.name(), "Prebid server does not recognize the size requested")
        }
    }
    
    func testGetObjectWithoutEmptyValues() {
        
        //Test 1
        var node1111: NSMutableDictionary = [:]
        var node111: NSMutableDictionary = [:]
        node111["key111"] = node1111
        
        var node11: NSMutableDictionary = [:]
        node11["key11"] = node111
        
        var node1: NSMutableDictionary = [:]
        node1["key1"] = node11
        
        let result1 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertNil(result1)
        
        //Test 2
        node1111["key1111"] = "value1111"

        let result2 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertEqual("{\"key1\":{\"key11\":{\"key111\":{\"key1111\":\"value1111\"}}}}", collectionToString(result2!))
        
        //Test 3
        node1111["key1111"] = nil
        
        var node121: NSMutableDictionary = [:]
        node121["key121"] = "value121"
        node11["key12"] = node121

        let result3 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertEqual("{\"key1\":{\"key12\":{\"key121\":\"value121\"}}}", collectionToString(result3!))
        
        //Test 4
        node11["key12"] = nil
        var node21: NSMutableArray = []
        node1["key2"] = node21
        let result4 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertNil(result4)

        //Test5
        node21.add("value21")
        let result5 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertEqual("{\"key2\":[\"value21\"]}", collectionToString(result5!))
        
        //Test6
        node21.removeObject(at: 0)
        var node211: NSMutableDictionary = [:]
        node21.add(node211)
        let result6 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertNil(result6)
        
        //Test7
        node211["key211"] = "value211"
        let result7 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertEqual("{\"key2\":[{\"key211\":\"value211\"}]}", collectionToString(result7!))
        
        //Test8
        node21.removeObject(at: 0)
        var node212: NSMutableArray = []
        node21.add(node212)
        let result8 = Utils.shared.getObjectWithoutEmptyValues(node1 as! [AnyHashable : Any])
        XCTAssertNil(result8)
    }
    
    
    func collectionToString(_ dict: [AnyHashable: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        return jsonString
    }

}
