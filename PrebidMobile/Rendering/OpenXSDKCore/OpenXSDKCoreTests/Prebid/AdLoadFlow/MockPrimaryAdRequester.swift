//
//  MockPrimaryAdRequester.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import OpenXApolloSDK

class MockPrimaryAdRequester: NSObject, OXAPrimaryAdRequesterProtocol {
    typealias ExpectedCall = (OXABidResponse?)->()
    
    private let expectedCalls: [ExpectedCall]
    private var nextCallIndex = 0
    private let syncQueue = DispatchQueue(label: "MockPrimaryAdRequester")
    
    private let file: StaticString
    private let line: UInt
    
    init(expectedCalls: [ExpectedCall], file: StaticString = #file, line: UInt = #line) {
        self.expectedCalls = expectedCalls
        self.file = file
        self.line = line
    }
    
    func requestAd(with bidResponse: OXABidResponse?) {
        let handler: ExpectedCall? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockPrimaryAdRequester] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            let handler = expectedCalls[nextCallIndex]
            nextCallIndex += 1
            return handler
        }
        handler?(bidResponse)
    }
}

extension MockPrimaryAdRequester {
    class func compose(prefixAction: @escaping ()->(), expectedCall: @escaping ExpectedCall)->ExpectedCall {
        return {
            prefixAction()
            expectedCall($0)
        }
    }
}
