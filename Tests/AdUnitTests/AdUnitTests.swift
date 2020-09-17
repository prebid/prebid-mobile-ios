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

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        Targeting.shared.clearUserKeywords()
    }

    func testFetchDemand() {
        //given
        let exception = expectation(description: "\(#function)")
        let testObject: AnyObject = () as AnyObject
        var resultCode: ResultCode?
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250))
        AdUnitSwizzleHelper.testScenario = expected
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //when
        adUnit.fetchDemand(adObject: testObject) { (code: ResultCode) in
            resultCode = code
            exception.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //then
        XCTAssertEqual(expected, resultCode)
    }
    
    func testFetchDemandBids() {
        //given
        let exception = expectation(description: "\(#function)")
        var codeResult: ResultCode?
        var kvDictResult: [String:String]?
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250))
        AdUnitSwizzleHelper.testScenario = expected
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //when
        adUnit.fetchDemand() { (code: ResultCode, kvDict: [String:String]?) in
            codeResult = code
            kvDictResult = kvDict
            exception.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //then
        XCTAssertEqual(expected, codeResult)
        XCTAssertEqual(1, kvDictResult!.count)
        XCTAssertEqual("value1", kvDictResult!["key1"])
    }
    
    func testFetchDemandAutoRefresh() {
        PBHTTPStubbingManager.shared().enable()
        PBHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        PBHTTPStubbingManager.shared().broadcastRequests = true
        
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        //given
        let expectedFetchDemandCount = 2
        let exception = expectation(description: "\(#function)")
        exception.expectedFulfillmentCount = expectedFetchDemandCount
        exception.assertForOverFulfill = false
        
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = "1001"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.setAutoRefreshMillis(time: 800.0)
        let testObject: AnyObject = () as AnyObject
        
        var fetchDemandCount = 0
        
        //when
        adUnit.fetchDemand(adObject: testObject) { (code: ResultCode) in
            fetchDemandCount += 1
            exception.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        
        PBHTTPStubbingManager.shared().disable()
        PBHTTPStubbingManager.shared().removeAllStubs()
        PBHTTPStubbingManager.shared().broadcastRequests = false
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)

    }
    
    func testFetchDemandBidsAutoRefresh() {
        PBHTTPStubbingManager.shared().enable()
        PBHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        PBHTTPStubbingManager.shared().broadcastRequests = true
        
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        //given
        let expectedFetchDemandCount = 2
        let exception = expectation(description: "\(#function)")
        exception.expectedFulfillmentCount = expectedFetchDemandCount
        exception.assertForOverFulfill = false
        
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = "1001"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.setAutoRefreshMillis(time: 800.0)
        
        var fetchDemandCount = 0
        
        //when
        adUnit.fetchDemand(completion: { (code: ResultCode, kvDict: [String:String]?) in
            fetchDemandCount += 1
            exception.fulfill()
        })

        waitForExpectations(timeout: 2, handler: nil)
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        
        PBHTTPStubbingManager.shared().disable()
        PBHTTPStubbingManager.shared().removeAllStubs()
        PBHTTPStubbingManager.shared().broadcastRequests = false
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)

    }

    func testSetAutoRefreshMillis() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 30_000)
        
        //then
        XCTAssertNotNil(adUnit.dispatcher)
    }

    func testSetAutoRefreshMillisSmall() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 29_000)
        
        //then
        XCTAssertNil(adUnit.dispatcher)
    }
    
    func testStopAutoRefresh() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 30_000)
        adUnit.stopDispatcher()
        
        //then
        XCTAssertNil(adUnit.dispatcher)
    }
    
    // MARK: - adunit context data aka inventory data (imp[].ext.context.data)
    func testAddContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextData(key: key1, value: value1)
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.updateContextData(key: key1, value: set)
        
        //when
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextData(key: key1, value: value1)
        
        //when
        adUnit.removeContextData(forKey: key1)
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextData(key: key1, value: value1)
        
        //when
        adUnit.clearContextData()
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - adunit context keywords (imp[].ext.context.keywords)
    func testAddContextKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextKeyword(element1)
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddContextKeywords() {
        //given
        let element1 = "element1"
        let inputSet: Set = [element1]
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextKeywords(inputSet)
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveContextKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextKeyword(element1)
        
        //when
        adUnit.removeContextKeyword(element1)
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearContextKeywords() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextKeyword(element1)
        
        //when
        adUnit.clearContextKeywords()
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
}
