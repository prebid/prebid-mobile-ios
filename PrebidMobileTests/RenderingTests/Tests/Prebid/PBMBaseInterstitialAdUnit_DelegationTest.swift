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

class MockInterstitialAdUnit: InterstitialRenderingAdUnit, WinningBidResponseFabricator {
    override var lastBidResponse: BidResponseForRendering? {
        return makeWinningBidResponse(bidPrice: 0.85)
    }
}

class MockRewardedAdUnit: RewardedAdUnit, WinningBidResponseFabricator {
    override var lastBidResponse: BidResponseForRendering? {
        return makeWinningBidResponse(bidPrice: 0.85)
    }
}

class PBMBaseInterstitialAdUnit_DelegationTest: XCTestCase {
    override func tearDown() {
        PrebidRenderingConfig.reset()
        
        super.tearDown()
    }
    
    private let configId = "someConfigId"
    
    func testInterstitialDelegateCalls_noOptionalMethods() {
        let adUnit = MockInterstitialAdUnit(configID: configId)
        let delegate = DummyInterstitialDelegate()
        adUnit.delegate = delegate
        callInterstitialDelegateMethods(adUnit: adUnit)
    }
    
    func testInterstitialDelegateCalls_receiveAllMethods() {
        let adUnit = MockInterstitialAdUnit(configID: configId)
        let delegate = InterstitialProxyDelegate()
        adUnit.delegate = delegate
        callInterstitialDelegateMethods(adUnit: adUnit, proxyDelegate: delegate)
    }
    
    func testRewardedAdDelegateCalls_noOptionalMethods() {
        let adUnit = MockRewardedAdUnit(configID: configId, minSizePerc: nil, eventHandler: RewardedEventHandlerStandalone())
        let delegate = DummyRewardedAdDelegate()
        adUnit.delegate = delegate
        callRewardedAdDelegateMethods(adUnit: adUnit)
    }
    
    func testRewardedAdDelegateCalls_receiveAllMethods() {
        let adUnit = MockRewardedAdUnit(configID: configId, minSizePerc: nil, eventHandler: RewardedEventHandlerStandalone())
        let delegate = RewardedAdProxyDelegate()
        adUnit.delegate = delegate
        callRewardedAdDelegateMethods(adUnit: adUnit, proxyDelegate: delegate)
    }
    
    func testAccountErrorPropagationByInterstitial() {
        let testID = "auid"
        
        PrebidRenderingConfig.shared.accountID = ""
        
        let interstitial = MockInterstitialAdUnit(configID: testID)
        let exp = expectation(description: "loading callback called")
        let delegate = InterstitialProxyDelegate()
        interstitial.delegate = delegate
        delegate.onCall = { selector, args in
            XCTAssertEqual(selector, "interstitial:didFailToReceiveAdWithError:")
            XCTAssertEqual(args.count, 2)
            XCTAssertEqual(args[0] as? MockInterstitialAdUnit, interstitial)
            XCTAssertEqual(args[1] as? NSError, PBMError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        
        interstitial.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    func testAccountErrorPropagationByRewardedAd() {
        let testID = "auid"
        
        PrebidRenderingConfig.shared.accountID = ""
        
        let rewarded = MockRewardedAdUnit(configID: testID, minSizePerc: nil, eventHandler: RewardedEventHandlerStandalone())
        let exp = expectation(description: "loading callback called")
        let delegate = RewardedAdProxyDelegate()
        rewarded.delegate = delegate
        delegate.onCall = { selector, args in
            XCTAssertEqual(selector, "rewardedAd:didFailToReceiveAdWithError:")
            XCTAssertEqual(args.count, 2)
            XCTAssertEqual(args[0] as? MockRewardedAdUnit, rewarded)
            XCTAssertEqual(args[1] as? NSError, PBMError.invalidAccountId as NSError?)
            exp.fulfill()
        }
        
        rewarded.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    // MARK: - Helper classes
    
    private class DummyInterstitialDelegate: NSObject, InterstitialAdUnitDelegate {}
    private class DummyRewardedAdDelegate: NSObject, RewardedAdUnitDelegate {}
    
    private class BaseProxyDelegate: NSObject {
        let file: StaticString
        let line: UInt
        
        var onCall: ((String, [Any]) -> ())?
        
        init(file: StaticString = #file, line: UInt = #line) {
            self.file = file
            self.line = line
        }
        
        func report(selectorName: String, args: [Any]) {
            if let reportBlock = onCall {
                reportBlock(selectorName, args)
            } else {
                XCTFail("onCall not assigned", file: file, line: line)
            }
        }
    }
    
    private class InterstitialProxyDelegate: BaseProxyDelegate, InterstitialAdUnitDelegate {
        func interstitialDidReceiveAd(_ interstitial: InterstitialRenderingAdUnit) {
            report(selectorName: "interstitialDidReceiveAd:", args: [interstitial])
            XCTAssertNotNil(interstitial.lastBidResponse)
        }
        func interstitial(_ interstitial: InterstitialRenderingAdUnit, didFailToReceiveAdWithError error: Error?) {
            report(selectorName: "interstitial:didFailToReceiveAdWithError:", args: [interstitial, error as Any])
            XCTAssertNotNil(interstitial.lastBidResponse)
        }
        func interstitialWillPresentAd(_ interstitial: InterstitialRenderingAdUnit) {
            report(selectorName: "interstitialWillPresentAd:", args: [interstitial])
            XCTAssertNotNil(interstitial.lastBidResponse)
        }
        func interstitialDidDismissAd(_ interstitial: InterstitialRenderingAdUnit) {
            report(selectorName: "interstitialDidDismissAd:", args: [interstitial])
            XCTAssertNotNil(interstitial.lastBidResponse)
        }
        func interstitialWillLeaveApplication(_ interstitial: InterstitialRenderingAdUnit) {
            report(selectorName: "interstitialWillLeaveApplication:", args: [interstitial])
            XCTAssertNotNil(interstitial.lastBidResponse)
        }
        func interstitialDidClickAd(_ interstitial: InterstitialRenderingAdUnit) {
            report(selectorName: "interstitialDidClickAd:", args: [interstitial])
            XCTAssertNotNil(interstitial.lastBidResponse)
        }
    }
    
    private class RewardedAdProxyDelegate: BaseProxyDelegate, RewardedAdUnitDelegate {
        func rewardedAdDidReceiveAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdDidReceiveAd:", args: [rewardedAd])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
        func rewardedAd(_ rewardedAd: RewardedAdUnit, didFailToReceiveAdWithError error: Error?) {
            report(selectorName: "rewardedAd:didFailToReceiveAdWithError:", args: [rewardedAd, error as Any])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
        func rewardedAdWillPresentAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdWillPresentAd:", args: [rewardedAd])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
        func rewardedAdDidDismissAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdDidDismissAd:", args: [rewardedAd])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
        func rewardedAdWillLeaveApplication(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdWillLeaveApplication:", args: [rewardedAd])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
        func rewardedAdDidClickAd(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdDidClickAd:", args: [rewardedAd])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
        func rewardedAdUserDidEarnReward(_ rewardedAd: RewardedAdUnit) {
            report(selectorName: "rewardedAdUserDidEarnReward:", args: [rewardedAd])
            XCTAssertNotNil(rewardedAd.lastBidResponse)
        }
    }
    
    // MARK: - Helper Methods (Static)
    
    private static func buildFailOnCall(expectedSelector: String?, file: StaticString = #file, line: UInt = #line) -> (String, [Any]) -> () {
        let expectationText: String
        if let expectedSelector = expectedSelector {
            expectationText = " while expecting [\(expectedSelector)]"
        } else {
            expectationText = ""
        }
        return { calledSelector, passedArgs in
            XCTFail("Unexpected call to '\(calledSelector)' with args: \(passedArgs)" + expectationText,
                    file: file, line: line)
        }
    }
    
    private static func callDelegateMethod(proxyDelegate: BaseProxyDelegate?,
                                           expectedSelector: String, expectedArgs: [Any],
                                           file: StaticString = #file, line: UInt = #line,
                                           block: () throws -> ())
    {
        var called = false
        proxyDelegate?.onCall = { calledSelector, passedArgs in
            guard calledSelector == expectedSelector else {
                buildFailOnCall(expectedSelector: expectedSelector, file: file, line: line)(calledSelector, passedArgs)
                return
            }
            guard !called else {
                XCTFail("Multiple calls to [\(expectedSelector)]", file: file, line: line)
                return
            }
            XCTAssertFalse(called, file: file, line: line)
            called = true
            XCTAssertEqual(calledSelector, expectedSelector)
            XCTAssertEqual(passedArgs.count, expectedArgs.count)
            for i in 0..<expectedArgs.count {
                let passed = passedArgs[i] as AnyObject as? NSObject
                let expected = expectedArgs[i] as AnyObject as? NSObject
                XCTAssertEqual(passed, expected, file: file, line: line)
            }
        }
        XCTAssertNoThrow(try block(), file: file, line: line)
        proxyDelegate?.onCall = buildFailOnCall(expectedSelector: nil)
        XCTAssertEqual(called, proxyDelegate != nil, "delegate method [\(expectedSelector)] not called", file: file, line: line)
    }
    
    private func callProtectedSelectors(baseAdUnit: BaseInterstitialAdUnitProtocol,
                                        proxyDelegate: BaseProxyDelegate?,
                                        selectorPrefix: String?,
                                        file: StaticString = #file, line: UInt = #line)
    {
        enum FakeError: Error {
            case someFakeError
        }
        
        let prefix = selectorPrefix ?? ""
        
        func testCall(_ expectedSelector: String, args expectedArgs: [Any], block: () throws -> ()) {
            PBMBaseInterstitialAdUnit_DelegationTest.callDelegateMethod(proxyDelegate: proxyDelegate,
                                                                        expectedSelector: expectedSelector,
                                                                        expectedArgs: expectedArgs,
                                                                        file: file, line: line,
                                                                        block: block)
        }
        
        testCall("\(prefix)DidReceiveAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_didReceiveAd()
        }
        testCall("\(prefix):didFailToReceiveAdWithError:", args: [baseAdUnit, FakeError.someFakeError]) {
            baseAdUnit.callDelegate_didFailToReceiveAd(with: FakeError.someFakeError)
        }
        testCall("\(prefix)WillPresentAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_willPresentAd()
        }
        testCall("\(prefix)DidDismissAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_didDismissAd()
        }
        testCall("\(prefix)WillLeaveApplication:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_willLeaveApplication()
        }
        testCall("\(prefix)DidClickAd:", args: [baseAdUnit]) {
            baseAdUnit.callDelegate_didClickAd()
        }
    }
    
    private func callInterstitialDelegateMethods(adUnit: InterstitialRenderingAdUnit,
                                                 proxyDelegate: InterstitialProxyDelegate? = nil,
                                                 file: StaticString = #file, line: UInt = #line)
    {
        callProtectedSelectors(baseAdUnit: adUnit,
                               proxyDelegate: proxyDelegate,
                               selectorPrefix: "interstitial",
                               file: file, line: line)
    }
    
    private func callRewardedAdDelegateMethods(adUnit: RewardedAdUnit,
                                               proxyDelegate: RewardedAdProxyDelegate? = nil,
                                               file: StaticString = #file, line: UInt = #line)
    {
        func testCall(_ expectedSelector: String, args expectedArgs: [Any], block: () throws -> ()) {
            PBMBaseInterstitialAdUnit_DelegationTest.callDelegateMethod(proxyDelegate: proxyDelegate,
                                                                        expectedSelector: expectedSelector,
                                                                        expectedArgs: expectedArgs,
                                                                        file: file, line: line,
                                                                        block: block)
        }
        
        callProtectedSelectors(baseAdUnit: adUnit,
                               proxyDelegate: proxyDelegate,
                               selectorPrefix: "rewardedAd",
                               file: file, line: line)
        
        testCall("rewardedAdUserDidEarnReward:", args: [adUnit]) {
            adUnit.callDelegate_rewardedAdUserDidEarnReward()
        }
    }
    
}
