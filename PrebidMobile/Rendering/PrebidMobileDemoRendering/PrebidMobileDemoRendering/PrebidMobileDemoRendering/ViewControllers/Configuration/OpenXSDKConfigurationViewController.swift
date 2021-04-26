//
//  PBMSDKConfigurationViewController.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import UIKit
import Eureka

final class OpenXSDKConfigurationController : FormViewController {
    
    var sdkConfig: PBMSDKConfiguration {
        return PBMSDKConfiguration.singleton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createForm()
    }
    
    // MARK: - Private Methods
    
    func createForm() {
        title = "OpenX SDK Configuration"
        
        form
            +++ sectionTimeouts
            +++ sectionMisc
            +++ sectionAppConfig
    }
    
    var sectionTimeouts: Section {
        return Section("Creative Factory Timeouts")
            <<< TextRow() { row in
                    row.title = "General"
                    row.value = "\(self.sdkConfig.creativeFactoryTimeout)"
                    row.cell.textField.accessibilityIdentifier = "creativeFactoryTimeoutTextField"
                }
                .onChange { row in
                    self.sdkConfig.creativeFactoryTimeout = row.value.pbm_toTimeInterval()
            }
            <<< TextRow() {row in
                    row.title = "Pre Render Content"
                    row.value = "\(self.sdkConfig.creativeFactoryTimeoutPreRenderContent)"
                    row.cell.textField.accessibilityIdentifier = "creativeFactoryTimeoutPreRenderContentTextField"
                }
                .onChange { row in
                    self.sdkConfig.creativeFactoryTimeoutPreRenderContent = row.value.pbm_toTimeInterval()
            }
    }
    
    var sectionMisc: Section {
        return Section("Misc")
            <<< SwitchRow() { row in
                    row.title = "Use External Clickthrough Browser"
                    row.value = self.sdkConfig.useExternalClickthroughBrowser
                    row.cell.switchControl.accessibilityIdentifier = "useExternalClickthroughBrowserSwitch"
                }
                .onChange { row in
                    self.sdkConfig.useExternalClickthroughBrowser = row.value ?? false
                }
    }
    
    var sectionAppConfig: Section {
        return Section("App configuration")
            <<< SwitchRow() { row in
                row.title = "Status Bar Hidden"
                row.value = AppConfiguration.shared.isAppStatusBarHidden
                row.cell.switchControl.accessibilityIdentifier = "statusBarHiddenSwitch"
            }
            .onChange { row in
                AppConfiguration.shared.isAppStatusBarHidden = row.value ?? true
                self.setNeedsStatusBarAppearanceUpdate()
            }
    }
}
