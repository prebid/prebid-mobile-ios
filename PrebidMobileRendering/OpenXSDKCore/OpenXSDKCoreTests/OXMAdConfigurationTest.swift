//
//  OXMAdConfigurationTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMAdConfigurationTest: XCTestCase {
    
    func testIsInterstitialDisablesAutoRefresh() {
        let adConfiguration = OXMAdConfiguration()
        XCTAssertNotNil(adConfiguration.autoRefreshDelay)

        // Setting an auto refresh value for an interstitial should always result in `nil`.
        adConfiguration.isInterstitialAd = true
        adConfiguration.autoRefreshDelay = 1
        XCTAssertNil(adConfiguration.autoRefreshDelay)

        // Setting an interstitial back to false, should re-enable auto refresh. Admittedly, this
        // may be unnecessary.
        adConfiguration.isInterstitialAd = false
        XCTAssertNotNil(adConfiguration.autoRefreshDelay)
        
        // Expect the same effect from `forceInterstitialPresentation`
        adConfiguration.forceInterstitialPresentation = true
        XCTAssertNil(adConfiguration.autoRefreshDelay)
        adConfiguration.forceInterstitialPresentation = nil
        XCTAssertNotNil(adConfiguration.autoRefreshDelay)
    }
}
