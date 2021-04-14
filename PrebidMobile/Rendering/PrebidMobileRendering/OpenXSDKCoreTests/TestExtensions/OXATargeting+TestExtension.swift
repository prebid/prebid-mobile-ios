//
//  OXATargeting+TestExtension.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension OXATargeting {
    class var withDisabledLock: OXATargeting {
        let newTargeting = OXATargeting(parameters: [:], coordinate: nil)
        newTargeting.disableLockUsage = true
        return newTargeting
    }
}
