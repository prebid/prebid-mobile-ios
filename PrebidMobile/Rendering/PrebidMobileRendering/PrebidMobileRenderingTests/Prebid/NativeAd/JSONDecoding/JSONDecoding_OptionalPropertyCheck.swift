//
//  JSONDecoding_OptionalPropertyCheck.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

extension JSONDecoding {
    typealias OptionalPropertyCheck<T, V: Equatable> = Decoding.OptionalPropertyCheck<NSMutableDictionary, T, V>
}

extension Decoding {
    class OptionalPropertyCheck<RawType, BoxedType, ValueType: Equatable>: BaseOptionalCheck<RawType, BoxedType> {
        let value: ValueType
        let writer: (RawType, ValueType) -> ()
        let reader: (BoxedType) -> ValueType?
        let file: StaticString
        let line: UInt
        
        init(value: ValueType,
             writer: @escaping (RawType, ValueType) -> (),
             reader: @escaping (BoxedType) -> ValueType?,
             file: StaticString = #file,
             line: UInt = #line)
        {
            self.value = value
            self.writer = writer
            self.reader = reader
            self.file = file
            self.line = line
        }
        
        convenience init(value: ValueType,
                         dicKey: String,
                         keyPath: KeyPath<BoxedType, ValueType?>,
                         file: StaticString = #file,
                         line: UInt = #line) where RawType == NSMutableDictionary
        {
            self.init(value: value,
                      writer: { $0[dicKey] = $1 },
                      reader: { $0[keyPath: keyPath] },
                      file: file,
                      line: line)
        }
        
        convenience init(value: [String: Any],
                         dicKey: String,
                         keyPath: KeyPath<BoxedType, [String: Any]?>,
                         file: StaticString = #file,
                         line: UInt = #line) where ValueType == NSDictionary, RawType == NSMutableDictionary
        {
            self.init(value: value as NSDictionary,
                      writer: { $0[dicKey] = $1 },
                      reader: { $0[keyPath: keyPath] as NSDictionary? },
                      file: file,
                      line: line)
        }
        
        override func toPropertyCheck(included: Bool) -> CheckType {
            if included {
                return .init(saver: { self.writer($0, self.value) }) {
                    XCTAssertEqual(self.reader($0), self.value, file: self.file, line:self.line)
                }
            } else {
                return .init(saver: { _ in }, checker: {
                    XCTAssertNil(self.reader($0), file: self.file, line:self.line)
                })
            }
        }
    }
}
