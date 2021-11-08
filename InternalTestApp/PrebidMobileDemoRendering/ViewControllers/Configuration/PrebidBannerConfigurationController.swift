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

protocol PrebidConfigurableBannerController: PrebidConfigurableController {
    var refreshInterval: TimeInterval { get set }
}

class PrebidBannerConfigurationController: BaseConfigurationController {
    
    var refreshInterval: TimeInterval = 0
    
    override func setupView() {
        guard let bannerController = self.controller as? PrebidConfigurableBannerController else {
            assertionFailure()
            return
        }
        
        super.setupView()
        
        refreshInterval = bannerController.refreshInterval
    }
    
    override var loadSection: Section {
        super.loadSection
            <<< rowAutoRefreshDelay
    }
    
    override func onConfigurationFinished() {
        guard let bannerController = self.controller as? PrebidConfigurableBannerController else {
            assertionFailure()
            return
        }
        super.onConfigurationFinished()
        
        bannerController.refreshInterval = refreshInterval
    }
    
    lazy var rowAutoRefreshDelay = TextRow("refresh_interval") { row in
        row.title = "Refresh Interval"
        row.value = "\(refreshInterval)"
    }
    .cellSetup { cell, row in
        cell.accessibilityIdentifier = "refreshInterval"
        cell.textField.isAccessibilityElement = true
        cell.textField.accessibilityIdentifier = "refreshInterval_field"
    }
    .onChange { row in
        // Clearing the text field resets auto refresh delay to it's the configured default.
        if let autoRefreshDelayText = row.value.pbm_trimCharactersToNil() {
            self.refreshInterval = TimeInterval(autoRefreshDelayText) ?? 0
        } else {
            self.refreshInterval = 0
        }
    }
}
