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

import Foundation
import Eureka
import PrebidMobile

protocol PrebidConfigurableNativeAdCompatibleController: PrebidConfigurableController {
    var nativeAdConfig: NativeAdConfiguration? { get set }
}

class PrebidNativeAdCompatibleConfigurationController: BaseConfigurationController {
    override var loadSection: Section {
        super.loadSection
            <<< nativeAdConfigRow
    }
    
    private var nativeAdConfig: NativeAdConfiguration? {
        get {
            (self.controller as? PrebidConfigurableBannerController)?.nativeAdConfig
        }
        set {
            (self.controller as? PrebidConfigurableBannerController)?.nativeAdConfig = newValue
            updateNativeAdConfigRow(nativeAdConfigRow)
            nativeAdConfigRow.updateCell()
        }
    }

    lazy var nativeAdConfigRow = LabelRow("native_ad_config") { row in
        row.title = "Native Ad Config"
        row.trailingSwipe.performsFirstActionWithFullSwipe = true
        updateNativeAdConfigRow(row)
    }
    .cellSetup { cell, row in
        cell.accessibilityIdentifier = "edit_native_ad_config"
        cell.accessoryType = .disclosureIndicator
    }
    .onCellSelection { [weak self] cell, row in
        cell.setSelected(false, animated: false)
        self?.editNativeAdConfig()
    }
    
    private func updateNativeAdConfigRow(_ row: LabelRow) {
        guard nativeAdConfig != nil else {
            row.value = "nil"
            row.trailingSwipe.actions = []
            return
        }
        row.value = "{...}"
        
        let deleteAction = SwipeAction(style: .normal, title: "Delete") { [weak self] (action, row, completionHandler) in
            self?.nativeAdConfig = nil
            completionHandler?(true)
        }
        deleteAction.image = UIImage(named: "icon-trash")
        deleteAction.actionBackgroundColor = .systemRed
        
        row.trailingSwipe.actions = [deleteAction]
    }
    
    private func editNativeAdConfig() {
        if nativeAdConfig == nil {
            nativeAdConfig = NativeAdConfiguration(assets: [])
        }
        let editor = NativeAdConfigController()
        editor.nativeAdConfig = nativeAdConfig
        navigationController?.pushViewController(editor, animated: true)
    }
}
