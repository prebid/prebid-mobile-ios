//
//  PBMAssert.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest

public func PBMAssertEq<T:Equatable>(_ actual:T?, _ expected:T?, file: StaticString = #file, line: UInt = #line) {
    if (expected != actual) {
        PBMFail(actual, expected, file:file, line:line)
    }
}

public func PBMAssertEq<T:Equatable>(_ actual:[T]?, _ expected:[T]?, file: StaticString = #file, line: UInt = #line) {
    //If both are nil, test passes.
    if (expected == nil) && (actual == nil) {
        return
    }
    
    //Swift forces an unwrap before comparison to non-explicit nil.
    guard let unwrappedExpected = expected, let unwrappedActual = actual, unwrappedExpected == unwrappedActual else {
        PBMFail(actual, expected, file:file, line:line)
        return
    }
}

public func PBMAssertEq<Key, Value:Equatable>(_ actual: [Key : Value]?, _ expected: [Key : Value]?, file: StaticString = #file, line: UInt = #line) {
    //If both are nil, test passes.
    if (expected == nil) && (actual == nil) {
        return
    }
    
    //Swift forces an unwrap before comparison to non-explicit nil.
    guard let unwrappedExpected = expected, let unwrappedActual = actual, unwrappedExpected == unwrappedActual else {
        PBMFail(expected, actual, file:file, line:line)
        return
    }
}

public func PBMFail(_ actual:Any?, _ expected:Any?, file:StaticString = #file, line:UInt = #line) {
    
    var message = "Expected: \(String(describing: expected)) Got: \(String(describing: actual))"
    
    //If the message is long, break it into multiple lines for easier comparison.
    if message.count > 100 {
        message = "Expected:\n\(String(describing: expected))\n\nGot:\n\(String(describing: actual))"
    }
    
    XCTFail(message, file:file, line:line)
}

