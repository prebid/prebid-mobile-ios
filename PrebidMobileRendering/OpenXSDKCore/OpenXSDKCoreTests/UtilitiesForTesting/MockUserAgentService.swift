//
//  MockUserAgentService.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

class MockUserAgentService : OXMUserAgentService {
    
    static let mockUserAgent = "TEST-USER-AGENT"
    
    override func getFullUserAgent() -> String {
        // return known value (version/build# changes from time to time )
        return MockUserAgentService.mockUserAgent
    }
    
    override func setUserAgent() {
        // Avoid superclass method
    }
}
