//
//  OXMVideoCreativeTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import OpenXApolloSDK

class OXMVideoCreativeTestCloseDelay : XCTestCase {

    func testCalculateCloseDelay() {
        var expected:TimeInterval
        var actual:TimeInterval
        
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.displayDurationInSeconds = 10
        
        //Typical case - pub sets a 5s delay
        expected = 5
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        OXMAssertEq(actual, expected)
        
        //If the pub doesn't set a value, the default is 2s
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:0)
        OXMAssertEq(actual, expected)
        
        //Highbound of videoLength
        expected = 10
        actual = calculateCloseDelay(with:model, pubCloseDelay:20)
        OXMAssertEq(actual, expected)
        
        //Highbound of 30 seconds
        model.displayDurationInSeconds = 100
        expected = 30
        actual = calculateCloseDelay(with:model, pubCloseDelay:50)
        OXMAssertEq(actual, expected)
        
        model.displayDurationInSeconds = 1

        //Edge case: 1 second long video, no pub value
        expected = 1
        actual = calculateCloseDelay(with:model, pubCloseDelay:0)
        OXMAssertEq(actual, expected)
        
        //Edge case: 1 second long video, pub sets 5s delay
        expected = 1
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        OXMAssertEq(actual, expected)
        
        //Edge case: Negative video length, pub sets 5s delay
        model.displayDurationInSeconds = -1
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        OXMAssertEq(actual, expected)
        
        //Edge case: Normal video length, pub sets -5s delay
         model.displayDurationInSeconds = 5
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:-5)
        OXMAssertEq(actual, expected)

        //Corner case: negative length and negative pub value
         model.displayDurationInSeconds = -5
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:-5)
        OXMAssertEq(actual, expected)
    }
    
    private func calculateCloseDelay(with model: OXMCreativeModel, pubCloseDelay:TimeInterval) -> TimeInterval {
        let creative = OXMVideoCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        return creative.calculateCloseDelay(forPubCloseDelay:pubCloseDelay)
    }
}
