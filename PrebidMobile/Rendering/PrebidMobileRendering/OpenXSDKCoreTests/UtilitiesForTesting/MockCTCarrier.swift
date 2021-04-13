//
//  MockCTCarrier.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import CoreTelephony

class MockCTCarrier : CTCarrier {
    
    static let mockMobileCountryCode = "123"
    static let mockMobileNetworkCode = "456"
    static let mockCarrierName = "MOCK_CARRIER_NAME"
    
    override open var mobileCountryCode: String? {
        get {
            return MockCTCarrier.mockMobileCountryCode
        }
    }

    override open var mobileNetworkCode: String? {
        get {
            return MockCTCarrier.mockMobileNetworkCode
        }
    }
    
    override open var carrierName: String? {
        get {
            return MockCTCarrier.mockCarrierName
        }
    }
}
