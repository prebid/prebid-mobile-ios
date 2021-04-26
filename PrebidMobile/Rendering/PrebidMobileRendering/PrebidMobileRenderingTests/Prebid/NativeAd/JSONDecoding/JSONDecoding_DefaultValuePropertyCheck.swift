//
//  JSONDecoding_DefaultValuePropertyCheck.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

extension JSONDecoding {
    typealias DefaultValuePropertyCheck<T, V: Equatable> = Decoding.DefaultValuePropertyCheck<NSMutableDictionary, T, V>
}

extension Decoding {
    class DefaultValuePropertyCheck<RawType, BoxedType, ValueType: Equatable>: BaseOptionalCheck<RawType, BoxedType> {
        let value: ValueType
        let defaultValue: ValueType
        let writer: (RawType, ValueType) -> ()
        let reader: (BoxedType) -> ValueType
        let file: StaticString
        let line: UInt
        
        init(value: ValueType,
             defaultValue: ValueType,
             writer: @escaping (RawType, ValueType) -> (),
             reader: @escaping (BoxedType) -> ValueType,
             file: StaticString = #file,
             line: UInt = #line)
        {
            self.value = value
            self.defaultValue = defaultValue
            self.writer = writer
            self.reader = reader
            self.file = file
            self.line = line
        }
        
        convenience init(value: ValueType,
                         writeKeyPath: ReferenceWritableKeyPath<RawType, ValueType?>,
                         readKeyPath: KeyPath<BoxedType, ValueType>,
                         defaultValue: ValueType,
                         file: StaticString = #file,
                         line: UInt = #line)
        {
            self.init(value: value,
                      defaultValue: defaultValue,
                      writer: { $0[keyPath: writeKeyPath] = $1 },
                      reader: { $0[keyPath: readKeyPath] },
                      file: file,
                      line: line)
        }
        
        override func toPropertyCheck(included: Bool) -> CheckType {
            if included {
                return .init(saver: { self.writer($0, self.value) }) {
                    let otherValue = self.reader($0)
                    XCTAssertEqual(otherValue, self.value, file: self.file, line:self.line)
                }
            } else {
                return .init(saver: { _ in }, checker: {
                    let otherValue = self.reader($0)
                    XCTAssertEqual(otherValue, self.defaultValue, file: self.file, line:self.line)
                })
            }
        }
    }
}
