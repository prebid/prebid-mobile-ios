//
//  GADNativeAdWrapper.swift
//  PrebidMobileGAMEventHandlersTests
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import XCTest

import GoogleMobileAds
@testable import PrebidMobileGAMEventHandlers

class GADNativeAdWrapperTest: XCTestCase {

    func testProperties() {
        
        guard let nativeAd = GADNativeAdWrapper(nativeAd: GADNativeAd()) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(nativeAd.headline)
        XCTAssertNil(nativeAd.callToAction)
        XCTAssertNil(nativeAd.body)
        XCTAssertNil(nativeAd.starRating)
        XCTAssertNil(nativeAd.store)
        XCTAssertNil(nativeAd.price)
        XCTAssertNil(nativeAd.advertiser)
    }

}
