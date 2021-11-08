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

import XCTest
import Foundation

@testable import PrebidMobile

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
