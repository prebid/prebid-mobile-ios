//
//  OXMVideoCreativeTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import PrebidMobileRendering

class OXMRewardedVideoCreativeTestCloseDelay : XCTestCase {

    func testCalculateCloseDelay() {
        let expected: TimeInterval = 10
        var actual: TimeInterval
        
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.adConfiguration?.isOptIn = true
        model.displayDurationInSeconds = 10
        
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        OXMAssertEq(actual, expected)
        
        // The pubCloseDelay has no matter. The value from adConfiguration should be returned
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        OXMAssertEq(actual, expected)
    }
    
    private func calculateCloseDelay(with model: OXMCreativeModel, pubCloseDelay:TimeInterval) -> TimeInterval {

        let creative = OXMVideoCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData:Data())
        return creative.calculateCloseDelay(forPubCloseDelay:pubCloseDelay)
    }
}
