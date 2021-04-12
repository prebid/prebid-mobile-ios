//
//  ArrayExtension.swift
//  OpenXInternalTestApp
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import Foundation

extension Array where Element == TestCaseTag {
    func intersection(_ other: [Element]) -> [Element] {
        return Array(Set(self).intersection(Set(other)))
    }
}
