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
