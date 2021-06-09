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

protocol PrebidConfigurableNativeAdRenderingController: PrebidConfigurableNativeAdCompatibleController {
    var autoPlayOnVisible: Bool { get set }
    var showOnlyMediaView: Bool { get set }
}

class PrebidNativeAdRenderingConfigurationController: PrebidNativeAdCompatibleConfigurationController {
    override var loadSection: Section {
        super.loadSection
            <<< autoPlayOnVisibleRow
            <<< showOnlyMediaViewRow
    }
    
    private var autoPlayOnVisible: Bool {
        get {
            (self.controller as? PrebidConfigurableNativeAdRenderingController)?.autoPlayOnVisible ?? false
        }
        set {
            (self.controller as? PrebidConfigurableNativeAdRenderingController)?.autoPlayOnVisible = newValue
            autoPlayOnVisibleRow.value = newValue
            autoPlayOnVisibleRow.updateCell()
        }
    }
    
    lazy var autoPlayOnVisibleRow = SwitchRow("auto_play_on_visible") { [weak self] row in
        row.title = "AutoPlay On Visible"
        row.value = self?.autoPlayOnVisible
    }
    .onChange { [weak self] row in
        self?.autoPlayOnVisible = row.value ?? false
    }
    
    private var showOnlyMediaView: Bool {
        get {
            (self.controller as? PrebidConfigurableNativeAdRenderingController)?.showOnlyMediaView ?? false
        }
        set {
            (self.controller as? PrebidConfigurableNativeAdRenderingController)?.showOnlyMediaView = newValue
            showOnlyMediaViewRow.value = newValue
            showOnlyMediaViewRow.updateCell()
        }
    }
    
    lazy var showOnlyMediaViewRow = SwitchRow("show_only_media_view") { [weak self] row in
        row.title = "Show only MediaView"
        row.value = self?.showOnlyMediaView
    }
    .onChange { [weak self] row in
        self?.showOnlyMediaView = row.value ?? false
    }
}

