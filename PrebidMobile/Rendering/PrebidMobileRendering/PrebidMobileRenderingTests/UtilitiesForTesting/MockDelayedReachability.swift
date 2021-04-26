//
//  MockDelayedReachability.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation

@testable import PrebidMobileRendering

class MockDelayedReachability: PBMReachability {
    
    var isReachable = false
    
    override func isNetworkReachable() -> Bool {
        return isReachable
    }
    
    override func onNetworkRestored(_ reachableBlock: PBMNetworkReachableBlock!) {
        isReachable = true
        reachableBlock(self)
    }
}
