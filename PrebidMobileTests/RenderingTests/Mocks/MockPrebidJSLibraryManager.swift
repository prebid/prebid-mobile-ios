//
//  MockPrebidJSLibraryManager.swift
//  PrebidMobileTests
//
//  Created by Olena Stepaniuk on 15.05.2023.
//  Copyright © 2023 AppNexus. All rights reserved.
//

import Foundation

@testable import PrebidMobile

class MockPrebidJSLibraryManager: PrebidJSLibraryManager {
    
    var omsdkScript: String?
    var mraidScript: String?
    
    override func getMRAIDLibrary() -> String? {
        return omsdkScript
    }
    
    override func getOMSDKLibrary() -> String? {
        return omsdkScript
    }
}
