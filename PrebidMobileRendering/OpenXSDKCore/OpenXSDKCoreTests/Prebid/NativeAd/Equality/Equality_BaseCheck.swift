//
//  Equality_BaseCheck.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension Equality {
    class BaseCheck<T> {
        // abstract
        func applyValue(_ valueIndex: AppliedValueIndex, to target: T) {}
    }
}
