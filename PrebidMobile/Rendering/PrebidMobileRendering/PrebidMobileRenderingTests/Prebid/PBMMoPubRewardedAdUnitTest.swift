//
//  PBMMoPubRewardedAdUnitTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMMoPubRewardedAdUnitTest: XCTestCase {
    func testDefaultSettings() {
        let adUnit = PBMMoPubRewardedAdUnit(configId: "prebidConfigId")
        let adUnitConfig = adUnit.adUnitConfig
        
        XCTAssertTrue(adUnitConfig.isInterstitial)
        XCTAssertTrue(adUnitConfig.isOptIn)
        PBMAssertEq(adUnitConfig.adPosition, .fullScreen)
        PBMAssertEq(adUnitConfig.adFormat, .video)
        XCTAssertEqual(adUnitConfig.videoPlacementType.rawValue, 5)
    }

}
