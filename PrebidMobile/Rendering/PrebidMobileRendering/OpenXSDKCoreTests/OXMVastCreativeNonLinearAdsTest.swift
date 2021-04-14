//
//  OXMVastCreativeNonLinearAdsTest.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class OXMVastCreativeNonLinearAdsTest: XCTestCase {
    
    // Verify OXMVastCreativeNonLinearAds.copyTracking() copies over the correct number of URIs
    func testCopyTracking() {
        
        let ad1 = OXMVastCreativeNonLinearAds()
        ad1.id = "111111"
        
        let nonLinear1 = OXMVastCreativeNonLinearAdsNonLinear()
        nonLinear1.clickThroughURI = "URI_1"
        nonLinear1.clickTrackingURIs = ["URI_1a", "URI_1b"]
        ad1.nonLinears.add(nonLinear1)
        
        let ad2 = OXMVastCreativeNonLinearAds()
        ad2.id = "222222"
        
        let nonLinear2 = OXMVastCreativeNonLinearAdsNonLinear()
        nonLinear2.clickThroughURI = "URI_2"
        nonLinear2.clickTrackingURIs = ["URI_2a", "URI_2b"]
        ad2.nonLinears.add(nonLinear2)
        
        // precondition: should contain only 2
        var nonLinear = ad1.nonLinears[0] as! OXMVastCreativeNonLinearAdsNonLinear
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1a"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1b"))
        XCTAssert(nonLinear.clickTrackingURIs.count == 2)
        
        ad1.copyTracking(fromNonLinearAds: ad2)
        
        // URIs in ad1 should contain all 4 URIs: "URI_1a", "URI_1b", "URI_2a", "URI_2b"
        
        nonLinear = ad1.nonLinears[0] as! OXMVastCreativeNonLinearAdsNonLinear
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1a"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_1b"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_2a"))
        XCTAssert(nonLinear.clickTrackingURIs.contains("URI_2b"))
        XCTAssert(nonLinear.clickTrackingURIs.count == 4)
    }
    
}
