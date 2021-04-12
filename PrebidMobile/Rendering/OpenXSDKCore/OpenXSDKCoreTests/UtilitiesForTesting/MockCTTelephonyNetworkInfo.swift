//
//  MockCTTelephonyNetworkInfo.swift
//  OpenXSDKCore
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import CoreTelephony

class MockCTTelephonyNetworkInfo : CTTelephonyNetworkInfo {
    
    var mockCTCarrier = MockCTCarrier()
    
    
    override var subscriberCellularProvider: CTCarrier? {
        get {
            return self.mockCTCarrier
        }
    }
    
    
}
