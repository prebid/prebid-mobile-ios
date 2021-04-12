//
//  OXMVastCreativeCompanionAdsTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
import Foundation

@testable import OpenXApolloSDK

class OXMVastCreativeCompanionAdsTest: XCTestCase {
    
    func testInit() {
        let creative = OXMVastCreativeCompanionAds()
        XCTAssert(creative.companions.count == 0)
        XCTAssert(creative.feasibleCompanions().count == 0)
        XCTAssert(creative.canPlayRequiredCompanions())
        XCTAssert(creative.requiredMode.isEmpty)
    }
    
    func testRequiredMode() {
        let creative = OXMVastCreativeCompanionAds()
       
        creative.requiredMode = OXMVastRequiredMode.all.rawValue
        XCTAssert(creative.canPlayRequiredCompanions())

        creative.requiredMode = OXMVastRequiredMode.any.rawValue
        XCTAssert(creative.canPlayRequiredCompanions())
    }
}
