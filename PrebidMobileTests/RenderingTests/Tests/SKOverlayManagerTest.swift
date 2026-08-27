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
import StoreKit

@testable import PrebidMobile

@available(iOS 14.0, *)
class SKOverlayManagerTest: XCTestCase {

    private var manager: SKOverlayManager!

    override func setUp() {
        super.setUp()
        manager = SKOverlayManager(viewControllerForPresentation: UIViewController())
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testBuildConfig() throws {
        let config = try XCTUnwrap(manager.buildConfig(with: SKOverlayUtilities.skadn()))

        XCTAssertEqual(config.appIdentifier, SkadnUtilities.itunesitem)
        XCTAssertEqual(config.position, .bottom)
        XCTAssertTrue(config.userDismissible)
    }

    func testBuildConfig_honoursPositionAndDismissible() throws {
        let skadn = SKOverlayUtilities.skadn()
        skadn.skoverlay?.pos = 1
        skadn.skoverlay?.dismissible = 0

        let config = try XCTUnwrap(manager.buildConfig(with: skadn))

        XCTAssertEqual(config.position, .bottomRaised)
        XCTAssertFalse(config.userDismissible)
    }

    func testBuildConfig_withoutSkoverlay_isNil() {
        let skadn = SKOverlayUtilities.skadn()
        skadn.skoverlay = nil

        XCTAssertNil(manager.buildConfig(with: skadn))
    }

    func testBuildConfig_withoutItunesitem_isNil() {
        let skadn = SKOverlayUtilities.skadn()
        skadn.itunesitem = nil

        XCTAssertNil(manager.buildConfig(with: skadn))
    }

    // MARK: - `itunesitem` validation

    /// Bid servers are known to send `itunesitem` as a JSON number, which decodes to its digits.
    func testBuildConfig_isIndifferentToJsonValueType() throws {
        let fromString = ORTBBidExtSkadn(jsonDictionary: SKOverlayUtilities.skadnJson(useNumbers: false))
        let fromNumber = ORTBBidExtSkadn(jsonDictionary: SKOverlayUtilities.skadnJson(useNumbers: true))

        let stringConfig = try XCTUnwrap(manager.buildConfig(with: fromString))
        let numberConfig = try XCTUnwrap(manager.buildConfig(with: fromNumber))

        XCTAssertEqual(stringConfig.appIdentifier, SkadnUtilities.itunesitem)
        XCTAssertEqual(numberConfig.appIdentifier, stringConfig.appIdentifier)
    }
}

class SKOverlayUtilities {

    static func skadn() -> ORTBBidExtSkadn {
        let skadn = ORTBBidExtSkadn()
        skadn.version = "2.2"
        skadn.network = SkadnUtilities.network
        skadn.itunesitem = SkadnUtilities.itunesitem
        skadn.sourceapp = SkadnUtilities.sourceapp
        skadn.skoverlay = skoverlay()
        return skadn
    }

    static func skoverlay() -> ORTBBidExtSkadnSKOverlay {
        let skoverlay = ORTBBidExtSkadnSKOverlay()
        skoverlay.delay = 0
        skoverlay.endcarddelay = 0
        skoverlay.dismissible = 1
        skoverlay.pos = 0
        return skoverlay
    }

    static func skadnJson(useNumbers: Bool) -> [String : Any] {
        [
            "version": "2.2",
            "network": SkadnUtilities.network,
            "itunesitem": useNumbers ? Int(SkadnUtilities.itunesitem)! : SkadnUtilities.itunesitem,
            "sourceapp": useNumbers ? Int(SkadnUtilities.sourceapp)! : SkadnUtilities.sourceapp,
            "skoverlay": [
                "delay": 0,
                "endcarddelay": 0,
                "dismissible": 1,
                "pos": 0,
            ],
        ]
    }
}
