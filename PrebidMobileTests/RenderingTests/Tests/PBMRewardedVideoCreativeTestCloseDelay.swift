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

class PBMRewardedVideoCreativeTestCloseDelay : XCTestCase {
    
    func testCalculateCloseDelay() {
        let expected: TimeInterval = 10
        var actual: TimeInterval
        
        let model = PBMCreativeModel(adConfiguration:AdConfiguration())
        model.adConfiguration?.isRewarded = true
        model.displayDurationInSeconds = 10
        
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
        
        // The pubCloseDelay has no matter. The value from adConfiguration should be returned
        actual = calculateCloseDelay(with:model, pubCloseDelay:5)
        PBMAssertEq(actual, expected)
    }
    
    private func calculateCloseDelay(with model: PBMCreativeModel, pubCloseDelay:TimeInterval) -> TimeInterval {
        
        let creative = PBMVideoCreative(creativeModel: model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData:Data())
        return creative.calculateCloseDelay(forPubCloseDelay:pubCloseDelay)
    }
}
