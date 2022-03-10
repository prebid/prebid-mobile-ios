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

class MockAdLoadFlowControllerDelegate: NSObject, AdLoadFlowControllerDelegate {
    enum ExpectedCall {
        case adUnitConfig(provider: ()->AdUnitConfig)
        case failedWithError(handler: (PBMAdLoadFlowController, Error?)->())
        case willSendBidRequest(handler: (PBMAdLoadFlowController)->())
        case willRequestPrimaryAd(handler: (PBMAdLoadFlowController)->())
        case shouldContinue(handler: (PBMAdLoadFlowController)->Bool)
    }
    
    private let expectedCalls: [ExpectedCall]
    private var nextCallIndex = 0
    private let syncQueue = DispatchQueue(label: "MockAdLoadFlowControllerDelegate")
    
    private let file: StaticString
    private let line: UInt
    
    init(expectedCalls: [ExpectedCall], file: StaticString = #file, line: UInt = #line) {
        self.expectedCalls = expectedCalls
        self.file = file
        self.line = line
    }
    
    // MARK: - AdLoadFlowControllerDelegate
    
    var adUnitConfig: AdUnitConfig {
        let provider: (()->AdUnitConfig)? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoadFlowControllerDelegate] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .adUnitConfig(let provider):
                nextCallIndex += 1
                return provider
            default:
                XCTFail("[MockAdLoadFlowControllerDelegate] 'adUnitConfig' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        return provider?() ?? AdUnitConfig(configId: "")
    }
    
    func adLoadFlowController(_ adLoadFlowController: PBMAdLoadFlowController, failedWithError error: Error?) {
        let handler: ((PBMAdLoadFlowController, Error?)->())? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoadFlowControllerDelegate] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .failedWithError(let handler):
                nextCallIndex += 1
                return handler
            default:
                XCTFail("[MockAdLoadFlowControllerDelegate] 'failedWithError' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        handler?(adLoadFlowController, error)
    }
    
    func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: PBMAdLoadFlowController) {
        let handler: ((PBMAdLoadFlowController)->())? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoadFlowControllerDelegate] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .willSendBidRequest(let handler):
                nextCallIndex += 1
                return handler
            default:
                XCTFail("[MockAdLoadFlowControllerDelegate] 'willSendBidRequest' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        handler?(adLoadFlowController)
    }
    
    func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: PBMAdLoadFlowController) {
        let handler: ((PBMAdLoadFlowController)->())? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoadFlowControllerDelegate] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .willRequestPrimaryAd(let handler):
                nextCallIndex += 1
                return handler
            default:
                XCTFail("[MockAdLoadFlowControllerDelegate] 'willRequestPrimaryAd' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        handler?(adLoadFlowController)
    }
    
    func adLoadFlowControllerShouldContinue(_ adLoadFlowController: PBMAdLoadFlowController) -> Bool {
        let handler: ((PBMAdLoadFlowController)->Bool)? = syncQueue.sync {
            guard nextCallIndex < expectedCalls.count else {
                XCTFail("[MockAdLoadFlowControllerDelegate] Call index out of bounds: \(nextCallIndex) < \(expectedCalls.count)",
                        file: file, line: line)
                return nil
            }
            switch expectedCalls[nextCallIndex] {
            case .shouldContinue(let handler):
                nextCallIndex += 1
                return handler
            default:
                XCTFail("[MockAdLoadFlowControllerDelegate] 'shouldContinue' called while expecting for '\(expectedCalls[nextCallIndex])'",
                        file: file, line: line)
                return nil
            }
        }
        return handler?(adLoadFlowController) ?? false
    }
}

extension MockAdLoadFlowControllerDelegate.ExpectedCall: CustomStringConvertible {
    var description: String {
        switch self {
        case .adUnitConfig:          return "adUnitConfig"
        case .failedWithError:       return "failedWithError"
        case .willSendBidRequest:    return "willSendBidRequest"
        case .willRequestPrimaryAd:  return "willRequestPrimaryAd"
        case .shouldContinue:        return "shouldContinue"
        }
    }
}
extension MockAdLoadFlowControllerDelegate.ExpectedCall {
    func addingPrefixAction(_ prefixAction: @escaping ()->())->Self {
        switch self {
        case .adUnitConfig(let provider):
            return .adUnitConfig(provider: {
                prefixAction()
                return provider()
            })
        case .failedWithError(let handler):
            return .failedWithError(handler: {
                prefixAction()
                handler($0, $1)
            })
        case .willSendBidRequest(let handler):
            return .willSendBidRequest(handler: {
                prefixAction()
                handler($0)
            })
        case .willRequestPrimaryAd(let handler):
            return .willRequestPrimaryAd(handler: {
                prefixAction()
                handler($0)
            })
        case .shouldContinue(let handler):
            return .shouldContinue(handler: {
                prefixAction()
                return handler($0)
            })
        }
    }
}
