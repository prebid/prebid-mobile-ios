/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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
