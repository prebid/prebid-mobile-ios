/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
import Foundation
import XCTest

@testable import PrebidMobile

class PBMAdLoadFlowControllerTest_CompositeMock {
    enum ExpectedCall {
        typealias BidRequestCall = (requesterOffset: Int, call: MockBidRequester.ExpectedCall)
        typealias BidRequesterFactoryCall = (AdUnitConfig, PBMBidRequesterProtocol)->PBMBidRequesterProtocol
        
        case flowControllerDelegate(call: MockAdLoadFlowControllerDelegate.ExpectedCall)
        case adLoader(call: MockAdLoader.ExpectedCall)
        case primaryAdRequester(call: MockPrimaryAdRequester.ExpectedCall)
        case makeBidRequester(handler: BidRequesterFactoryCall)
        case bidRequester(call: BidRequestCall)
        case configValidation(call: PBMAdUnitConfigValidationBlock)
    }
    
    let mockFlowControllerDelegate: AdLoadFlowControllerDelegate
    let mockAdLoader: PBMAdLoaderProtocol
    let mockPrimaryAdRequester: PBMPrimaryAdRequesterProtocol
    let mockRequesterFactory: (AdUnitConfig)->PBMBidRequesterProtocol
    let mockConfigValidator: PBMAdUnitConfigValidationBlock
    
    let getProgress: ()->(done: Int, total: Int)
    func checkIsFinished(file: StaticString = #file, line: UInt = #line) {
        let state = getProgress()
        XCTAssertEqual(state.done, state.total, file: file, line: line)
    }
    
    init(expectedCalls: [ExpectedCall], file: StaticString = #file, line: UInt = #line) {
        let nextCallIndexBox = NSMutableArray(object: NSNumber(0))
        let syncQueue = DispatchQueue(label: "PBMAdLoadFlowControllerTest.CompositeMock")
        
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
                print("[PBMAdLoadFlowControllerTest_CompositeMock] Step \(nextCallIndex) passed!")
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
            { (config, renderWithPrebid) in
                action()
                return call(config, renderWithPrebid)
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
        
        mockConfigValidator = { (adUnitConfig, renderWithPrebid) in
            let nextValidationCallIndex: Int = syncQueue.sync {
                let result = (nextValidationCallIndexBox[0] as! NSNumber).intValue
                nextValidationCallIndexBox[0] = NSNumber(value: result + 1)
                return result
            }
            if nextValidationCallIndex < configValidationCalls.count {
                return configValidationCalls[nextValidationCallIndex](adUnitConfig, renderWithPrebid)
            } else {
                validateCallIndex(-1, method: "configValidation (#\(nextValidationCallIndex))")
                return true
            }
        }
    }
}

extension PBMAdLoadFlowControllerTest_CompositeMock.ExpectedCall {
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
    var asConfigValidationCall: PBMAdUnitConfigValidationBlock? {
        switch self {
        case .configValidation(let call):
            return call
        default:
            return nil
        }
    }
}

extension PBMAdLoadFlowControllerTest_CompositeMock.ExpectedCall: CustomStringConvertible {
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
