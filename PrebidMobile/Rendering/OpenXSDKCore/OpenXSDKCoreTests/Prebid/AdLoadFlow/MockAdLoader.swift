//
//  MockAdLoader.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import OpenXApolloSDK

class MockAdLoader: NSObject, OXAAdLoaderProtocol {
    enum ExpectedCall {
        case getFlowDelegate(provider: ()->OXAAdLoaderFlowDelegate?)
        case setFlowDelegate(handler: (OXAAdLoaderFlowDelegate?)->())
        case primaryAdRequester(provider: ()->OXAPrimaryAdRequesterProtocol)
        case createApolloAd(handler: (OXABid, OXAAdUnitConfig, (Any)->(), (@escaping ()->())->())->())
        case reportSuccess(handler: (Any, NSValue?)->())
    }

    private let expectedCalls: [ExpectedCall]
    private var nextCallIndex = 0
    private let syncQueue = DispatchQueue(label: "MockAdLoader")

    private let file: StaticString
    private let line: UInt

    init(expectedCalls: [ExpectedCall], file: StaticString = #file, line: UInt = #line) {
        self.expectedCalls = expectedCalls
        self.file = file
        self.line = line
    }

    // MARK: - OXAAdLoaderProtocol

    var flowDelegate: OXAAdLoaderFlowDelegate? {
        get {
            let provider: (()->OXAAdLoaderFlowDelegate?)? = syncQueue.sync {
                guard nextCallIndex < expectedCalls.count else {
                    XCTFail("[MockAdLoader] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                            file: file, line: line)
                    return nil
                }
                switch expectedCalls[nextCallIndex] {
                case .getFlowDelegate(let provider):
                    nextCallIndex += 1
                    return provider
                default:
                    XCTFail("[MockAdLoader] 'getFlowDelegate' called while expecting for '\(expectedCalls[nextCallIndex])'",
                            file: file, line: line)
                    return nil
                }
            }
            return provider?()
        }
        set {
            let handler: ((OXAAdLoaderFlowDelegate?)->())? = syncQueue.sync {
                guard nextCallIndex < expectedCalls.count else {
                    XCTFail("[MockAdLoader] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                            file: file, line: line)
                    return nil
                }
                switch expectedCalls[nextCallIndex] {
                case .setFlowDelegate(let handler):
                    nextCallIndex += 1
                    return handler
                default:
                    XCTFail("[MockAdLoader] 'setFlowDelegate' called while expecting for '\(expectedCalls[nextCallIndex])'",
                            file: file, line: line)
                    return nil
                }
            }
            handler?(newValue)
        }
    }

    var primaryAdRequester: OXAPrimaryAdRequesterProtocol {
        let provider: (()->OXAPrimaryAdRequesterProtocol)? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoader] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .primaryAdRequester(let provider):
                nextCallIndex += 1
                return provider
            default:
                XCTFail("[MockAdLoader] 'primaryAdRequester' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        return provider?() ?? MockPrimaryAdRequester(expectedCalls: [], file: file, line: line)
    }

    func createApolloAd(with bid: OXABid, adUnitConfig: OXAAdUnitConfig, adObjectSaver: @escaping (Any) -> Void, loadMethodInvoker: @escaping (@escaping () -> Void) -> Void) {
        let handler: ((OXABid, OXAAdUnitConfig, (Any)->(), (@escaping ()->())->())->())? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoader] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .createApolloAd(let handler):
                nextCallIndex += 1
                return handler
            default:
                XCTFail("[MockAdLoader] 'createApolloAd' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        handler?(bid, adUnitConfig, adObjectSaver, loadMethodInvoker)
    }

    func reportSuccess(withAdObject adObject: Any, adSize: NSValue?) {
        let handler: ((Any, NSValue?)->())? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoader] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .reportSuccess(let handler):
                nextCallIndex += 1
                return handler
            default:
                XCTFail("[MockAdLoader] 'reportSuccess' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        handler?(adObject, adSize)
    }
}

extension MockAdLoader.ExpectedCall: CustomStringConvertible {
    var description: String {
        switch self {
        case .getFlowDelegate:      return "getFlowDelegate"
        case .setFlowDelegate:      return "setFlowDelegate"
        case .primaryAdRequester:   return "primaryAdRequester"
        case .createApolloAd:       return "createApolloAd"
        case .reportSuccess:        return "reportSuccess"
        }
    }
}

extension MockAdLoader.ExpectedCall {
    func addingPrefixAction(_ prefixAction: @escaping ()->())->Self {
        switch self {
        case .getFlowDelegate(let provider):
            return .getFlowDelegate(provider: {
                prefixAction()
                return provider()
            })
        case .setFlowDelegate(let handler):
            return .setFlowDelegate(handler: {
                prefixAction()
                handler($0)
            })
        case .primaryAdRequester(let provider):
            return .primaryAdRequester(provider: {
                prefixAction()
                return provider()
            })
        case .createApolloAd(let handler):
            return .createApolloAd(handler: {
                prefixAction()
                handler($0, $1, $2, $3)
            })
        case .reportSuccess(let handler):
            return .reportSuccess(handler: {
                prefixAction()
                handler($0, $1)
            })
        }
    }
}
