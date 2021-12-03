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
