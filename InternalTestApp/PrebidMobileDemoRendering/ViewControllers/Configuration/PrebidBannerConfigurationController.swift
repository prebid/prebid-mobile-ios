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

protocol PrebidConfigurableBannerController: PrebidConfigurableController {
    var refreshInterval: TimeInterval { get set }
}

class PrebidBannerConfigurationController: BaseConfigurationController {
    var refreshInterval: TimeInterval = 0

    override func setupView() {
        super.setupView()
        refreshInterval = (controller as? PrebidConfigurableBannerController)?.refreshInterval ?? 0
    }

    override var loadSection: FormSection {
        let section = super.loadSection
        section.rows.append(rowAutoRefreshDelay)
        return section
    }

    override func onConfigurationFinished() {
        super.onConfigurationFinished()
        (controller as? PrebidConfigurableBannerController)?.refreshInterval = refreshInterval
    }

    var rowAutoRefreshDelay: FormRow {
        let row = FormRow("Refresh Interval", kind: .text, value: "\(refreshInterval)")
        row.identifier = "refreshInterval"
        row.controlIdentifier = "refreshInterval_field"
        row.onTextChange = { [weak self] in
            self?.refreshInterval = TimeInterval($0.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        }
        return row
    }
}
