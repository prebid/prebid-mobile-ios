//
//  PBMVastCreativeCompanionAdsTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
import Foundation

@testable import PrebidMobileRendering

class PBMVastCreativeCompanionAdsTest: XCTestCase {
    
    func testInit() {
        let creative = PBMVastCreativeCompanionAds()
        XCTAssert(creative.companions.count == 0)
        XCTAssert(creative.feasibleCompanions().count == 0)
        XCTAssert(creative.canPlayRequiredCompanions())
        XCTAssert(creative.requiredMode.isEmpty)
    }
    
    func testRequiredMode() {
        let creative = PBMVastCreativeCompanionAds()
       
        creative.requiredMode = PBMVastRequiredMode.all.rawValue
        XCTAssert(creative.canPlayRequiredCompanions())

        creative.requiredMode = PBMVastRequiredMode.any.rawValue
        XCTAssert(creative.canPlayRequiredCompanions())
    }
}
