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
@testable @_spi(PBMInternal) import PrebidMobile

// MARK: - Parity assertion

/// Verifies that an ObjC ORTB type and its Swift twin produce identical JSON output
/// for the same input. Used during Phase 1–3 of the ObjC → Swift migration to
/// confirm byte-for-byte JSON parity before deleting the ObjC source files.
///
/// Usage (per S1.x PR):
/// ```swift
/// assertORTBParity(
///     jsonString: Fixtures.ORTB.format,
///     objcType: PBMORTBFormat.self,
///     swiftType: PBMORTBFormatSwift.self
/// )
/// ```
func assertORTBParity<ObjCType: PBMORTBAbstract, SwiftType: PBMJsonCodable>(
    jsonString: String,
    objcType: ObjCType.Type,
    swiftType: SwiftType.Type,
    file: StaticString = #file,
    line: UInt = #line
) {
    do {
        let objcEncoded = try objcType.from(jsonString: jsonString).toJsonString()

        guard let swiftInstance = try SwiftType(jsonString: jsonString) else {
            XCTFail("\(SwiftType.self) init?(jsonString:) returned nil", file: file, line: line)
            return
        }
        let swiftEncoded = try swiftInstance.toJsonString()

        XCTAssertEqual(objcEncoded, swiftEncoded, file: file, line: line)
    } catch {
        XCTFail("assertORTBParity error: \(error)", file: file, line: line)
    }
}

// MARK: - Baseline fixtures

/// Canonical JSON fixtures for Phase 1 ORTB request-side types.
/// Each constant exercises every field of the type so that a missing or
/// mis-keyed property in the Swift twin is caught by the parity test.
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
        {"anid":"some-anid-value"}
        """

    static let impExtSkadn = """
        {"skadnetids":["net1","net2"],"sourceapp":"12345678",\
        "versions":["2.0","2.1","2.2"]}
        """

    static let deviceExtAtts = """
        {"atts":3,"ifv":"ifv-value"}
        """
}
