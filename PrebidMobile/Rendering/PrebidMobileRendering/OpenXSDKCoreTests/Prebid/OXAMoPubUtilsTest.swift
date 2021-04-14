//
//  OXAMoPubUtilsTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

@objc class MoPubAdObject: NSObject, OXAMoPubAdObjectProtocol  {
    var keywords: String?
    
    var localExtras: [AnyHashable : Any]?
}

class OXAMoPubUtilsTest: XCTestCase, RawWinningBidFabricator {

    func testIsCorrectAdObject() {
        XCTAssertTrue(OXAMoPubUtils.isCorrectAdObject(MoPubAdObject()))
        
        XCTAssertFalse(OXAMoPubUtils.isCorrectAdObject(UILabel()))
        
        
        @objc class WrongAdObject1: NSObject {
            @objc var keywords: NSString?
        }
        XCTAssertFalse(OXAMoPubUtils.isCorrectAdObject(WrongAdObject1()))
        
        @objc class WrongAdObject2: NSObject {
            @objc var localExtras: NSDictionary?
        }
        XCTAssertFalse(OXAMoPubUtils.isCorrectAdObject(WrongAdObject2()))
        
        @objc class WrongAdObject3: NSObject {
            @objc var keywords: NSString {
                get {
                    return ""
                }
            }
            @objc var localExtras: NSDictionary?
        }
        XCTAssertFalse(OXAMoPubUtils.isCorrectAdObject(WrongAdObject3()))
        
        @objc class WrongAdObject4: NSObject {
            @objc var keywords: NSString?
            @objc var localExtras: NSDictionary {
                get {
                   return NSDictionary()
                }
            }
        }
        XCTAssertFalse(OXAMoPubUtils.isCorrectAdObject(WrongAdObject4()))
    }
    
    func testAdObjectSetUpCleanUp() {
        
        let initialKeyWords = "key1,key2"
        let targetingInfo = [
            "hb_pb": "0.10",
            "hb_size": "320x50"
        ];
        let sortedKeywords = ["hb_pb:0.10", "hb_size:320x50", "key1", "key2"]
        let bid = OXABid()
        let configId = "configId"
        
        let adObject = MoPubAdObject()
        adObject.keywords = initialKeyWords
        
        OXAMoPubUtils.setUpAdObject(adObject,
                                    withConfigId: configId,
                                    targetingInfo: targetingInfo,
                                    extraObject: bid,
                                    forKey: OXAMoPubAdUnitBidKey)
        
        let bidKeywords = adObject.keywords?.components(separatedBy: ",").sorted()
        
        XCTAssertEqual(bidKeywords, sortedKeywords)
        XCTAssertEqual(adObject.localExtras?[OXAMoPubAdUnitBidKey] as! OXABid, bid)
        XCTAssertEqual(adObject.localExtras?[OXAMoPubConfigIdKey] as! String, configId)
        
        OXAMoPubUtils.cleanUpAdObject(adObject)
        
        XCTAssertEqual(adObject.keywords, initialKeyWords)
        XCTAssertEqual(adObject.localExtras?.count, 0)
    }
    
    func testFindNativeAd() {
        let emptyExtras: [AnyHashable : Any] = [:]
        let errorExpectation = expectation(description: "Error finding native ad expectation")
        OXAMoPubUtils.findNativeAd(emptyExtras) { _, error in
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
        let bid = OXABid(bid: rawBid)!
        let responseInfo = OXADemandResponseInfo(fetchDemandResult: .ok, bid: bid, configId: configId) {
            $1(markupString)
        }
        let targetingInfo = [
            "hb_pb": "0.10",
        ];
        
        let adObject = MoPubAdObject()
        OXAMoPubUtils.setUpAdObject(adObject,
                                    withConfigId: configId,
                                    targetingInfo: targetingInfo,
                                    extraObject: responseInfo,
                                    forKey: OXAMoPubAdNativeResponseKey)
        
        let successExpectation = expectation(description: "Success finding Native Ad expectation")
        OXAMoPubUtils.findNativeAd(adObject.localExtras) { nativeAd, _ in
            if nativeAd != nil {
                successExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1)
    }
}
