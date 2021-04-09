//
//  JSONDecoding_ArrayPropertyCheck.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

extension JSONDecoding {
    typealias ArrayPropertyCheck<T, V: Equatable> = Decoding.ArrayPropertyCheck<NSMutableDictionary, T, V>
}

extension Decoding {
    class ArrayPropertyCheck<RawType, BoxedType, ValueType: Equatable>: DefaultValuePropertyCheck<RawType, BoxedType, [ValueType]> {
        convenience init(value: [ValueType],
                         writer: @escaping (RawType, [ValueType]) -> (),
                         reader: @escaping (BoxedType) -> [ValueType],
                         file: StaticString = #file,
                         line: UInt = #line)
        {
            self.init(value: value, defaultValue: [], writer: writer, reader: reader, file: file, line: line)
        }
        
        convenience init(value: [ValueType],
                         writeKeyPath: ReferenceWritableKeyPath<RawType, [ValueType]?>,
                         readKeyPath: KeyPath<BoxedType, [ValueType]>,
                         file: StaticString = #file,
                         line: UInt = #line)
        {
            self.init(value: value,
                      writeKeyPath: writeKeyPath,
                      readKeyPath: readKeyPath,
                      defaultValue: [],
                      file: file,
                      line: line)
        }
    }
}
