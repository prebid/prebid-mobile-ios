//
//  MockDelayedReachability.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation
@testable import OpenXApolloSDK

class MockDelayedReachability: OXMReachability {
    
    var isReachable = false
    
    override func isNetworkReachable() -> Bool {
        return isReachable
    }
    
    override func onNetworkRestored(_ reachableBlock: OXMNetworkReachableBlock!) {
        isReachable = true
        reachableBlock(self)
    }
}
