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
