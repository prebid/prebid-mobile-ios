//
//  PrebidBannerConfigurationController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import Eureka

protocol PrebidConfigurableBannerController: PrebidConfigurableNativeAdCompatibleController {
    var refreshInterval: TimeInterval { get set }
}

class PrebidBannerConfigurationController: PrebidNativeAdCompatibleConfigurationController {
    
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
