//
//  OXAAdLoadFlowControllerTest_CompositeMock.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

@testable import PrebidMobileRendering

class OXAAdLoadFlowControllerTest_CompositeMock {
    enum ExpectedCall {
        typealias BidRequestCall = (requesterOffset: Int, call: MockBidRequester.ExpectedCall)
        typealias BidRequesterFactoryCall = (OXAAdUnitConfig, OXABidRequesterProtocol)->OXABidRequesterProtocol
        
        case flowControllerDelegate(call: MockAdLoadFlowControllerDelegate.ExpectedCall)
        case adLoader(call: MockAdLoader.ExpectedCall)
        case primaryAdRequester(call: MockPrimaryAdRequester.ExpectedCall)
        case makeBidRequester(handler: BidRequesterFactoryCall)
        case bidRequester(call: BidRequestCall)
        case configValidation(call: OXAAdUnitConfigValidationBlock)
    }
    
    let mockFlowControllerDelegate: OXAAdLoadFlowControllerDelegate
    let mockAdLoader: OXAAdLoaderProtocol
    let mockPrimaryAdRequester: OXAPrimaryAdRequesterProtocol
    let mockRequesterFactory: (OXAAdUnitConfig)->OXABidRequesterProtocol
    let mockConfigValidator: OXAAdUnitConfigValidationBlock
    
    let getProgress: ()->(done: Int, total: Int)
    func checkIsFinished(file: StaticString = #file, line: UInt = #line) {
        let state = getProgress()
        XCTAssertEqual(state.done, state.total, file: file, line: line)
    }
    
    init(expectedCalls: [ExpectedCall], file: StaticString = #file, line: UInt = #line) {
        let nextCallIndexBox = NSMutableArray(object: NSNumber(0))
        let syncQueue = DispatchQueue(label: "OXAAdLoadFlowControllerTest.CompositeMock")
        
        getProgress = {
            syncQueue.sync {
                if nextCallIndexBox.count > 0, let nextCallIndex = nextCallIndexBox[0] as? NSNumber {
                    return (nextCallIndex.intValue, expectedCalls.count)
                } else {
                    return (0, -1)
                }
            }
        }
        
        let enumeratedCalls = expectedCalls.enumerated()
        func validateCallIndex(_ callIndex: Int, method: String)->() {
            let nextCallIndex = (nextCallIndexBox[0] as? NSNumber)?.intValue ?? 0
            nextCallIndexBox[0] = NSNumber(value: nextCallIndex + 1)
            if nextCallIndex == callIndex {
                print("[OXAAdLoadFlowControllerTest_CompositeMock] Step \(nextCallIndex) passed!")
            } else {
                XCTFail("[CompositeMock] Method \(method) called out of order: #\(callIndex), while waiting for #\(nextCallIndex)",
                        file: file, line: line)
            }
        }
        func mappedCalls<T>(_ converterKeyPath: KeyPath<ExpectedCall, T?>, injector: (T, @escaping ()->())->T) -> [T] {
            return enumeratedCalls.compactMap { pair in
                let rawElement = pair.element
                guard let rawVal = rawElement[keyPath: converterKeyPath] else {
                    return nil
                }
                let offset = pair.offset
                let newVal = injector(rawVal) {
                    syncQueue.sync {
                        validateCallIndex(offset, method: rawElement.description)
                    }
                }
                return newVal
            }
        }
        let flowControllerDelegateCalls = mappedCalls(\.asAdLoadFlowControllerDelegateCall) { $0.addingPrefixAction($1) }
        let adLoaderCalls = mappedCalls(\.asAdLoaderCall) { $0.addingPrefixAction($1) }
        let adRequesterCalls = mappedCalls(\.asPrimaryAdRequesterCall) {
            MockPrimaryAdRequester.compose(prefixAction: $1, expectedCall: $0)
        }
        let bidRequesterCalls = mappedCalls(\.asBidRequesterCall) { (call, action) in
            (call.requesterOffset, MockBidRequester.compose(prefixAction: action, expectedCall: call.call))
        }
        let factoryCalls = mappedCalls(\.asBidRequesterFactoryCall) { (call, action) in
            { adUnitConfig, mockRequester in
                action()
                return call(adUnitConfig, mockRequester)
            }
        }
        let configValidationCalls = mappedCalls(\.asConfigValidationCall) { (call, action) in
            { (config, renderWithApollo) in
                action()
                return call(config, renderWithApollo)
            }
        }
        
        mockFlowControllerDelegate = MockAdLoadFlowControllerDelegate(expectedCalls: flowControllerDelegateCalls,
                                                                      file: file, line: line)
        mockAdLoader = MockAdLoader(expectedCalls: adLoaderCalls, file: file, line: line)
        mockPrimaryAdRequester = MockPrimaryAdRequester(expectedCalls: adRequesterCalls, file: file, line: line)
        
        let nextRequesterIndexBox = NSMutableArray(object: NSNumber(0))
        
        mockRequesterFactory = { adUnitConfig in
            let requesterIndex: Int = syncQueue.sync {
                let result = (nextRequesterIndexBox[0] as! NSNumber).intValue
                nextRequesterIndexBox[0] = NSNumber(value: result + 1)
                return result
            }
            let designatedCalls = bidRequesterCalls
                .filter { $0.requesterOffset == requesterIndex }
                .map { $0.call }
            let mockRequester = MockBidRequester(expectedCalls: designatedCalls)
            if requesterIndex < factoryCalls.count {
                return factoryCalls[requesterIndex](adUnitConfig, mockRequester)
            } else {
                validateCallIndex(-1, method: "makeBidRequester (#\(requesterIndex))")
                return mockRequester
            }
        }
        
        let nextValidationCallIndexBox = NSMutableArray(object: NSNumber(0))
        
        mockConfigValidator = { (adUnitConfig, renderWithApollo) in
            let nextValidationCallIndex: Int = syncQueue.sync {
                let result = (nextValidationCallIndexBox[0] as! NSNumber).intValue
                nextValidationCallIndexBox[0] = NSNumber(value: result + 1)
                return result
            }
            if nextValidationCallIndex < configValidationCalls.count {
                return configValidationCalls[nextValidationCallIndex](adUnitConfig, renderWithApollo)
            } else {
                validateCallIndex(-1, method: "configValidation (#\(nextValidationCallIndex))")
                return true
            }
        }
    }
}

extension OXAAdLoadFlowControllerTest_CompositeMock.ExpectedCall {
    var asAdLoadFlowControllerDelegateCall: MockAdLoadFlowControllerDelegate.ExpectedCall? {
        switch self {
        case .flowControllerDelegate(let call):
            return call
        default:
            return nil
        }
    }
    var asAdLoaderCall: MockAdLoader.ExpectedCall? {
        switch self {
        case .adLoader(let call):
            return call
        default:
            return nil
        }
    }
    var asPrimaryAdRequesterCall: MockPrimaryAdRequester.ExpectedCall? {
        switch self {
        case .primaryAdRequester(let call):
            return call
        default:
            return nil
        }
    }
    var asBidRequesterCall: BidRequestCall? {
        switch self {
        case .bidRequester(let call):
            return call
        default:
            return nil
        }
    }
    var asBidRequesterFactoryCall: BidRequesterFactoryCall? {
        switch self {
        case .makeBidRequester(let call):
            return call
        default:
            return nil
        }
    }
    var asConfigValidationCall: OXAAdUnitConfigValidationBlock? {
        switch self {
        case .configValidation(let call):
            return call
        default:
            return nil
        }
    }
}

extension OXAAdLoadFlowControllerTest_CompositeMock.ExpectedCall: CustomStringConvertible {
    var description: String {
        switch self {
        case .flowControllerDelegate(let call):
            return "flowControllerDelegate.\(call)"
        case .adLoader(let call):
            return "adLoader.\(call)"
        case .primaryAdRequester:
            return "primaryAdRequester.requestAd"
        case .bidRequester:
            return "bidRequester.requestBids"
        case .makeBidRequester:
            return "makeBidRequester"
        case .configValidation:
            return "configValidation"
        }
    }
}
