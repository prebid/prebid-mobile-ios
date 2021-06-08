//
//  DemandResponseInfoTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class DemandResponseInfoTest: XCTestCase, RawWinningBidFabricator {
    private func makeWinningBid() -> Bid {
        let rawBid = makeRawWinningBid(price: 0.75, bidder: "some bidder", cacheID: "some-cache-id")
        let bid = Bid(bid: rawBid)
        XCTAssert(bid.isWinning)
        return bid
    }
    
    func testInit() {
        let winningBid = makeWinningBid()
        
        let testBlocks: [(fetchDemandResult: FetchDemandResult, bid: Bid?, configId: String?)] = [
            (.demandNoBids, nil, nil),
            (.ok, Bid(bid: PBMORTBBid<PBMORTBBidExt>()), "configID-1"),
            (.ok, winningBid, "configID-2"),
        ]
        
        for initArgs in testBlocks {
            let notifier: PBMWinNotifierBlock = { (bid, markupStringHandler) in
                XCTFail()
                markupStringHandler(nil)
            }
            
            let responseInfo = DemandResponseInfo(fetchDemandResult: initArgs.fetchDemandResult,
                                                     bid: initArgs.bid,
                                                     configId: initArgs.configId,
                                                     winNotifierBlock: notifier)
            
            XCTAssertEqual(responseInfo.fetchDemandResult, initArgs.fetchDemandResult)
            XCTAssertEqual(responseInfo.bid, initArgs.bid)
            XCTAssertEqual(responseInfo.configId, initArgs.configId)
            
            let noCallCheck = expectation(description: "no call")
            noCallCheck.isInverted = true
            
            waitForExpectations(timeout: 1)
        }
    }
    
    func testGetAdMarkupString_Ok() {
        let winningBid = makeWinningBid()
        
        let configID = "the-config-ID"
        
        let noCallExpectation = expectation(description: "no win call till fetch")
        noCallExpectation.isInverted = true
        
        let expectationToCall = NSMutableArray(object: noCallExpectation)
        let adMarkupString = "<div>Some Ad markup</div>"
        
        let responseInfo = DemandResponseInfo(fetchDemandResult: .ok, bid: winningBid, configId: configID) {
            (expectationToCall[0] as! XCTestExpectation).fulfill()
            XCTAssertEqual($0, winningBid)
            $1(adMarkupString)
        }
        
        waitForExpectations(timeout: 1)
        
        for i in 0..<3 {
            let winNotifierCalled = expectation(description: "win notifier called \(i)")
            expectationToCall[0] = winNotifierCalled
            
            let adMarkupStringReturned = expectation(description: "ad markup string returned \(i)")
            responseInfo.getAdMarkupString { markupString in
                adMarkupStringReturned.fulfill()
                XCTAssertEqual(markupString, adMarkupString)
            }
            
            waitForExpectations(timeout: 1)
        }
    }
    
    func testGetAdMarkupString_NoBid() {
        let responseInfo = DemandResponseInfo(fetchDemandResult: .ok, bid: nil, configId: nil) { _, _ in
            XCTFail()
        }
        
        let noWinNotifierCall = expectation(description: "win notifier not called")
        noWinNotifierCall.isInverted = true
        waitForExpectations(timeout: 1)
        
        let adMarkupStringReturned = expectation(description: "ad markup string returned")
        responseInfo.getAdMarkupString { markupString in
            adMarkupStringReturned.fulfill()
            XCTAssertNil(markupString)
        }
        waitForExpectations(timeout: 1)
    }
    
    func testGetNativeAd() {
        let someLinkUrl = "some link URL"
        
        let testBlocks: [(adMarkup: String?, expectedNativeAd: NativeAd?)] = [
            nil,
            "not a real native ad",
            """
{"link": {"url": "\(someLinkUrl)"}}
""",
        ].map { adString in
            if let adString = adString, let nativeAdMarkup = try? PBMNativeAdMarkup(jsonString: adString) {
                return (adString, NativeAd(nativeAdMarkup: nativeAdMarkup))
            } else {
                return (adString, nil)
            }
        }
        
        let winningBid = makeWinningBid()
        
        let configID = "the-config-ID"
        
        for nextMarkup in testBlocks {
            let noCallExpectation = expectation(description: "no win call till fetch")
            noCallExpectation.isInverted = true
            
            let expectationToCall = NSMutableArray(object: noCallExpectation)
            let adMarkupString = nextMarkup.adMarkup
            
            let responseInfo = DemandResponseInfo(fetchDemandResult: .ok, bid: winningBid, configId: configID) {
                (expectationToCall[0] as! XCTestExpectation).fulfill()
                XCTAssertEqual($0, winningBid)
                $1(adMarkupString)
            }
            
            waitForExpectations(timeout: 1)
            
            for i in 0..<3 {
                let winNotifierCalled = expectation(description: "win notifier called \(i)")
                expectationToCall[0] = winNotifierCalled
                
                let nativeAdReturned = expectation(description: "native ad returned \(i)")
                responseInfo.getNativeAd { nativeAd in
                    nativeAdReturned.fulfill()
                    XCTAssertEqual(nativeAd, nextMarkup.expectedNativeAd)
                }
                
                waitForExpectations(timeout: 1)
            }
        }
    }
}
