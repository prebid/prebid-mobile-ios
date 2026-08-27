//
/*   Copyright 2018-2021 Prebid.org, Inc.

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

@testable import PrebidMobile

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
        PBMAssertEq(type: String.self, actual: actual.version, expected: expected.version)
    }

    @available(iOS 14.5, *)
    func testGetProductParameters() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        let actual = SkadnParametersManager.getSkadnProductParameters(for: skadn)!
        let expected: [String: Any] = SkadnUtilities.createSkadnProductParameters(from: skadn)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterITunesItemIdentifier]!, expected: expected[SKStoreProductParameterITunesItemIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkIdentifier]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkCampaignIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkCampaignIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkVersion]!, expected: expected[SKStoreProductParameterAdNetworkVersion]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkTimestamp]!, expected: expected[SKStoreProductParameterAdNetworkTimestamp]!)
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
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterITunesItemIdentifier]!, expected: expected[SKStoreProductParameterITunesItemIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkIdentifier]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkSourceIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkSourceIdentifier]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkVersion]!, expected: expected[SKStoreProductParameterAdNetworkVersion]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier]!, expected: expected[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier]!)
        PBMAssertEq(type: NSNumber.self, actual: actual[SKStoreProductParameterAdNetworkTimestamp]!, expected: expected[SKStoreProductParameterAdNetworkTimestamp]!)
        PBMAssertEq(type: UUID.self, actual: actual[SKStoreProductParameterAdNetworkNonce]!, expected: expected[SKStoreProductParameterAdNetworkNonce]!)
        PBMAssertEq(type: String.self, actual: actual[SKStoreProductParameterAdNetworkAttributionSignature]!, expected: expected[SKStoreProductParameterAdNetworkAttributionSignature]!)

        // `campaign` is replaced by `sourceidentifier` in 4.0
        XCTAssertNil(actual[SKStoreProductParameterAdNetworkCampaignIdentifier])
    }

    // MARK: - StoreKit value type
    /// StoreKit documents a value type per `SKStoreProductParameter*` key: the identifiers and the
    /// timestamp are `NSNumber`, and the nonce is `NSUUID`.
    @available(iOS 16.1, *)
    func testGetProductParameters_valueTypes() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities_version_4_0()
        skadn.campaign = SkadnUtilities.campaign

        let params = SkadnParametersManager.getSkadnProductParameters(for: skadn)!

        XCTAssertTrue(params[SKStoreProductParameterITunesItemIdentifier] is NSNumber)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] is NSNumber)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkCampaignIdentifier] is NSNumber)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkTimestamp] is NSNumber)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkNonce] is UUID)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkIdentifier] is String)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkVersion] is String)
        XCTAssertTrue(params[SKStoreProductParameterAdNetworkAttributionSignature] is String)

        XCTAssertTrue(params[SKStoreProductParameterAdNetworkSourceIdentifier] is NSNumber)
    }

    @available(iOS 16.1, *)
    func testGetSkadnImpression_valueTypes() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities_version_4_0()
        skadn.campaign = SkadnUtilities.campaign

        let imp = SkadnParametersManager.getSkadnImpression(for: skadn)!

        XCTAssertEqual(imp.advertisedAppStoreItemIdentifier, NSNumber(value: 123456789))
        XCTAssertEqual(imp.sourceAppStoreItemIdentifier, NSNumber(value: 880047117))
        XCTAssertEqual(imp.adCampaignIdentifier, NSNumber(value: 45))
        XCTAssertEqual(imp.sourceIdentifier, NSNumber(value: 1234))
        XCTAssertEqual(imp.timestamp, NSNumber(value: 1594406342))

        XCTAssertEqual(imp.adImpressionIdentifier, SkadnUtilities.nonce0)
    }

    // MARK: - Response decoding


    @available(iOS 16.1, *)
    func testGetSkadnImpression_isIndifferentToJsonValueType() {
        let fromStrings = ORTBBidExtSkadn(jsonDictionary: SkadnUtilities.skadnJson(useNumbers: false))
        let fromNumbers = ORTBBidExtSkadn(jsonDictionary: SkadnUtilities.skadnJson(useNumbers: true))

        let stringsImp = SkadnParametersManager.getSkadnImpression(for: fromStrings)!
        let numbersImp = SkadnParametersManager.getSkadnImpression(for: fromNumbers)!

        PBMAssertEq(numbersImp.sourceAppStoreItemIdentifier, stringsImp.sourceAppStoreItemIdentifier)
        PBMAssertEq(numbersImp.advertisedAppStoreItemIdentifier, stringsImp.advertisedAppStoreItemIdentifier)
        PBMAssertEq(numbersImp.adNetworkIdentifier, stringsImp.adNetworkIdentifier)
        PBMAssertEq(numbersImp.adCampaignIdentifier, stringsImp.adCampaignIdentifier)
        PBMAssertEq(numbersImp.sourceIdentifier, stringsImp.sourceIdentifier)
        PBMAssertEq(numbersImp.adImpressionIdentifier, stringsImp.adImpressionIdentifier)
        PBMAssertEq(numbersImp.timestamp, stringsImp.timestamp)
        PBMAssertEq(numbersImp.signature, stringsImp.signature)
        PBMAssertEq(numbersImp.version, stringsImp.version)
    }

    @available(iOS 14.5, *)
    func testGetProductParameters_isIndifferentToJsonValueType() {
        let fromStrings = ORTBBidExtSkadn(jsonDictionary: SkadnUtilities.skadnJson(useNumbers: false))
        let fromNumbers = ORTBBidExtSkadn(jsonDictionary: SkadnUtilities.skadnJson(useNumbers: true))

        let stringsParams = SkadnParametersManager.getSkadnProductParameters(for: fromStrings)!
        let numbersParams = SkadnParametersManager.getSkadnProductParameters(for: fromNumbers)!

        XCTAssertEqual(numbersParams as NSDictionary, stringsParams as NSDictionary)
    }


    @available(iOS 16.1, *)
    func testStoreKitValuesDecodedFromRawJSON() throws {
        let raw = """
        {
            "version": "4.0",
            "network": "\(SkadnUtilities.network)",
            "sourceidentifier": "\(SkadnUtilities.sourceidentifier)",
            "itunesitem": "\(SkadnUtilities.itunesitem)",
            "sourceapp": "\(SkadnUtilities.sourceapp)",
            "fidelities": [
                {
                    "fidelity": 0,
                    "nonce": "\(SkadnUtilities.nonce0)",
                    "timestamp": "\(SkadnUtilities.timestamp0)",
                    "signature": "\(SkadnUtilities.signature)"
                },
                {
                    "fidelity": 1,
                    "nonce": "\(SkadnUtilities.nonce1)",
                    "timestamp": "\(SkadnUtilities.timestamp1)",
                    "signature": "\(SkadnUtilities.signature)"
                }
            ]
        }
        """

        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: Data(raw.utf8)) as? [String : Any])
        let skadn = ORTBBidExtSkadn(jsonDictionary: json)

        let imp = try XCTUnwrap(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertEqual(imp.version, "4.0")
        XCTAssertEqual(imp.adNetworkIdentifier, SkadnUtilities.network)
        XCTAssertEqual(imp.sourceIdentifier, NSNumber(value: 1234))
        XCTAssertEqual(imp.advertisedAppStoreItemIdentifier, NSNumber(value: 123456789))
        XCTAssertEqual(imp.sourceAppStoreItemIdentifier, NSNumber(value: 880047117))
        XCTAssertEqual(imp.signature, SkadnUtilities.signature)

        let params = try XCTUnwrap(SkadnParametersManager.getSkadnProductParameters(for: skadn))
        XCTAssertEqual(
            params as NSDictionary,
            SkadnUtilities.createSkadnProductParameters_version_4_0(from: skadn) as NSDictionary
        )
    }

    // MARK: - Fidelity selection

    @available(iOS 14.5, *)
    func testFidelityTypeSelection() throws {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()

        let imp = try XCTUnwrap(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertEqual(imp.adImpressionIdentifier, SkadnUtilities.nonce0)
        XCTAssertEqual(imp.timestamp, NSNumber(value: Int64(SkadnUtilities.timestamp0)!))

        let params = try XCTUnwrap(SkadnParametersManager.getSkadnProductParameters(for: skadn))
        XCTAssertEqual(params[SKStoreProductParameterAdNetworkNonce] as? UUID, UUID(uuidString: SkadnUtilities.nonce1))
        XCTAssertEqual(params[SKStoreProductParameterAdNetworkTimestamp] as? NSNumber, NSNumber(value: Int64(SkadnUtilities.timestamp1)!))
    }

    // MARK: - Malformed responses

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withoutFidelity0_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.fidelities = skadn.fidelities?.filter { $0.fidelity != 0 }

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetProductParameters_withoutFidelity1_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.fidelities = skadn.fidelities?.filter { $0.fidelity != 1 }

        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withoutFidelities_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.fidelities = nil

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    /// Neither surface can represent a non-numeric identifier, so both are dropped.
    @available(iOS 14.5, *)
    func testGetSkadnImpression_withNonNumericIdentifiers_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.itunesitem = "not-a-number"

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withNonNumericTimestamp_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.fidelities?.forEach { $0.timestamp = "1,594,406,342" }

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    /// A non-numeric `campaign` must not drop the whole impression - it is optional in 4.0+.
    @available(iOS 14.5, *)
    func testGetSkadnImpression_withNonNumericCampaign_skipsCampaign() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.campaign = "not-a-number"

        XCTAssertNotNil(SkadnParametersManager.getSkadnImpression(for: skadn))

        let params = SkadnParametersManager.getSkadnProductParameters(for: skadn)
        XCTAssertNotNil(params)
        XCTAssertNil(params?[SKStoreProductParameterAdNetworkCampaignIdentifier])
    }

    /// StoreKit types the nonce as `NSUUID`, so a nonce that does not parse drops the parameters.
    @available(iOS 14.5, *)
    func testGetProductParameters_withMalformedNonce_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.fidelities?.forEach { $0.nonce = "not-a-uuid" }

        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withoutVersion_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.version = nil

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    /// `version` and `network` are the only fields the spec marks as required.
    @available(iOS 14.5, *)
    func testGetSkadnImpression_withoutNetwork_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.network = nil

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withoutSignature_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.fidelities?.forEach { $0.signature = nil }

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withOverflowingIdentifier_isNil() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.itunesitem = "99999999999999999999"

        XCTAssertNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(SkadnParametersManager.getSkadnProductParameters(for: skadn))
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withLocaleFormattedIdentifiers_isNil() {
        for malformed in ["1,234", "1.234", "1 234", "1\u{00a0}234"] {
            let skadn = SkadnUtilities.createSkadnExtWithFidelities()
            skadn.itunesitem = malformed

            XCTAssertNil(
                SkadnParametersManager.getSkadnImpression(for: skadn),
                "expected \(malformed) to be rejected as an itunesitem"
            )

            let bySourceapp = SkadnUtilities.createSkadnExtWithFidelities()
            bySourceapp.sourceapp = malformed

            XCTAssertNil(
                SkadnParametersManager.getSkadnImpression(for: bySourceapp),
                "expected \(malformed) to be rejected as a sourceapp"
            )
        }
    }

    @available(iOS 14.5, *)
    func testGetSkadnImpression_withLocaleFormattedCampaign_skipsCampaign() throws {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()
        skadn.campaign = "1,234"

        let imp = try XCTUnwrap(SkadnParametersManager.getSkadnImpression(for: skadn))

        XCTAssertNil(imp.value(forKey: "adCampaignIdentifier"))

        let params = SkadnParametersManager.getSkadnProductParameters(for: skadn)
        XCTAssertNotNil(params)
        XCTAssertNil(params?[SKStoreProductParameterAdNetworkCampaignIdentifier])
    }

    /// `sourceidentifier` is absent below SKAdNetwork 4.0 - it must not be defaulted.
    @available(iOS 16.1, *)
    func testGetProductParameters_withoutSourceIdentifier_omitsIt() {
        let skadn = SkadnUtilities.createSkadnExtWithFidelities()

        XCTAssertNotNil(SkadnParametersManager.getSkadnImpression(for: skadn))
        XCTAssertNil(
            SkadnParametersManager.getSkadnProductParameters(for: skadn)?[SKStoreProductParameterAdNetworkSourceIdentifier]
        )
    }
}

class SkadnUtilities {

    // Values are strings, as typed by the ORTB SKAdNetwork extension:
    // https://github.com/InteractiveAdvertisingBureau/openrtb/blob/main/extensions/community_extensions/skadnetwork.md
    static let network = "cDkw7geQsH.skadnetwork"
    static let campaign = "45"
    static let sourceidentifier = "1234"
    static let itunesitem = "123456789"
    static let sourceapp = "880047117"
    static let signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
    static let nonce0 = "473b1a16-b4ef-43ad-9591-fcf3aefa82a7"
    static let nonce1 = "6b4bc07e-42a1-4b2f-b6cd-b0c0f9f0d5f4"
    static let timestamp0 = "1594406342"
    static let timestamp1 = "1594406341"

    class func createFidelities() -> [ORTBSkadnFidelity] {
        let fidelity0 = ORTBSkadnFidelity()
        fidelity0.fidelity = 0
        fidelity0.signature = signature
        fidelity0.nonce = nonce0
        fidelity0.timestamp = timestamp0

        let fidelity1 = ORTBSkadnFidelity()
        fidelity1.fidelity = 1
        fidelity1.signature = signature
        fidelity1.nonce = nonce1
        fidelity1.timestamp = timestamp1

        return [fidelity0, fidelity1]
    }

    class func createSkadnExtWithFidelities() -> ORTBBidExtSkadn {
        let skadn = ORTBBidExtSkadn()

        skadn.version = "2.2"
        skadn.network = network
        skadn.campaign = campaign
        skadn.itunesitem = itunesitem
        skadn.sourceapp = sourceapp
        skadn.fidelities = createFidelities()

        return skadn
    }

    class func createSkadnExtWithFidelities_version_4_0() -> ORTBBidExtSkadn {
        let skadn = ORTBBidExtSkadn()

        skadn.version = "4.0"
        skadn.network = network
        skadn.sourceidentifier = sourceidentifier
        skadn.itunesitem = itunesitem
        skadn.sourceapp = sourceapp
        skadn.fidelities = createFidelities()

        return skadn
    }

    class func createSkadnExtWithFidelities_version_4_0_SKOverlay() -> ORTBBidExtSkadn {
        let skadn = createSkadnExtWithFidelities_version_4_0()

        skadn.skoverlay = ORTBBidExtSkadnSKOverlay()
        skadn.skoverlay?.delay = 10
        skadn.skoverlay?.endcarddelay = 20
        skadn.skoverlay?.dismissible = 1
        skadn.skoverlay?.pos = 1

        return skadn
    }

    /// A `bid.ext.skadn` payload as it arrives from the bid server. When `useNumbers` is `true` the
    /// numeric identifiers are sent as JSON numbers instead of the spec-mandated strings.
    class func skadnJson(useNumbers: Bool) -> [String: Any] {
        func value(_ string: String) -> Any {
            useNumbers ? NSNumber(value: Int64(string)!) : string
        }

        return [
            "version": "4.0",
            "network": network,
            "campaign": value(campaign),
            "sourceidentifier": value(sourceidentifier),
            "itunesitem": value(itunesitem),
            "sourceapp": value(sourceapp),
            "fidelities": [
                [
                    "fidelity": 0,
                    "nonce": nonce0,
                    "timestamp": value(timestamp0),
                    "signature": signature,
                ],
                [
                    "fidelity": 1,
                    "nonce": nonce1,
                    "timestamp": value(timestamp1),
                    "signature": signature,
                ],
            ],
        ]
    }

    @available(iOS 14.5, *)
    class func createSkadnProductParameters(from skadn: ORTBBidExtSkadn) -> [String: Any] {
        let fidelity1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!
        return [
            SKStoreProductParameterITunesItemIdentifier : NSNumber(value: Int64(skadn.itunesitem!)!),
            SKStoreProductParameterAdNetworkIdentifier : skadn.network!,
            SKStoreProductParameterAdNetworkCampaignIdentifier : NSNumber(value: Int64(skadn.campaign!)!),
            SKStoreProductParameterAdNetworkVersion : skadn.version!,
            SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : NSNumber(value: Int64(skadn.sourceapp!)!),
            SKStoreProductParameterAdNetworkTimestamp : NSNumber(value: Int64(fidelity1.timestamp!)!),
            SKStoreProductParameterAdNetworkNonce : UUID(uuidString: fidelity1.nonce!)!,
            SKStoreProductParameterAdNetworkAttributionSignature : fidelity1.signature!
        ]

    }

    @available(iOS 16.1, *)
    class func createSkadnProductParameters_version_4_0(from skadn: ORTBBidExtSkadn) -> [String: Any] {
        let fidelity1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!
        return [
            SKStoreProductParameterITunesItemIdentifier : NSNumber(value: Int64(skadn.itunesitem!)!),
            SKStoreProductParameterAdNetworkIdentifier : skadn.network!,
            SKStoreProductParameterAdNetworkSourceIdentifier : NSNumber(value: Int64(skadn.sourceidentifier!)!),
            SKStoreProductParameterAdNetworkVersion : skadn.version!,
            SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : NSNumber(value: Int64(skadn.sourceapp!)!),
            SKStoreProductParameterAdNetworkTimestamp : NSNumber(value: Int64(fidelity1.timestamp!)!),
            SKStoreProductParameterAdNetworkNonce : UUID(uuidString: fidelity1.nonce!)!,
            SKStoreProductParameterAdNetworkAttributionSignature : fidelity1.signature!
        ]

    }

    @available(iOS 14.5, *)
    class func createSkadImpression(with nonce: String) -> SKAdImpression {
        let imp = SKAdImpression()
        imp.sourceAppStoreItemIdentifier = NSNumber(value: Int64(sourceapp)!)
        imp.advertisedAppStoreItemIdentifier = NSNumber(value: Int64(itunesitem)!)
        imp.adNetworkIdentifier = network
        imp.adCampaignIdentifier = NSNumber(value: Int64(campaign)!)
        imp.adImpressionIdentifier = nonce
        imp.timestamp = NSNumber(value: Int64(timestamp0)!)
        imp.signature = signature
        imp.version = "2.2"
        return imp
    }

    @available(iOS 16.1, *)
    class func createSkadImpression_version_4_0(with nonce: String) -> SKAdImpression {
        let imp = SKAdImpression()
        imp.sourceAppStoreItemIdentifier = NSNumber(value: Int64(sourceapp)!)
        imp.advertisedAppStoreItemIdentifier = NSNumber(value: Int64(itunesitem)!)
        imp.adNetworkIdentifier = network
        imp.sourceIdentifier = NSNumber(value: Int64(sourceidentifier)!)
        imp.adImpressionIdentifier = nonce
        imp.timestamp = NSNumber(value: Int64(timestamp0)!)
        imp.signature = signature
        imp.version = "4.0"
        return imp
    }
}
