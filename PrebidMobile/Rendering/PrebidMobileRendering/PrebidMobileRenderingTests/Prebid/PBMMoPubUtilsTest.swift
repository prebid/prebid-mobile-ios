//
//  MoPubUtilsTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

@objc class MoPubAdObject: NSObject  {
    @objc var keywords: String?
    @objc var localExtras: [AnyHashable : Any]?
}

class PBMMoPubUtilsTest: XCTestCase, RawWinningBidFabricator {

    func testIsCorrectAdObject() {
        XCTAssertTrue(MoPubUtils.isCorrectAdObject(MoPubAdObject()))
        
        XCTAssertFalse(MoPubUtils.isCorrectAdObject(UILabel()))
        
        
        @objc class WrongAdObject1: NSObject {
            @objc var keywords: NSString?
        }
        XCTAssertFalse(MoPubUtils.isCorrectAdObject(WrongAdObject1()))
        
        @objc class WrongAdObject2: NSObject {
            @objc var localExtras: NSDictionary?
        }
        XCTAssertFalse(MoPubUtils.isCorrectAdObject(WrongAdObject2()))
        
        @objc class WrongAdObject3: NSObject {
            @objc var keywords: NSString {
                get {
                    return ""
                }
            }
            @objc var localExtras: NSDictionary?
        }
        XCTAssertFalse(MoPubUtils.isCorrectAdObject(WrongAdObject3()))
        
        @objc class WrongAdObject4: NSObject {
            @objc var keywords: NSString?
            @objc var localExtras: NSDictionary {
                get {
                   return NSDictionary()
                }
            }
        }
        XCTAssertFalse(MoPubUtils.isCorrectAdObject(WrongAdObject4()))
    }
    
    func testAdObjectSetUpCleanUp() {
        
        let initialKeyWords = "key1,key2"
        let targetingInfo = [
            "hb_pb": "0.10",
            "hb_size": "320x50"
        ];
        let sortedKeywords = ["hb_pb:0.10", "hb_size:320x50", "key1", "key2"]
        let rawBid = makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: "some-cache-id")
        let bid = Bid(bid: rawBid)
        let configId = "configId"
        
        let adObject = MoPubAdObject()
        adObject.keywords = initialKeyWords
        
        guard MoPubUtils.setUpAdObject(adObject,
                                 configID: configId,
                                 targetingInfo: targetingInfo,
                                 extraObject: bid,
                                 forKey: PBMMoPubAdUnitBidKey) else {
            XCTFail()
            return
        }
        
        let bidKeywords = adObject.keywords?.components(separatedBy: ",").sorted()
        
        XCTAssertEqual(bidKeywords, sortedKeywords)
        XCTAssertEqual(adObject.localExtras?[PBMMoPubAdUnitBidKey] as! Bid, bid)
        XCTAssertEqual(adObject.localExtras?[PBMMoPubConfigIdKey] as! String, configId)
        
        MoPubUtils.cleanUpAdObject(adObject)
        
        XCTAssertEqual(adObject.keywords, initialKeyWords)
        XCTAssertEqual(adObject.localExtras?.count, 0)
    }
    
    func testFindNativeAd() {
        let emptyExtras: [AnyHashable : Any] = [:]
        let errorExpectation = expectation(description: "Error finding native ad expectation")
        MoPubUtils.findNativeAd(emptyExtras) { _, error in
            if error != nil {
                errorExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1)
        
        let configId = "config-id"
        let markupString = """
{"assets": [{"required": 1, "title": { "text": "OpenX (Title)" }}],
"link": {"url": "http://www.openx.com"}}
"""
        let rawBid = makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: "some-cache-id")
        let bid = Bid(bid: rawBid)
        let responseInfo = DemandResponseInfo(fetchDemandResult: .ok, bid: bid, configId: configId) {
            $1(markupString)
        }
        let targetingInfo = [
            "hb_pb": "0.10",
        ];
        
        let adObject = MoPubAdObject()
        guard MoPubUtils.setUpAdObject(adObject,
                                       configID: configId,
                                       targetingInfo: targetingInfo,
                                       extraObject: responseInfo,
                                       forKey: PBMMoPubAdNativeResponseKey) else {
            XCTFail()
            return
        }
        
        let successExpectation = expectation(description: "Success finding Native Ad expectation")
        MoPubUtils.findNativeAd(adObject.localExtras!) { nativeAd, _ in
            if nativeAd != nil {
                successExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1)
    }
}
