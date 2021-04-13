//
//  MockThread.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation
import XCTest

// Use this class when need to test behavior in the global thread from the main thread.
final class MockNSThread : OXMNSThreadProtocol {
    
    var mockIsMainThread: Bool
    
    init(mockIsMainThread: Bool) {
        self.mockIsMainThread = mockIsMainThread
    }
    
    // MARK: - OXMNSThreadProtocol
    
    var isMainThread: Bool {
        return mockIsMainThread
    }
}

// Use this class when need to test switching the execution from the global threat to the main thread.
final class OXMThread : OXMNSThreadProtocol {
    
    var checkThreadCallback:((Bool) -> Void)
    
    init(checkThreadCallback: @escaping ((Bool) -> Void)) {
        self.checkThreadCallback = checkThreadCallback
    }
    
    // MARK: - OXMNSThreadProtocol
    
    var isMainThread: Bool {
        let isMainThread = Thread.isMainThread
        
        checkThreadCallback(isMainThread)
        
        return isMainThread
    }
}
