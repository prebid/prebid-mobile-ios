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
import UIKit
import XCTest
import PrebidMobile

public let MockMediationAdUnitBidKey           = "PBM_BID"
public let MockMediationConfigIdKey            = "PBM_CONFIG_ID"
public let MockMediationAdNativeResponseKey    = "PBM_NATIVE_RESPONSE"
public let MockMediationTargetingInfoKey       = "PBM_TARGETING_INFO"

fileprivate let keywordsSeparator              = ","
fileprivate let HBKeywordPrefix                = "hb_"

@objc class MockAdObject: UIView {
    @objc var keywords: String?
    @objc var localExtras: [AnyHashable : Any]?
}

class MockEmptyPrebidMediationDelegate: PrebidMediationDelegate {
    func setUpAdObject(with values: [String : Any]) -> Bool { true }
    func cleanUpAdObject() {}
    func getAdView() -> UIView? { UIView(frame: .zero)}
}

/// A mediation delegate that cannot set up its ad object.
class MockRejectingMediationDelegate: PrebidMediationDelegate {
    // Retained here: `MediationBannerAdUnit` holds the ad view weakly
    private let adView = UIView(frame: .zero)

    func setUpAdObject(with values: [String : Any]) -> Bool { false }
    func cleanUpAdObject() {}
    func getAdView() -> UIView? { adView }
}

class MockMediationUtils: PrebidMediationDelegate {
    
    let adObject: MockAdObject
    
    public init(adObject: MockAdObject) {
        self.adObject = adObject
    }
    
    public func cleanUpAdObject() {
        guard let adExtras = adObject.localExtras,
              let adKeywords = adObject.keywords else {
                  return
              }
        
        let keywords = removeHBKeywordsFrom(adKeywords)
        adObject.keywords = keywords
        
        let HBKeys = [MockMediationAdUnitBidKey, MockMediationConfigIdKey, MockMediationAdNativeResponseKey, MockMediationTargetingInfoKey]
        let extras = adExtras.filter {
            guard let key = $0.key as? String else { return true }
            return !HBKeys.contains(key)
        }
        
        adObject.localExtras = extras
    }
    
    public func setUpAdObject(with values: [String: Any]) -> Bool {
    
        let extras = adObject.localExtras ?? [:]
        let adKeywords = adObject.keywords ?? ""
        
        //Pass our objects via the localExtra property
        adObject.localExtras = extras.merging(values, uniquingKeysWith: { $1})
        
        //Setup bid targeting keyword
        if let targetingInfo = values[MockMediationTargetingInfoKey] as? [String: String], targetingInfo.count > 0 {
            let bidKeywords = keywordsFrom(targetingInfo)
            let keywords = adKeywords.isEmpty ? bidKeywords : adKeywords + "," + bidKeywords
            adObject.keywords = keywords
        }
        
        return true
    }
    
    func getAdView() -> UIView? {
        return adObject
    }
    
    // MARK: - Private Methods
    private func keywordsFrom(_ targetingInfo: [String : String]) -> String {
        return targetingInfo
            .map { $0 + ":" + $1 }
            .joined(separator: keywordsSeparator)
    }
    
    private func removeHBKeywordsFrom(_ keywords: String) -> String  {
        return keywords
            .components(separatedBy: keywordsSeparator)
            .filter { !$0.hasPrefix(HBKeywordPrefix) }
            .joined(separator: keywordsSeparator)
    }
}

/// Records every call of a fetch completion.
final class FetchRecorder {
    let firstCall = XCTestExpectation(description: "first completion call")
    let completed: XCTestExpectation
    private(set) var results: [BidInfo] = []
    private let expectedCalls: Int

    init(expectedCalls: Int) {
        self.expectedCalls = expectedCalls
        completed = XCTestExpectation(description: "completion called \(expectedCalls) time(s)")
    }

    func record(_ bidInfo: BidInfo) {
        results.append(bidInfo)

        if results.count == 1 {
            firstCall.fulfill()
        }
        if results.count == expectedCalls {
            completed.fulfill()
        }
        if results.count > expectedCalls {
            XCTFail("Unexpected completion call with \(bidInfo.resultCode.name())")
        }
    }
}

/// A connection that answers `responses` at once, then holds the next request until the test
/// answers it with `respond(with:in:)`. Holding a request keeps its fetch in progress.
final class HeldRequest {
    private let sent = XCTestExpectation(description: "held bid request sent")
    private var hasWaitedForSend = false
    private(set) var connection: MockServerConnection!
    private var callback: PrebidServerResponseCallback?

    init(after responses: [PrebidServerResponse] = []) {
        var handlers: [MockServerConnection.PostHandler_NoContentType] = responses.map { response in
            { (url, data, timeout, callback) in callback(response) }
        }
        handlers.append { [weak self] (url, data, timeout, callback) in
            self?.callback = callback
            self?.sent.fulfill()
        }
        connection = MockServerConnection(onPost: handlers)
    }

    /// Waits until the held request has been sent. Can be called more than once.
    func waitUntilSent(in testCase: XCTestCase) {
        guard !hasWaitedForSend else {
            return
        }

        testCase.wait(for: [sent], timeout: 1)
        hasWaitedForSend = true
    }

    func respond(with response: PrebidServerResponse, in testCase: XCTestCase) {
        waitUntilSent(in: testCase)
        callback?(response)
    }
}
