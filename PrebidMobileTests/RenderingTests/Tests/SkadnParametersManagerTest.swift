//
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


import XCTest
import StoreKit

class SkadnParametersManagerTest: XCTestCase {
    
    @available(iOS 14.5, *)
    func testGetSkadnImpression() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        let nonceForFidelity0 = skadn.fidelities!.filter({ $0.fidelity == 0 }).first!.nonce!
        let actual = SkadnParametersManager.getSkadnImpression(for: skadn)!
        let expected = SkadnUtilities.createSkadImpression(with: nonceForFidelity0)
        PBMAssertEq(type: NSNumber.self, actual: actual.sourceAppStoreItemIdentifier, expected: expected.sourceAppStoreItemIdentifier)
        PBMAssertEq(type: NSNumber.self, actual: actual.advertisedAppStoreItemIdentifier, expected: expected.advertisedAppStoreItemIdentifier)
        PBMAssertEq(type: String.self, actual: actual.adNetworkIdentifier, expected: expected.adNetworkIdentifier)
        PBMAssertEq(type: NSNumber.self, actual: actual.adCampaignIdentifier, expected: expected.adCampaignIdentifier)
        PBMAssertEq(type: String.self, actual: actual.adImpressionIdentifier, expected: expected.adImpressionIdentifier)
        PBMAssertEq(type: NSNumber.self, actual: actual.timestamp, expected: expected.timestamp)
        PBMAssertEq(type: String.self, actual: actual.signature, expected: expected.signature)
    }
    
    @available(iOS 14.0, *)
    func testGetProductParameters() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        let actual = SkadnParametersManager.getSkadnProductParameters(for: skadn)!
        let expected: [String: Any] = SkadnUtilities.createSkadnProductParameters(from: skadn)
        PBMAssertEq(type: Int.self, actual: actual[SKStoreProductParameterITunesItemIdentifier]!, expected: expected[SKStoreProductParameterITunesItemIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkIdentifier]!)
        PBMAssertEq(type: Int.self, actual: actual[SKStoreProductParameterAdNetworkCampaignIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkCampaignIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkVersion]!, expected: expected[SKStoreProductParameterAdNetworkVersion]!)
        PBMAssertEq(type: Int.self, actual: actual[SKStoreProductParameterAdNetworkTimestamp]!, expected: expected[SKStoreProductParameterAdNetworkTimestamp]!)
        PBMAssertEq(type: UUID.self, actual: actual[SKStoreProductParameterAdNetworkNonce]!, expected: expected[SKStoreProductParameterAdNetworkNonce]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkAttributionSignature]!, expected: expected[SKStoreProductParameterAdNetworkAttributionSignature]!)
    }
    
    @available(iOS 16.1, *)
    func testGetSkadnImpression_version_4_0() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities_version_4_0()
        let nonceForFidelity0 = skadn.fidelities!.filter({ $0.fidelity == 0 }).first!.nonce!
        let actual = SkadnParametersManager.getSkadnImpression(for: skadn)!
        let expected = SkadnUtilities.createSkadImpression_version_4_0(with: nonceForFidelity0)
        PBMAssertEq(type: NSNumber.self, actual: actual.sourceAppStoreItemIdentifier, expected: expected.sourceAppStoreItemIdentifier)
        PBMAssertEq(type: NSNumber.self, actual: actual.advertisedAppStoreItemIdentifier, expected: expected.advertisedAppStoreItemIdentifier)
        PBMAssertEq(type: String.self, actual: actual.adNetworkIdentifier, expected: expected.adNetworkIdentifier)
        PBMAssertEq(type: NSNumber.self, actual: actual.sourceIdentifier, expected: expected.sourceIdentifier)
        PBMAssertEq(type: String.self, actual: actual.adImpressionIdentifier, expected: expected.adImpressionIdentifier)
        PBMAssertEq(type: NSNumber.self, actual: actual.timestamp, expected: expected.timestamp)
        PBMAssertEq(type: String.self, actual: actual.signature, expected: expected.signature)
    }
    
    @available(iOS 16.1, *)
    func testGetProductParameters_version_4_0() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities_version_4_0()
        let actual = SkadnParametersManager.getSkadnProductParameters(for: skadn)!
        let expected: [String: Any] = SkadnUtilities.createSkadnProductParameters_version_4_0(from: skadn)
        PBMAssertEq(type: Int.self, actual: actual[SKStoreProductParameterITunesItemIdentifier]!, expected: expected[SKStoreProductParameterITunesItemIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkIdentifier]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkSourceIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkSourceIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkVersion]!, expected: expected[SKStoreProductParameterAdNetworkVersion]!)
        PBMAssertEq(type: Int.self, actual: actual[SKStoreProductParameterAdNetworkTimestamp]!, expected: expected[SKStoreProductParameterAdNetworkTimestamp]!)
        PBMAssertEq(type: UUID.self, actual: actual[SKStoreProductParameterAdNetworkNonce]!, expected: expected[SKStoreProductParameterAdNetworkNonce]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkAttributionSignature]!, expected: expected[SKStoreProductParameterAdNetworkAttributionSignature]!)
    }
}

class SkadnUtilities {
    class func createSkadnExtWithFidelities() -> PBMORTBBidExtSkadn {
        let skadn = PBMORTBBidExtSkadn()
        
        skadn.version = "2.2"
        skadn.network = "cDkw7geQsH.skadnetwork"
        skadn.campaign = 45
        skadn.itunesitem = 123456789
        skadn.sourceapp = 880047117
        let fidelity0 = PBMORTBSkadnFidelity()
        fidelity0.fidelity = 0
        fidelity0.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        fidelity0.nonce = UUID()
        fidelity0.timestamp = 1594406342
        let fidelity1 = PBMORTBSkadnFidelity()
        fidelity1.fidelity = 1
        fidelity1.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        fidelity1.nonce = UUID()
        fidelity1.timestamp = 1594406341
        
        skadn.fidelities = [fidelity0, fidelity1]
        return skadn
    }
    
    class func createSkadnExtWithFidelities_version_4_0() -> PBMORTBBidExtSkadn {
        let skadn = PBMORTBBidExtSkadn()
        
        skadn.version = "4.0"
        skadn.network = "cDkw7geQsH.skadnetwork"
        skadn.sourceidentifier = "1234"
        skadn.itunesitem = 123456789
        skadn.sourceapp = 880047117
        
        let fidelity0 = PBMORTBSkadnFidelity()
        fidelity0.fidelity = 0
        fidelity0.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        fidelity0.nonce = UUID()
        fidelity0.timestamp = 1594406342
        let fidelity1 = PBMORTBSkadnFidelity()
        fidelity1.fidelity = 1
        fidelity1.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        fidelity1.nonce = UUID()
        fidelity1.timestamp = 1594406341
        
        skadn.fidelities = [fidelity0, fidelity1]
        return skadn
    }
    
    @available(iOS 14.0, *)
    class func createSkadnProductParameters(from skadn: PBMORTBBidExtSkadn) -> [String: Any] {
        let fidelity1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!
        return [
            SKStoreProductParameterITunesItemIdentifier : skadn.itunesitem!,
            SKStoreProductParameterAdNetworkIdentifier : skadn.network!,
            SKStoreProductParameterAdNetworkCampaignIdentifier : skadn.campaign!,
            SKStoreProductParameterAdNetworkVersion : skadn.version!,
            SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : skadn.sourceapp!,
            SKStoreProductParameterAdNetworkTimestamp : fidelity1.timestamp!,
            SKStoreProductParameterAdNetworkNonce : fidelity1.nonce!,
            SKStoreProductParameterAdNetworkAttributionSignature : fidelity1.signature!
        ]
        
    }
    
    @available(iOS 16.1, *)
    class func createSkadnProductParameters_version_4_0(from skadn: PBMORTBBidExtSkadn) -> [String: Any] {
        let fidelity1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!
        return [
            SKStoreProductParameterITunesItemIdentifier : skadn.itunesitem!,
            SKStoreProductParameterAdNetworkIdentifier : skadn.network!,
            SKStoreProductParameterAdNetworkSourceIdentifier : NSNumber(integerLiteral: Int(skadn.sourceidentifier!)!),
            SKStoreProductParameterAdNetworkVersion : skadn.version!,
            SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : skadn.sourceapp!,
            SKStoreProductParameterAdNetworkTimestamp : fidelity1.timestamp!,
            SKStoreProductParameterAdNetworkNonce : fidelity1.nonce!,
            SKStoreProductParameterAdNetworkAttributionSignature : fidelity1.signature!
        ]
        
    }
    
    @available(iOS 14.5, *)
    class func createSkadImpression(with nonce: UUID) -> SKAdImpression {
        let imp = SKAdImpression()
        imp.sourceAppStoreItemIdentifier = 880047117
        imp.advertisedAppStoreItemIdentifier = 123456789
        imp.adNetworkIdentifier = "cDkw7geQsH.skadnetwork"
        imp.adCampaignIdentifier = 45
        imp.adImpressionIdentifier = nonce.uuidString
        imp.timestamp = 1594406342
        imp.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        return imp
    }
    
    @available(iOS 16.1, *)
    class func createSkadImpression_version_4_0(with nonce: UUID) -> SKAdImpression {
        let imp = SKAdImpression()
        imp.sourceAppStoreItemIdentifier = 880047117
        imp.advertisedAppStoreItemIdentifier = 123456789
        imp.adNetworkIdentifier = "cDkw7geQsH.skadnetwork"
        imp.sourceIdentifier = 1234
        imp.adImpressionIdentifier = nonce.uuidString
        imp.timestamp = 1594406342
        imp.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        return imp
    }
}
