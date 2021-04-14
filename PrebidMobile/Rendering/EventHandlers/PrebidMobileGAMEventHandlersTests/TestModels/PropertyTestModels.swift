//
//  PropertyTestModels.swift
//  OpenXApolloGAMEventHandlersTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

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
