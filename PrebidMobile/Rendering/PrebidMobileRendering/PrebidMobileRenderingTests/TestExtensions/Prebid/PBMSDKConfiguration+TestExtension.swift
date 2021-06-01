//
//  PBMSDKConfiguration+TestExtension.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension PrebidRenderingConfig {
    static let devintServerURL = "https://prebid.devint.openx.net/openrtb2/auction"
    static let devintAccountID = "4f112bad-8cd2-4c43-97d0-1ab72fd442ed"
    static let prodAccountID = "0689a263-318d-448b-a3d4-b02e8a709d9d"
    
    static var mock: PrebidRenderingConfig {
        PrebidRenderingConfig.reset()
        return PrebidRenderingConfig.shared
    }
    
    static func reset() {
        PrebidRenderingConfig.shared.prebidServerHost = .custom
        PrebidRenderingConfig.shared.accountID  = ""
        
        PrebidRenderingConfig.shared.bidRequestTimeoutMillis = 2000
        
        PrebidRenderingConfig.forcedIsViewable = false
    }
    
    static var forcedIsViewable: Bool {
        get { UserDefaults.standard.bool(forKey: "forcedIsViewable") }
        set { UserDefaults.standard.setValue(newValue, forKey: "forcedIsViewable")}
    }
}


