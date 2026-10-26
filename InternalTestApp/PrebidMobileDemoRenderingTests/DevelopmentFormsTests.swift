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

    func testTextCellReuseRebindsTheCurrentRowWithoutDuplicateControls() {
        let first = FormRow("First", kind: .text, value: "first")
        let second = FormRow("Second", kind: .text, value: "second")
        second.controlIdentifier = "second_field"
        var firstChanges = 0
        var secondChanges = 0
        first.onTextChange = { _ in firstChanges += 1 }
        second.onTextChange = { _ in secondChanges += 1 }
        let cell = makeCell(for: first)
        let field = cell.contentView.subviews.compactMap { $0 as? UITextField }.first!
        let subviewCount = cell.contentView.subviews.count
        let constraintCount = cell.contentView.constraints.count
        field.text = "edited-first"
        field.sendActions(for: .editingChanged)

        cell.prepareForReuse()
        cell.configure(second)
        cell.configure(second)
        XCTAssertEqual(field.text, "second")
        XCTAssertEqual(field.accessibilityLabel, "Second")
        XCTAssertEqual(field.accessibilityIdentifier, "second_field")
        field.text = "edited-second"
        field.sendActions(for: .editingChanged)

        XCTAssertEqual(first.value, "edited-first")
        XCTAssertEqual(second.value, "edited-second")
        XCTAssertEqual(firstChanges, 1)
        XCTAssertEqual(secondChanges, 1)
        XCTAssertEqual(cell.contentView.subviews.count, subviewCount)
        XCTAssertEqual(cell.contentView.constraints.count, constraintCount)
        XCTAssertNotNil(cell.reuseIdentifier)
    }

    func testToggleCellReuseRebindsTheCurrentRow() {
        let first = FormRow("First", kind: .toggle)
        let second = FormRow("Second", kind: .toggle, isOn: true)
        second.controlIdentifier = "second_toggle"
        var firstChanges = 0
        var secondChanges = 0
        first.onToggle = { _ in firstChanges += 1 }
        second.onToggle = { _ in secondChanges += 1 }
        let cell = makeCell(for: first)
        let control = cell.accessoryView as! UISwitch
        control.isOn = true
        control.sendActions(for: .valueChanged)

        cell.prepareForReuse()
        cell.configure(second)
        cell.configure(second)
        XCTAssertTrue(control.isOn)
        XCTAssertEqual(control.accessibilityLabel, "Second")
        XCTAssertEqual(control.accessibilityIdentifier, "second_toggle")
        control.isOn = false
        control.sendActions(for: .valueChanged)

        XCTAssertTrue(first.isOn)
        XCTAssertFalse(second.isOn)
        XCTAssertEqual(firstChanges, 1)
        XCTAssertEqual(secondChanges, 1)
        XCTAssertTrue(cell.accessoryView === control)
    }

    func testDisplayCellReuseClearsPreviousPresentationState() {
        let action = FormRow("Action", kind: .action)
        action.accessoryType = .disclosureIndicator
        let label = FormRow("Version", kind: .label, value: "1.0")
        label.detailIdentifier = "version_value"
        let checkmark = FormRow("Choice", kind: .checkmark)
        let cell = makeCell(for: action)
        XCTAssertEqual(cell.accessoryType, .disclosureIndicator)
        XCTAssertEqual(cell.textLabel?.textColor, .systemBlue)

        cell.prepareForReuse()
        cell.configure(label)
        XCTAssertEqual(cell.textLabel?.textColor, .label)
        XCTAssertEqual(cell.detailTextLabel?.text, "1.0")
        XCTAssertEqual(cell.detailTextLabel?.accessibilityIdentifier, "version_value")
        XCTAssertEqual(cell.accessoryType, .none)
        XCTAssertEqual(cell.selectionStyle, .none)

        cell.prepareForReuse()
        cell.configure(checkmark)
        XCTAssertNil(cell.detailTextLabel?.text)
        XCTAssertNil(cell.detailTextLabel?.accessibilityIdentifier)
        XCTAssertEqual(cell.selectionStyle, .default)
        XCTAssertEqual(cell.accessoryType, .none)
    }

    private func makeCell(for row: FormRow) -> FormTableViewCell {
        let controller = FormTableViewController()
        controller.sections = [FormSection(rows: [row])]
        controller.loadViewIfNeeded()
        return controller.tableView(controller.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! FormTableViewCell
    }
}

private final class ConfigurableBanner: PrebidConfigurableBannerController {
    var prebidConfigId = "original"
    var refreshInterval: TimeInterval = 30
    func configurationController() -> BaseConfigurationController? { nil }
}
