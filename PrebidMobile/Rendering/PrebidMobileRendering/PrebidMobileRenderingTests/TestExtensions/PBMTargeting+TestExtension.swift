//
//  PBMTargeting+TestExtension.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension PBMTargeting {
    class var withDisabledLock: PBMTargeting {
        let newTargeting = PBMTargeting(parameters: [:], coordinate: nil)
        newTargeting.disableLockUsage = true
        return newTargeting
    }
}
