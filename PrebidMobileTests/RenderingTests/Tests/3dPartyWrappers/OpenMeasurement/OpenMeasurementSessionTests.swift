/*   Copyright 2018-2025 Prebid.org, Inc.

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

@testable import PrebidMobile

class OpenMeasurementSessionTests: XCTestCase {

    /// Replaces the ObjC `testInitiWithInvalidParams`, which passed `nil` for both arguments. The Swift initializer
    /// takes non-optional OMID types, so the ObjC-facing seam is what receives invalid input.
    func testInitWithInvalidParams() {
        XCTAssertNil(OpenMeasurementSession(omidContext: NSObject(), omidConfiguration: NSObject()))
    }
}
