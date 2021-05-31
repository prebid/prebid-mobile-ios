//
//  PBMMoPubNativeAdUnitTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMMoPubNativeAdUnitTest: XCTestCase, WinningBidResponseFabricator {
    let configID = "testConfigID"
    let nativeAdConfig = NativeAdConfiguration(assets: [NativeAssetTitle(length: 25)])

    func testWrongAdObject() {
        let adUnit = MoPubNativeAdUnit(configID: configID, nativeAdConfiguration: nativeAdConfig)
        let badObjexpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(with: NSString()) { result in
            XCTAssertEqual(result, .wrongArguments)
            badObjexpectation.fulfill()
        }
        waitForExpectations(timeout: 0.2)
    }
    
    func testFetch() {
        let markupString = """
{"assets": [{"required": 1, "title": { "text": "OpenX (Title)" }}],
"link": {"url": "http://www.openx.com"}}
"""
        let bidPrice = 0.42
        let bidResponse = makeWinningBidResponse(bidPrice: bidPrice)
        
        let adUnit = NativeAdUnit(configID: configID,
                                  nativeAdConfiguration: nativeAdConfig) { adUnitConfig in
            return MockBidRequester(expectedCalls: [
                { responseHandler in
                    responseHandler(bidResponse, nil)
                },
            ])
        } winNotifierBlock: { _, adMarkupStringHandler in
            adMarkupStringHandler(markupString)
        }
        
        let moPubAdUnit = MoPubNativeAdUnit(nativeAdUnit: adUnit)
        
        let fetchExpectation = expectation(description: "fetchDemand executed")
        
        let targeting = MoPubAdObject()
        moPubAdUnit.fetchDemand(with: targeting) { result in
            XCTAssertEqual(result, .ok)
            PBMAssertEq(targeting.localExtras?[PBMMoPubAdNativeResponseKey] as? DemandResponseInfo, adUnit.lastDemandResponseInfo)
            fetchExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.2)
    }

}
