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
import TestUtils
@testable import PrebidMobile

class AdUnitTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        Targeting.shared.clearUserKeywords()
        Prebid.shared.useExternalClickthroughBrowser = false
        PrebidInternal.shared().isOriginalAPI = false
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
    
    func testFetchDemandResumeAutoRefresh() {
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
        
        adUnit.stopAutoRefresh()
        sleep(1)
        adUnit.resumeAutoRefresh()
        
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
        XCTAssertNil(adUnit.dispatcher?.timer)
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
    
    // MARK: - global context data aka inventory data (app.content.data)
    func testSetAppContent() {
        //given
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"
        
        let appContent = PBMORTBAppContent()
        appContent.album = "test album"
        appContent.embeddable = 1
        appContent.data = [appDataObject1, appDataObject2]
        //when
        adUnit.setAppContent(appContent)
        let resultAppContent = adUnit.getAppContent()!

        //then
        XCTAssertEqual(2, resultAppContent.data!.count)
        XCTAssertEqual(resultAppContent.data!.first, appDataObject1)
        XCTAssertEqual(appContent, resultAppContent)
    }
    
    func testClearAppContent() {
        //given
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"
        
        let appContent = PBMORTBAppContent()
        appContent.album = "test album"
        appContent.embeddable = 1
        appContent.data = [appDataObject1, appDataObject2]
        //when
        adUnit.setAppContent(appContent)
        
        let resultAppContent1 = adUnit.getAppContent()
        XCTAssertNotNil(resultAppContent1)
        adUnit.clearAppContent()
        let resultAppContent2 = adUnit.getAppContent()
        XCTAssertNil(resultAppContent2)
    }
    
    func testAddAppContentDataObject() {
        //given
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        //when
        adUnit.addAppContentData([appDataObject1, appDataObject2])
        let objects = adUnit.getAppContent()!.data!

        //then
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, appDataObject1)
    }

    func testRemoveAppContentDataObjects() {
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let appDataObject = PBMORTBContentData()
        appDataObject.id = "data id"
        appDataObject.name = "test name"

        adUnit.addAppContentData([appDataObject])
        let objects1 = adUnit.getAppContent()!.data!

        XCTAssertEqual(1, objects1.count)

        adUnit.removeAppContentData(appDataObject)
        let objects2 = adUnit.getAppContent()!.data!

        XCTAssertEqual(0, objects2.count)
    }
    
    func testClearAppContentDataObjects() {
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let appDataObject1 = PBMORTBContentData()
        appDataObject1.id = "data id"
        appDataObject1.name = "test name"
        let appDataObject2 = PBMORTBContentData()
        appDataObject2.id = "data id"
        appDataObject2.name = "test name"

        adUnit.addAppContentData([appDataObject1, appDataObject2])
        let objects1 = adUnit.getAppContent()!.data!
        
        XCTAssertEqual(2, objects1.count)
        adUnit.clearAppContentData()
        let objects2 = adUnit.getAppContent()!.data!
        XCTAssertEqual(0, objects2.count)
    }
    
//    // MARK: - global user data aka visitor data (user.data)

    func testAddUserDataObjects() {
        //given
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        //when
        adUnit.addUserData([userDataObject1, userDataObject2])
        let objects = adUnit.getUserData()!

        //then
        XCTAssertEqual(2, objects.count)
        XCTAssertEqual(objects.first, userDataObject1)
    }
    
    func testRemoveUserDataObjects() {
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let userDataObject = PBMORTBContentData()
        userDataObject.id = "data id"
        userDataObject.name = "test name"

        adUnit.addUserData([userDataObject])
        let objects1 = adUnit.getUserData()!

        XCTAssertEqual(1, objects1.count)

        adUnit.removeUserData(userDataObject)
        let objects2 = adUnit.getUserData()!

        XCTAssertEqual(0, objects2.count)
    }

    func testClearUserDataObjects() {
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let userDataObject1 = PBMORTBContentData()
        userDataObject1.id = "data id"
        userDataObject1.name = "test name"
        let userDataObject2 = PBMORTBContentData()
        userDataObject2.id = "data id"
        userDataObject2.name = "test name"

        adUnit.addUserData([userDataObject1, userDataObject2])
        let objects1 = adUnit.getUserData()!

        XCTAssertEqual(2, objects1.count)

        adUnit.clearUserData()
        let objects2 = adUnit.getUserData()!
        XCTAssertEqual(0, objects2.count)
    }
}
