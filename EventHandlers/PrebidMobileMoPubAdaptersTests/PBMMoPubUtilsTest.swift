/*   Copyright 2018-2021 Prebid.org, Inc.
 
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
import MoPubSDK
import PrebidMobile
@testable import PrebidMobileMoPubAdapters

class PBMMoPubUtilsTest: XCTestCase, RawWinningBidFabricator {
    
    var adView: MPAdView?
    
    var mediationDelegate: PrebidMediationDelegate?
    
    override func setUp() {
        super.setUp()
        adView = MPAdView()
        mediationDelegate = MoPubMediationBannerUtils(mopubView: adView!)
    }
    
    func testAdObjectSetUpCleanUp() {
        
        let initialKeyWords = "key1,key2"
        let targetingInfo = [
            "hb_pb": "0.10",
            "hb_size": "320x50"
        ];
        let sortedKeywords = ["hb_pb:0.10", "hb_size:320x50", "key1", "key2"]
        let rawBid = makeRawWinningBidRendering(price: 0.75, bidder: "some bidder", cacheID: "some-cache-id")
        let bid = Bid(bid: rawBid)
        let configId = "configId"
        
        adView!.keywords = initialKeyWords
        
        guard mediationDelegate!.setUpAdObject(configId: configId,
                                               configIdKey: PBMMediationConfigIdKey,
                                               targetingInfo: targetingInfo,
                                               extrasObject: bid,
                                               extrasObjectKey: PBMMediationAdUnitBidKey) else {
            XCTFail()
            return
        }
        
        let bidKeywords = adView!.keywords?.components(separatedBy: ",").sorted()
        
        XCTAssertEqual(bidKeywords, sortedKeywords)
        XCTAssertEqual(adView!.localExtras?[PBMMediationAdUnitBidKey] as! Bid, bid)
        XCTAssertEqual(adView!.localExtras?[PBMMediationConfigIdKey] as! String, configId)
        
        mediationDelegate!.cleanUpAdObject()
        
        XCTAssertEqual(adView!.keywords, initialKeyWords)
        XCTAssertEqual(adView!.localExtras?.count, 0)
    }
    
    func testCorrectBannerAdObjectSetUp() {
        let mopubView = MPAdView()
        let testIntitialExtras = ["existingKey": "existingValue"]
        let testInitialKeywords = "existingKey:existingValue"
        let bid = makeRawWinningBidRendering(price: 0.10, bidder: "TestBidder", cacheID: "testCacheId")
        mopubView.keywords = testInitialKeywords
        mopubView.localExtras = testIntitialExtras
        let mediationDelegate = MoPubMediationBannerUtils(mopubView: mopubView)
        guard mediationDelegate.setUpAdObject(configId: "testConfigId",
                                              configIdKey: "testConfigIdKey",
                                              targetingInfo: ["test": "test"],
                                              extrasObject: bid,
                                              extrasObjectKey: "testExtrasObjectKey") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(mediationDelegate.mopubView.keywords.contains(testInitialKeywords))
        testIntitialExtras.forEach { key, value in
            if !mediationDelegate.mopubView.localExtras.keys.contains(key) ||
                !mediationDelegate.mopubView.localExtras.values.contains(where: {
                    let stringValue = $0 as? String
                    return stringValue == value
                }) {
                XCTFail()
            }
        }
    }
    
    func testCorrectInterstitialAdObjectSetUp() {
        let mopubController = MPInterstitialAdController()
        let testIntitialExtras = ["existingKey": "existingValue"]
        let testInitialKeywords = "existingKey:existingValue"
        let bid = makeRawWinningBidRendering(price: 0.10, bidder: "TestBidder", cacheID: "testCacheId")
        mopubController.keywords = testInitialKeywords
        mopubController.localExtras = testIntitialExtras
        let mediationDelegate = MoPubMediationInterstitialUtils(mopubController: mopubController)
        guard mediationDelegate.setUpAdObject(configId: "testConfigId",
                                              configIdKey: "testConfigIdKey",
                                              targetingInfo: ["test": "test"],
                                              extrasObject: bid,
                                              extrasObjectKey: "testExtrasObjectKey") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(mediationDelegate.mopubController.keywords.contains(testInitialKeywords))
        testIntitialExtras.forEach { key, value in
            if !mediationDelegate.mopubController.localExtras.keys.contains(key) ||
                !mediationDelegate.mopubController.localExtras.values.contains(where: {
                    let stringValue = $0 as? String
                    return stringValue == value
                }) {
                XCTFail()
            }
        }
    }
    
    func testCorrectRewardedAdObjectSetUp() {
        let bidInfoWrapper = MediationBidInfoWrapper()
        let testIntitialExtras = ["existingKey": "existingValue"]
        let testInitialKeywords = "existingKey:existingValue"
        let bid = makeRawWinningBidRendering(price: 0.10, bidder: "TestBidder", cacheID: "testCacheId")
        bidInfoWrapper.keywords = testInitialKeywords
        bidInfoWrapper.localExtras = testIntitialExtras
        let mediationDelegate = MoPubMediationRewardedUtils(bidInfoWrapper: bidInfoWrapper)
        guard mediationDelegate.setUpAdObject(configId: "testConfigId",
                                              configIdKey: "testConfigIdKey",
                                              targetingInfo: ["test": "test"],
                                              extrasObject: bid,
                                              extrasObjectKey: "testExtrasObjectKey") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(mediationDelegate.bidInfoWrapper.keywords!.contains(testInitialKeywords))
        testIntitialExtras.forEach { key, value in
            if !mediationDelegate.bidInfoWrapper.localExtras!.keys.contains(key) ||
                !mediationDelegate.bidInfoWrapper.localExtras!.values.contains(where: {
                    let stringValue = $0 as? String
                    return stringValue == value
                }) {
                XCTFail()
            }
        }
    }
    
    func testCorrectNativeAdObjectSetUp() {
        let targeting = MPNativeAdRequestTargeting()!
        let testIntitialExtras = ["existingKey": "existingValue"]
        let testInitialKeywords = "existingKey:existingValue"
        let bid = makeRawWinningBidRendering(price: 0.10, bidder: "TestBidder", cacheID: "testCacheId")
        targeting.keywords = testInitialKeywords
        targeting.localExtras = testIntitialExtras
        let mediationDelegate = MoPubMediationNativeUtils(targeting: targeting)
        guard mediationDelegate.setUpAdObject(configId: "testConfigId",
                                              configIdKey: "testConfigIdKey",
                                              targetingInfo: ["test": "test"],
                                              extrasObject: bid,
                                              extrasObjectKey: "testExtrasObjectKey") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(mediationDelegate.targeting.keywords!.contains(testInitialKeywords))
        testIntitialExtras.forEach { key, value in
            if !mediationDelegate.targeting.localExtras!.keys.contains(key) ||
                !mediationDelegate.targeting.localExtras!.values.contains(where: {
                    let stringValue = $0 as? String
                    return stringValue == value
                }) {
                XCTFail()
            }
        }
    }
}
