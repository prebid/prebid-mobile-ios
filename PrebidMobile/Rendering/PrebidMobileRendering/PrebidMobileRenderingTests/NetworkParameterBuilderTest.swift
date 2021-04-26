//
//  NetworkParameterBuilderTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation


import Foundation
import XCTest
@testable import PrebidMobileRendering

class NetworkParameterBuilderTest : XCTestCase {
    
    func testParameterBuilder() {
        let mockCTTelephonyNetworkInfo = MockCTTelephonyNetworkInfo()
        let mockReachability = MockReachability.forInternetConnection()!
        let networkParameterBuilder = NetworkParameterBuilder(ctTelephonyNetworkInfo:mockCTTelephonyNetworkInfo, reachability: mockReachability)
        let bidRequest = PBMORTBBidRequest()        
        
        networkParameterBuilder.build(bidRequest)
        
        let actualMccmnc = bidRequest.device.mccmnc
        let expectedMccmnc = "\(MockCTCarrier.mockMobileCountryCode)-\(MockCTCarrier.mockMobileNetworkCode)"
        PBMAssertEq(actualMccmnc, expectedMccmnc)
        
        let expectedCarrierName = MockCTCarrier.mockCarrierName
        let actualCarrierName = bidRequest.device.carrier
        PBMAssertEq(actualCarrierName, expectedCarrierName)
    }
}
