//
//  GADCustomNativeAdWrapperTest.swift
//  PrebidMobileGAMEventHandlersTests
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import XCTest
import GoogleMobileAds

@testable import PrebidMobileGAMEventHandlers

class GADCustomNativeAdWrapperTest: XCTestCase {

    func testProperties() {
        
        guard let customNativeAd = GADCustomNativeAdWrapper(customNativeAd: GADCustomNativeAd()) else {
            XCTFail()
            return
        }
        
        XCTAssertNil(customNativeAd.string(forKey:"test"))
    }
}
