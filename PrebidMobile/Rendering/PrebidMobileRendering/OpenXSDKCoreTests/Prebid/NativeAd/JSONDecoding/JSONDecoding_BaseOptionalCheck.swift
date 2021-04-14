//
//  JSONDecoding_BaseOptionalCheck.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension JSONDecoding {
    typealias BaseOptionalCheck<T> = Decoding.BaseOptionalCheck<NSMutableDictionary, T>
}

extension Decoding {
    class BaseOptionalCheck<RawType, BoxedType> {
        typealias CheckType = PropertyCheck<RawType, BoxedType>
        // abstract
        func toPropertyCheck(included: Bool) -> CheckType {
            return .init(saver: { _ in }, checker: { _ in })
        }
    }
}
