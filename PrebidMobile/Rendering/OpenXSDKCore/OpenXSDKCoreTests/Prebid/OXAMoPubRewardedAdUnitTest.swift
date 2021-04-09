//
//  OXAMoPubRewardedAdUnitTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXAMoPubRewardedAdUnitTest: XCTestCase {
    func testDefaultSettings() {
        let adUnit = OXAMoPubRewardedAdUnit(configId: "prebidConfigId")
        let adUnitConfig = adUnit.adUnitConfig
        
        XCTAssertTrue(adUnitConfig.isInterstitial)
        XCTAssertTrue(adUnitConfig.isOptIn)
        OXMAssertEq(adUnitConfig.adPosition, .fullScreen)
        OXMAssertEq(adUnitConfig.adFormat, .video)
        XCTAssertEqual(adUnitConfig.videoPlacementType.rawValue, 5)
    }

}
