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

import UIKit
import XCTest

@testable import PrebidMobile

class BasicParameterBuilderPureTargetingTest: XCTestCase {
    
    override class func setUp() {
        Targeting.shared.coppa = nil
    }
    
    func testParameterBuilderNoUserAgeNoCoppa() {
        let targeting = Targeting.shared
        let builder = PBMBasicParameterBuilder(adConfiguration:AdConfiguration(),
                                               sdkConfiguration:Prebid.mock,
                                               sdkVersion:"MOCK_SDK_VERSION",
                                               targeting: targeting)
        
        let bidRequest = PBMORTBBidRequest()
        builder.build(bidRequest)
        
        //Check Regs
        XCTAssertNil(bidRequest.regs.coppa)
    }
}
