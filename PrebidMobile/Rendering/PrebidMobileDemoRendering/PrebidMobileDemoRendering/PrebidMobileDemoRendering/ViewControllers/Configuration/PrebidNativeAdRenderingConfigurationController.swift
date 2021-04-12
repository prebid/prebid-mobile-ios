//
//  PrebidNativeAdRenderingConfigurationController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

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

