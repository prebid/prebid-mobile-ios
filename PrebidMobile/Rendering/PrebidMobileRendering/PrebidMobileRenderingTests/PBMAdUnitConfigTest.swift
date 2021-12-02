//
//  PBMAdUnitConfigTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMAdUnitConfigTest: XCTestCase {
    
    func testIsNativeAd() {
        let adUnitConfig = AdUnitConfig(configID: "dummy-config-id")
        XCTAssertFalse(adUnitConfig.adConfiguration.isNative)
        
        let nativeAdConfig = NativeAdConfiguration(assets: [NativeAssetTitle(length: 25)])
        adUnitConfig.nativeAdConfiguration = nativeAdConfig
        XCTAssertTrue(adUnitConfig.adConfiguration.isNative)
    }

    func testSetRefreshInterval() {
        let adUnitConfig = AdUnitConfig(configID: "dummy-config-id")
        
        XCTAssertEqual(adUnitConfig.refreshInterval, 60)
        
        adUnitConfig.refreshInterval = 10   // less than the min value
        XCTAssertEqual(adUnitConfig.refreshInterval, 15)
        
        adUnitConfig.refreshInterval = 1000   // greater than the max value
        XCTAssertEqual(adUnitConfig.refreshInterval, 120)
    }

}
