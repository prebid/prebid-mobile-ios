//
//  OXAAdUnitConfigTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXAAdUnitConfigTest: XCTestCase {
    
    func testIsNativeAd() {
        let adUnitConfig = OXAAdUnitConfig(configId: "dummy-config-id")
        XCTAssertFalse(adUnitConfig.adConfiguration.isNative)
        
        let nativeAdConfig = OXANativeAdConfiguration(assets: [OXANativeAssetTitle(length: 25)])
        adUnitConfig.nativeAdConfig = nativeAdConfig
        XCTAssertTrue(adUnitConfig.adConfiguration.isNative)
    }

    func testSetRefreshInterval() {
        let adUnitConfig = OXAAdUnitConfig(configId: "dummy-config-id")
        
        XCTAssertEqual(adUnitConfig.refreshInterval, 60)
        
        adUnitConfig.refreshInterval = 10   // less than the min value
        XCTAssertEqual(adUnitConfig.refreshInterval, 15)
        
        adUnitConfig.refreshInterval = 1000   // greater than the max value
        XCTAssertEqual(adUnitConfig.refreshInterval, 120)
    }

}
