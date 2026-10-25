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

import UIKit
import XCTest
@testable import InternalTestApp

final class DevelopmentFormsTests: XCTestCase {
    func testBannerEditsPropagateToController() {
        let owner = ConfigurableBanner()
        let controller = PrebidBannerConfigurationController(controller: owner)
        controller.loadViewIfNeeded()
        let config = controller.sections[0].rows[0]
        let interval = controller.sections[0].rows[1]
        let cell = controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let field = cell.contentView.subviews.compactMap { $0 as? UITextField }.first!
        XCTAssertEqual(field.accessibilityIdentifier, "configId_field")
        field.text = "new-config"
        field.sendActions(for: .editingChanged)
        interval.onTextChange?("12.5")
        controller.onConfigurationFinished()
        XCTAssertEqual(config.value, "new-config")
        XCTAssertEqual(owner.prebidConfigId, "new-config")
        XCTAssertEqual(owner.refreshInterval, 12.5)
        interval.onTextChange?("")
        controller.onConfigurationFinished()
        XCTAssertEqual(owner.refreshInterval, 0)
    }

    func testMultiformatRequiresAtLeastTwoFormats() {
        let controller = PrebidMultiformatConfigurationController(controller: ConfigurableBanner())
        controller.loadViewIfNeeded()
        let section = controller.sections[0]
        XCTAssertTrue(section.footer!.isEnabled)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertFalse(controller.includeBanner)
        XCTAssertTrue(section.footer!.isEnabled)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertFalse(controller.includeVideo)
        XCTAssertFalse(section.footer!.isEnabled)
        controller.tableView(controller.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(section.footer!.isEnabled)
    }

    func testConsentRowsPersistAndRemoveEmptyValues() {
        let key = IABConsentSettingKey.usPrivacyString
        let original = UserDefaults.standard.object(forKey: key)
        defer {
            if let original = original { UserDefaults.standard.set(original, forKey: key) }
            else { UserDefaults.standard.removeObject(forKey: key) }
        }
        let controller = IABConsentViewController()
        controller.loadViewIfNeeded()
        let row = controller.sections[2].rows[0]
        row.onTextChange?("1YNN")
        XCTAssertEqual(UserDefaults.standard.string(forKey: key), "1YNN")
        row.onTextChange?("")
        XCTAssertNil(UserDefaults.standard.object(forKey: key))
    }
}

private final class ConfigurableBanner: PrebidConfigurableBannerController {
    var prebidConfigId = "original"
    var refreshInterval: TimeInterval = 30
    func configurationController() -> BaseConfigurationController? { nil }
}
