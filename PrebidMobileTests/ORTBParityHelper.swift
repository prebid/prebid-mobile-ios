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

/// Verifies that a Swift ORTB type produces expected JSON output for a given fixture.
/// Used during Phase 1–3 of the ObjC → Swift migration to confirm JSON parity.
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
}
