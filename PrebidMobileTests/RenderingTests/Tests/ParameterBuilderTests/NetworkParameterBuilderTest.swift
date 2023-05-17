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


import Foundation
import XCTest
@testable import PrebidMobile

class NetworkParameterBuilderTest : XCTestCase {
    
    func testParameterBuilder() {
        let mockCTTelephonyNetworkInfo = MockCTTelephonyNetworkInfo()
        let mockReachability = MockReachability.shared
        let networkParameterBuilder = NetworkParameterBuilder(ctTelephonyNetworkInfo:mockCTTelephonyNetworkInfo, reachability: mockReachability)
        let bidRequest = PBMORTBBidRequest()
        
        networkParameterBuilder.build(bidRequest)
        
        PBMAssertEq(bidRequest.device.connectiontype, NSNumber(integerLiteral: mockReachability.currentReachabilityStatus.rawValue))
        
        if #available(iOS 16.0, *) {
            // do nothing - CTCarrier is deprecated
        } else {
            //
            let actualMccmnc = bidRequest.device.mccmnc
            let expectedMccmnc = "\(MockCTCarrier.mockMobileCountryCode)-\(MockCTCarrier.mockMobileNetworkCode)"
            PBMAssertEq(actualMccmnc, expectedMccmnc)
            
            let expectedCarrierName = MockCTCarrier.mockCarrierName
            let actualCarrierName = bidRequest.device.carrier
            PBMAssertEq(actualCarrierName, expectedCarrierName)
        }
    }
}
