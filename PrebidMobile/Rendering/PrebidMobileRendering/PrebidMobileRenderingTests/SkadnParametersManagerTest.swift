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
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkNonce]!, expected: expected[SKStoreProductParameterAdNetworkNonce]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkAttributionSignature]!, expected: expected[SKStoreProductParameterAdNetworkAttributionSignature]!)
    }
}
