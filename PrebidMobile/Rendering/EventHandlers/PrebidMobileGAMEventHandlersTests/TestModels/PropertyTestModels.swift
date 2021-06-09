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

class BasePropTest<T> {
    let file: StaticString
    let line: UInt
    
    init(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }
    func run(object: T) {}
}

class PropTest<T, V: Equatable>: BasePropTest<T> {
    let keyPath: ReferenceWritableKeyPath<T, V>
    let value: V
    
    init(keyPath: ReferenceWritableKeyPath<T, V>, value: V, file: StaticString = #file, line: UInt = #line) {
        self.keyPath = keyPath
        self.value = value
        super.init(file: file, line: line)
    }
    
    override func run(object: T) {
        object[keyPath: keyPath] = value
        let readValue = object[keyPath: keyPath]
        XCTAssertEqual(readValue, value, file: file, line: line)
    }
}

class RefPropTest<T, V: NSObjectProtocol>: BasePropTest<T> {
    let keyPath: ReferenceWritableKeyPath<T, V?>
    let value: V
    
    init(keyPath: ReferenceWritableKeyPath<T, V?>, value: V, file: StaticString = #file, line: UInt = #line) {
        self.keyPath = keyPath
        self.value = value
        super.init(file: file, line: line)
    }
    
    override func run(object: T) {
        object[keyPath: keyPath] = value
        let readValue = object[keyPath: keyPath]
        XCTAssertEqual(readValue as? NSObject?, value as? NSObject, file: file, line: line)
    }
}

class RefProxyPropTest<T, V: NSObjectProtocol>: BasePropTest<T> {
    let keyPath: ReferenceWritableKeyPath<T, V?>
    let value: V
    
    init(keyPath: ReferenceWritableKeyPath<T, V?>, value: V, file: StaticString = #file, line: UInt = #line) {
        self.keyPath = keyPath
        self.value = value
        super.init(file: file, line: line)
    }
    
    override func run(object: T) {
        object[keyPath: keyPath] = value
        
        let _ = object[keyPath: keyPath]
        
        // Do nothing since there is no storage for value yet. We just test properties.
        //XCTAssertEqual(readValue as? NSObject?, value as? NSObject, file: file, line: line)
    }
}

class DicPropTest<T, K: Hashable, V>: BasePropTest<T> {
    let keyPath: ReferenceWritableKeyPath<T, [K: V]?>
    let value: [K: V]
    
    init(keyPath: ReferenceWritableKeyPath<T, [K: V]?>, value: [K: V], file: StaticString = #file, line: UInt = #line) {
        self.keyPath = keyPath
        self.value = value
        super.init(file: file, line: line)
    }
    
    override func run(object: T) {
        object[keyPath: keyPath] = value
        let readValue = object[keyPath: keyPath]
        XCTAssertEqual(readValue as NSDictionary?, value as NSDictionary, file: file, line: line)
    }
}
