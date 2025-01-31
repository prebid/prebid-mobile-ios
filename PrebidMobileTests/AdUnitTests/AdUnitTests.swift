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

    override func tearDown() {
        Targeting.shared.clearUserKeywords()
        Targeting.shared.forceSdkToChooseWinner = true
        
        Prebid.shared.useExternalClickthroughBrowser = false
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        Prebid.shared.timeoutMillis = 2000
    }

    func testFetchDemand() {
        //given
        let expectation = expectation(description: "\(#function)")
        let testObject: AnyObject = () as AnyObject
        var resultCode: ResultCode?
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        AdUnitSwizzleHelper.testScenario = expected
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //when
        adUnit.fetchDemand(adObject: testObject) { (code: ResultCode) in
            resultCode = code
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //then
        XCTAssertEqual(expected, resultCode)
    }
    
    func testFetchDemandBids() {
        //given
        let expectation = expectation(description: "\(#function)")
        var codeResult: ResultCode?
        var kvDictResult: [String:String]?
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let expectedKVDictionary = ["key1" : "value1"]
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        
        AdUnitSwizzleHelper.testScenario = expected
        AdUnitSwizzleHelper.targetingKeywords = expectedKVDictionary
        
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //when
        adUnit.fetchDemand() { (code: ResultCode, kvDict: [String:String]?) in
            codeResult = code
            kvDictResult = kvDict
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //then
        XCTAssertEqual(expected, codeResult)
        XCTAssertEqual(1, kvDictResult!.count)
        XCTAssertTrue(NSDictionary(dictionary: kvDictResult!).isEqual(to: expectedKVDictionary))
    }
    
    func testFetchDemandBidInfo() {
        //given
        let expectation = expectation(description: "\(#function)")
        
        var realBidInfo: BidInfo?
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let expectedKVDictionary = ["key1" : "value1"]
        let expectedExp = 5.0
        let expectedCacheId = UUID().uuidString
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        
        AdUnitSwizzleHelper.testScenario = expected
        AdUnitSwizzleHelper.targetingKeywords = expectedKVDictionary
        AdUnitSwizzleHelper.exp = expectedExp
        AdUnitSwizzleHelper.nativeAdCacheId = expectedCacheId
        
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //when
        adUnit.fetchDemand { bidInfo in
            expectation.fulfill()
            realBidInfo = bidInfo
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        AdUnitSwizzleHelper.toggleFetchDemand()
        
        //then
        XCTAssertEqual(realBidInfo?.resultCode, expected)
        XCTAssertEqual(realBidInfo?.targetingKeywords, expectedKVDictionary)
        XCTAssertEqual(realBidInfo?.exp, expectedExp)
        XCTAssertEqual(realBidInfo?.nativeAdCacheId, expectedCacheId)
    }
    
    //forceSdkToChooseWinner + Winner = Contains Targeting Info
    func testForcedWinnerAndWinningBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true
        
        let expected = ResultCode.prebidDemandFetchSuccess
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = PBMBidResponseTransformer.makeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict as? NSDictionary
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //forceSdkToChooseWinner + No Winner = Doesn't contain Targeting Info
    func testForcedWinnerAndLoosingBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true
        let expected = ResultCode.prebidDemandNoBids
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = PBMBidResponseTransformer.makeValidResponseWithNonWinningTargetingInfo()
        let jsonDict = rawWinningBid.jsonDict as? NSDictionary
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertFalse((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //Don't forceSdkToChooseWinner + Winner = Contains Targeting Info
    func testNonForcedWinnerAndWinningBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = false
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = PBMBidResponseTransformer.makeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict as? NSDictionary
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //Don't forceSdkToChooseWinner + No Winner = Contains Targeting Info
    func testNonForcedWinnerAndNonWinningBid() {
        //given
        Targeting.shared.forceSdkToChooseWinner = false
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.banner])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = PBMBidResponseTransformer.makeValidResponseWithNonWinningTargetingInfo()
        let jsonDict = rawWinningBid.jsonDict as? NSDictionary
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(adObject["hb_bidder"] as? String, "Test-Bidder-1")
        XCTAssertEqual(resultCode, expected)
    }
    
    //forceSdkToChooseWinner + Native Format Winner = Contains Targeting Info
    func testForcedWinnerAndWinningBidNativeFormat() {
        //given
        Targeting.shared.forceSdkToChooseWinner = true
        
        let expected = ResultCode.prebidDemandFetchSuccess
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.native])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = PBMBidResponseTransformer.makeNativeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict as? NSDictionary
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertNotNil(bidResponse.targetingInfo?[PrebidLocalCacheIdKey])
        XCTAssertTrue((adObject.allKeys as? [String])?.contains(PrebidLocalCacheIdKey) ?? false)
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    //Don't forceSdkToChooseWinner + Native Format Winner = Contains Targeting Info
    func testNonForcedWinnerAndWinningBidNativeFormat() {
        //given
        Targeting.shared.forceSdkToChooseWinner = false
        
        let expected = ResultCode.prebidDemandFetchSuccess
        
        let adUnit = AdUnit(configId: "138c4d03-0efb-4498-9dc6-cb5a9acb2ea4", size: CGSize(width: 300, height: 250), adFormats: [.native])
        //This needs to after AdUnit init as the AdUnit enables this value.
        //We need to disabled to not look for cache id for winning bid
        Prebid.shared.useCacheForReportingWithRenderingAPI = false
        let adObject = NSMutableDictionary()
        let rawWinningBid = PBMBidResponseTransformer.makeNativeValidResponse(bidPrice: 0.75)
        let jsonDict = rawWinningBid.jsonDict as? NSDictionary
        let bidResponse = BidResponse(jsonDictionary: jsonDict ?? [:])
        
        //when
        let resultCode = adUnit.setUp(adObject, with: bidResponse)
        
        //then
        XCTAssertNotNil(bidResponse.targetingInfo?[PrebidLocalCacheIdKey])
        XCTAssertTrue((adObject.allKeys as? [String])?.contains(PrebidLocalCacheIdKey) ?? false)
        XCTAssertTrue((adObject.allKeys as? [String])?.contains("hb_bidder") ?? false)
        XCTAssertEqual(resultCode, expected)
    }
    
    func testBidInfoCompletion() {
        Prebid.shared.prebidServerAccountId = "test-account-id"
        
        defer {
            Prebid.shared.prebidServerAccountId = ""
        }
        
        guard let json = UtilitiesForTesting.loadFileAsDictFromBundle("sample_ortb_native_with_win_event.json") as PrebidMobile.JsonDictionary? else {
            XCTFail("Couldn't load `sample_ortb_native_with_win_event.json` file.")
            return
        }
        
        let bidRequester = MockPBMBidRequester(jsonDictionary: json)
        let adUnit = AdUnit(bidRequester: bidRequester, configId: "test-config-id", size: CGSize.zero, adFormats: [])
        
        let expectation = expectation(description: "Fetch demand completed.")
        adUnit.baseFetchDemand { bidInfo in
            expectation.fulfill()
            
            XCTAssertEqual(bidInfo.resultCode, .prebidDemandFetchSuccess)
            
            XCTAssertNotNil(bidInfo.targetingKeywords)
            XCTAssertNotNil(bidInfo.exp)
            XCTAssertNotNil(bidInfo.nativeAdCacheId)
            XCTAssertNotNil(bidInfo.events[BidInfo.EVENT_WIN], "There is no win event in bid response.")
            XCTAssertNotNil(bidInfo.events[BidInfo.EVENT_IMP], "There is no imp event in bid response.")
            XCTAssertFalse(bidInfo.events.isEmpty)
        }
        
        waitForExpectations(timeout: 30.0)
    }
    
    func testFetchDemandAutoRefresh() {
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
        
        waitForExpectations(timeout: 10, handler: nil)
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)

    }
    
    func testFetchDemandResumeAutoRefresh() {
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
        
        waitForExpectations(timeout: 10, handler: nil)
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)

    }
    
    func testFetchDemandBidsAutoRefresh() {
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

        waitForExpectations(timeout: 10, handler: nil)
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        
        //then
        XCTAssertEqual(expectedFetchDemandCount, fetchDemandCount)

    }
    
    func testFetchDemandBidsAutoRefreshWithSimilarGlobalTimeout() {
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        //given
        let expectedFetchDemandCount = 2
        let exception = expectation(description: "\(#function)")
        exception.expectedFulfillmentCount = expectedFetchDemandCount
        exception.assertForOverFulfill = false
        
        guard let json = UtilitiesForTesting.loadFileAsDictFromBundle("sample_ortb_native_with_win_event.json") as PrebidMobile.JsonDictionary? else {
            XCTFail("Couldn't load `sample_ortb_native_with_win_event.json` file.")
            return
        }
        
        Prebid.shared.timeoutMillis = 800
        Prebid.shared.prebidServerHost = PrebidHost.Rubicon
        Prebid.shared.prebidServerAccountId = "1001"
        
        let bidRequester = MockPBMBidRequester(jsonDictionary: json)
        let adUnit = AdUnit(bidRequester: bidRequester, configId: "1001-1", size: .zero, adFormats: [])
        adUnit.setAutoRefreshMillis(time: 800)
        
        var fetchDemandCount = 0
        
        //when
        adUnit.fetchDemand(completionBidInfo: { bid in
            XCTAssertNotEqual(bid.resultCode, .prebidDemandTimedOut)
            fetchDemandCount += 1
            exception.fulfill()
        })

        waitForExpectations(timeout: 10, handler: nil)
        AdUnitSwizzleHelper.toggleCheckRefreshTime()
        
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
    
    // MARK: - [DEPRECATED API] adunit context data aka inventory data (imp[].ext.context.data)
    
    func testAddContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextData(key: key1, value: value1)
        let dictionary = adUnit.getExtDataDictionary()
        
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
        let dictionary = adUnit.getExtDataDictionary()
        
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
        let dictionary = adUnit.getExtDataDictionary()
        
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
        let dictionary = adUnit.getExtDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - [DEPRECATED API] adunit context keywords (imp[].ext.context.keywords)
    
    func testAddContextKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextKeyword(element1)
        let set = adUnit.getExtKeywordsSet()
        
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
        let set = adUnit.getExtKeywordsSet()
        
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
        let set = adUnit.getExtKeywordsSet()
        
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
        let set = adUnit.getExtKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
    
    // MARK: - adunit ext data aka inventory data (imp[].ext.data)
    
    func testAddExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addExtData(key: key1, value: value1)
        let dictionary = adUnit.getExtDataDictionary()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.updateExtData(key: key1, value: set)
        
        //when
        let dictionary = adUnit.getExtDataDictionary()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addExtData(key: key1, value: value1)
        
        //when
        adUnit.removeExtData(forKey: key1)
        let dictionary = adUnit.getExtDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearExtData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addExtData(key: key1, value: value1)
        
        //when
        adUnit.clearExtData()
        let dictionary = adUnit.getExtDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - adunit ext keywords (imp[].ext.keywords)
    
    func testAddExtKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addExtKeyword(element1)
        let set = adUnit.getExtKeywordsSet()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddExtKeywords() {
        //given
        let element1 = "element1"
        let inputSet: Set = [element1]
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addExtKeywords(inputSet)
        let set = adUnit.getExtKeywordsSet()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveExtKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addExtKeyword(element1)
        
        //when
        adUnit.removeExtKeyword(element1)
        let set = adUnit.getExtKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearExtKeywords() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addExtKeyword(element1)
        
        //when
        adUnit.clearExtKeywords()
        let set = adUnit.getExtKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
    
    // MARK: - global context data aka inventory data (app.content.data)
    
    func testSetAppContent() {
        //given
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
    
    // MARK: - global user data aka visitor data (user.data)

    func testAddUserDataObjects() {
        //given
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
        let adUnit = AdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250), adFormats: [.banner])
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
    
    func testAdUnitSetAdPosition() {
        let adUnit = AdUnit(
            configId: "test",
            size: CGSize(width: 300, height: 250),
            adFormats: [.banner, .video]
        )
        
        let adUnitConfig = adUnit.adUnitConfig
        
        adUnit.adPosition = .header
        
        XCTAssertEqual(adUnit.adPosition, adUnitConfig.adPosition)
        XCTAssertEqual(adUnitConfig.adPosition, .header)
        
        adUnit.adPosition = .footer
        
        XCTAssertEqual(adUnit.adPosition, adUnitConfig.adPosition)
        XCTAssertEqual(adUnitConfig.adPosition, .footer)
    }
}
