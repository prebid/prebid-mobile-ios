//
//  Equality_Check.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension Equality {
    class Check<T, V>: BaseCheck<T> {
        private let v1: V
        private let v2: V
        private let writer: (T, V)->()
        
        init(values v1: V, _ v2: V, file: StaticString = #file, line: UInt = #line, writer: @escaping (T, V)->()) {
            self.v1 = v1
            self.v2 = v2
            self.writer = writer
        }
        
        convenience init(values v1: V, _ v2: V, keyPath: ReferenceWritableKeyPath<T, V>,
                         file: StaticString = #file, line: UInt = #line)
        {
            self.init(values: v1, v2, file: file, line: line) { $0[keyPath: keyPath] = $1 }
        }
        
        convenience init(values v1: V, _ v2: V, keyPath: ReferenceWritableKeyPath<T, V?>,
                         file: StaticString = #file, line: UInt = #line)
        {
            self.init(values: v1, v2, file: file, line: line) { $0[keyPath: keyPath] = $1 }
        }
        
        override func applyValue(_ valueIndex: AppliedValueIndex, to target: T) {
            writer(target, valueIndex == .first ? v1 : v2)
        }
    }
}
