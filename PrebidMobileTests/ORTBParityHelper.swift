// Copyright 2018-2025 Prebid.org, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
@_spi(PBMInternal) @testable import PrebidMobile

// MARK: - Parity assertion

/// Asserts that decode → encode is **idempotent** for a Swift ORTB type: encoding the
/// decoded fixture and then decoding/re-encoding that output yields the same JSON.
///
/// Scope and limits — read before relying on this:
/// - This is a Swift-internal self-consistency check. It does **not** compare against the
///   ObjC original, and it does **not** assert the output matches the input fixture.
/// - With a fully-populated fixture it cannot detect the class of bug where an *absent*
///   JSON key resurrects a class default on encode (playbook Gap S2.5-C), because the
///   default is stable across both round trips. Use `assertORTBNoResurrectedDefaults`
///   with a partial fixture for that.
///
/// Usage:
/// ```swift
/// assertORTBParity(jsonString: ORTBFixtures.format, swiftType: ORTBFormat.self)
/// ```
func assertORTBParity<T: PBMJsonCodable>(
    jsonString: String,
    swiftType: T.Type,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        guard let instance = try T(jsonString: jsonString) else {
            XCTFail("\(T.self) init?(jsonString:) returned nil", file: file, line: line)
            return
        }
        let encoded = try instance.toJsonString()
        let decoded = try T(jsonString: encoded)
        let reEncoded = try decoded?.toJsonString()
        XCTAssertEqual(encoded, reEncoded, file: file, line: line)
    } catch {
        XCTFail("assertORTBParity error: \(error)", file: file, line: line)
    }
}

/// Decodes `jsonString` and asserts the re-encoded dictionary contains exactly `expectedKeys`.
///
/// Guards playbook Gap S2.5-C: the ObjC `initWithJsonDictionary:` assigned ivars directly and
/// unconditionally, so an absent key cleared the default seeded by `init` and the key was then
/// omitted on re-encode. A Swift port that falls back to the default (`json[.k] ?? default`)
/// silently adds keys the ObjC SDK never sent.
func assertORTBNoResurrectedDefaults<T: PBMJsonCodable>(
    jsonString: String,
    swiftType: T.Type,
    expectedKeys: Set<String>,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        guard let instance = try T(jsonString: jsonString) else {
            XCTFail("\(T.self) init?(jsonString:) returned nil", file: file, line: line)
            return
        }
        let keys = Set(instance.jsonDictionary.keys)
        XCTAssertEqual(keys, expectedKeys,
                       "\(T.self) re-encoded unexpected keys: \(keys.symmetricDifference(expectedKeys).sorted())",
                       file: file, line: line)
    } catch {
        XCTFail("assertORTBNoResurrectedDefaults error: \(error)", file: file, line: line)
    }
}

// MARK: - from(jsonString:) shim

/// Provides a throwing non-optional `from(jsonString:)` class method that mirrors the
/// former `PBMORTBAbstract.fromJsonString:error:` ObjC API. Required by test files that
/// call `try ORTBFoo.from(jsonString: ...)` after the ObjC abstract base was deleted.
extension PBMJsonDecodable {
    static func from(jsonString: String) throws -> Self {
        guard let instance = try Self(jsonString: jsonString) else {
            throw NSError(domain: "ORTBParity", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "\(Self.self).init?(jsonString:) returned nil"])
        }
        return instance
    }
}

// MARK: - Baseline fixtures

/// Canonical JSON fixtures for Phase 1 ORTB request-side types.
enum ORTBFixtures {

    // MARK: Leaf types (S1.1)

    static let format = """
        {"h":480,"hratio":3,"w":640,"wmin":160,"wratio":4}
        """

    static let publisher = """
        {"domain":"publisher.com","id":"pub-123","name":"Example Publisher"}
        """

    static let geo = """
        {"accuracy":50,"city":"Los Angeles","country":"USA","lat":34.052235,\
        "lon":-118.243683,"metro":"803","region":"CA","regionfips104":"US06",\
        "type":1,"utcoffset":-480,"zip":"90012"}
        """

    static let deal = """
        {"at":1,"bidfloor":2.5,"bidfloorcur":"USD","id":"deal-abc",\
        "wadomain":["advertiser.com"],"wseat":["seat1"]}
        """

    static let sourceExtOMID = """
        {"omidpn":"prebid.org","omidpv":"1.0.0"}
        """

    static let impExtSkadn = """
        {"skadnetids":["net1","net2"],"sourceapp":"12345678",\
        "versions":["2.0","2.1","2.2"]}
        """

    static let deviceExtAtts = """
        {"atts":3,"ifv":"ifv-value"}
        """

    // MARK: Partial payloads (Gap S2.5-C regression coverage)

    /// Only `id` present — every other `ORTBDeal` field must stay absent on re-encode even
    /// though `init` seeds `bidfloor`, `bidfloorcur`, `wseat` and `wadomain`.
    static let partialDeal = """
        {"id":"deal-abc"}
        """

    /// Only `id` present — `instl`, `clickbrowser` and `secure` must stay absent even though
    /// `init` seeds them. `ext` is still emitted: `ORTBImp` unconditionally writes `dlp`.
    static let partialImp = """
        {"id":"imp-1"}
        """

    /// No `imp` key — must not resurrect the one-element default impression.
    static let partialBidRequest = """
        {"id":"req-1"}
        """

    /// Explicitly empty `imp` — must stay empty rather than falling back to the default.
    static let emptyImpBidRequest = """
        {"id":"req-1","imp":[]}
        """
}
