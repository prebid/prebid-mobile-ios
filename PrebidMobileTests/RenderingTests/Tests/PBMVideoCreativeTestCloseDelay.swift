/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import Foundation
import XCTest
@testable import PrebidMobile

class PBMVideoCreativeTestCloseDelay : XCTestCase {
    
    func testCalculateCloseDelay() {
        var expected:TimeInterval
        var actual:TimeInterval
        
        let model = PBMCreativeModel(adConfiguration:AdConfiguration())
        model.displayDurationInSeconds = 10
        
        //if model is opt in or has companion ad - return display duration
        model.adConfiguration?.isRewarded = true
        model.hasCompanionAd = true
        
        expected = 10
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        //reset
        model.adConfiguration?.isRewarded = false
        model.hasCompanionAd = false
        
        //for video without end cart use skip delay
        model.adConfiguration?.videoControlsConfig.skipDelay = 5
        expected = 5
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        //reset
        model.adConfiguration?.videoControlsConfig.skipDelay = 1000000
        
        //if skipOffset is not nil and is less than video duration - use it
        model.skipOffset = 4
        expected = 4
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        //reset
        model.skipOffset = nil
        
        //Typical case - pub sets a 5s delay
        expected = 5
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        //If the pub doesn't set a value, the default is 2s
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:0)
        PBMAssertEq(actual, expected)
        
        //Highbound of videoLength
        expected = 10
        actual = calculateCloseDelay(with:model, pubCloseDelay:20)
        PBMAssertEq(actual, expected)
        
        //Highbound of 30 seconds
        model.displayDurationInSeconds = 100
        expected = 30
        actual = calculateCloseDelay(with:model, pubCloseDelay:50)
        PBMAssertEq(actual, expected)
        
        model.displayDurationInSeconds = 1
        
        //Edge case: 1 second long video, no pub value
        expected = 1
        actual = calculateCloseDelay(with:model, pubCloseDelay:0)
        PBMAssertEq(actual, expected)
        
        //Edge case: 1 second long video, pub sets 5s delay
        expected = 1
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        //Edge case: Negative video length, pub sets 5s delay
        model.displayDurationInSeconds = -1
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        //Edge case: Normal video length, pub sets -5s delay
        model.displayDurationInSeconds = 5
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:-5)
        PBMAssertEq(actual, expected)
        
        //Corner case: negative length and negative pub value
        model.displayDurationInSeconds = -5
        expected = 2
        actual = calculateCloseDelay(with:model, pubCloseDelay:-5)
        PBMAssertEq(actual, expected)
    }
    
    private func calculateCloseDelay(with model: PBMCreativeModel, pubCloseDelay:TimeInterval) -> TimeInterval {
        let creative = PBMVideoCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        return creative.calculateCloseDelay(forPubCloseDelay:pubCloseDelay)
    }
}
