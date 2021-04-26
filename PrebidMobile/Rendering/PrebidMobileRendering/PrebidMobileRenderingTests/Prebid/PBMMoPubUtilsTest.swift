//
//  PBMMoPubUtilsTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

@objc class MoPubAdObject: NSObject, PBMMoPubAdObjectProtocol  {
    var keywords: String?
    
    var localExtras: [AnyHashable : Any]?
}

class PBMMoPubUtilsTest: XCTestCase, RawWinningBidFabricator {

    func testIsCorrectAdObject() {
        XCTAssertTrue(PBMMoPubUtils.isCorrectAdObject(MoPubAdObject()))
        
        XCTAssertFalse(PBMMoPubUtils.isCorrectAdObject(UILabel()))
        
        
        @objc class WrongAdObject1: NSObject {
            @objc var keywords: NSString?
        }
        XCTAssertFalse(PBMMoPubUtils.isCorrectAdObject(WrongAdObject1()))
        
        @objc class WrongAdObject2: NSObject {
            @objc var localExtras: NSDictionary?
        }
        XCTAssertFalse(PBMMoPubUtils.isCorrectAdObject(WrongAdObject2()))
        
        @objc class WrongAdObject3: NSObject {
            @objc var keywords: NSString {
                get {
                    return ""
                }
            }
            @objc var localExtras: NSDictionary?
        }
        XCTAssertFalse(PBMMoPubUtils.isCorrectAdObject(WrongAdObject3()))
        
        @objc class WrongAdObject4: NSObject {
            @objc var keywords: NSString?
            @objc var localExtras: NSDictionary {
                get {
                   return NSDictionary()
                }
            }
        }
        XCTAssertFalse(PBMMoPubUtils.isCorrectAdObject(WrongAdObject4()))
    }
    
    func testAdObjectSetUpCleanUp() {
        
        let initialKeyWords = "key1,key2"
        let targetingInfo = [
            "hb_pb": "0.10",
            "hb_size": "320x50"
        ];
        let sortedKeywords = ["hb_pb:0.10", "hb_size:320x50", "key1", "key2"]
        let bid = PBMBid()
        let configId = "configId"
        
        let adObject = MoPubAdObject()
        adObject.keywords = initialKeyWords
        
        PBMMoPubUtils.setUpAdObject(adObject,
                                    withConfigId: configId,
                                    targetingInfo: targetingInfo,
                                    extraObject: bid,
                                    forKey: PBMMoPubAdUnitBidKey)
        
        let bidKeywords = adObject.keywords?.components(separatedBy: ",").sorted()
        
        XCTAssertEqual(bidKeywords, sortedKeywords)
        XCTAssertEqual(adObject.localExtras?[PBMMoPubAdUnitBidKey] as! PBMBid, bid)
        XCTAssertEqual(adObject.localExtras?[PBMMoPubConfigIdKey] as! String, configId)
        
        PBMMoPubUtils.cleanUpAdObject(adObject)
        
        XCTAssertEqual(adObject.keywords, initialKeyWords)
        XCTAssertEqual(adObject.localExtras?.count, 0)
    }
    
    func testFindNativeAd() {
        let emptyExtras: [AnyHashable : Any] = [:]
        let errorExpectation = expectation(description: "Error finding native ad expectation")
        PBMMoPubUtils.findNativeAd(emptyExtras) { _, error in
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
        let bid = PBMBid(bid: rawBid)!
        let responseInfo = PBMDemandResponseInfo(fetchDemandResult: .ok, bid: bid, configId: configId) {
            $1(markupString)
        }
        let targetingInfo = [
            "hb_pb": "0.10",
        ];
        
        let adObject = MoPubAdObject()
        PBMMoPubUtils.setUpAdObject(adObject,
                                    withConfigId: configId,
                                    targetingInfo: targetingInfo,
                                    extraObject: responseInfo,
                                    forKey: PBMMoPubAdNativeResponseKey)
        
        let successExpectation = expectation(description: "Success finding Native Ad expectation")
        PBMMoPubUtils.findNativeAd(adObject.localExtras) { nativeAd, _ in
            if nativeAd != nil {
                successExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1)
    }
}
