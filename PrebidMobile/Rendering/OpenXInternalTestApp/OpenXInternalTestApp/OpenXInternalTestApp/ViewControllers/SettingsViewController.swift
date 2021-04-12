//
//  SettingsViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import UIKit
import Eureka

class SettingsViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        createForm()
    }
    
    private func createForm() {
        title = "App Settings"
        
        form
            +++ Section("HUD Settings")
            <<< showHUDRow
    }

    private static func switchRow(for userDefaultsKey: String, title: String) -> SwitchRow {
        return SwitchRow() { row in
            row.title = title
            row.value = UserDefaults.standard.bool(forKey: userDefaultsKey)
            row.cell.accessibilityIdentifier = title
        }.onChange { row in
            UserDefaults.standard.set(row.value, forKey: userDefaultsKey)
        }
    }
    
    private let showHUDRow = switchRow(for: AppSettingsKeys.showHUD, title: "Show HUD")
}
