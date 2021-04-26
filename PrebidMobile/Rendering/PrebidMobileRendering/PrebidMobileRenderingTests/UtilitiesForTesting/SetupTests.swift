//
//  SetupTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit

class SetupTests: NSObject {
    
    override init() {
        MockServer.singleton().connectionIDHeaderKey = PBMServerConnection.internalIDKey
    }
}
