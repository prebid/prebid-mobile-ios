//
//  Equality_Tester.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation
import XCTest

extension Equality {
    class Tester<T: Equatable> {
        let factory: ()->T
        let checks: [BaseCheck<T>]
        
        init(factory: @escaping ()->T, checks: [BaseCheck<T>]) {
            self.factory = factory
            self.checks = checks
        }
        convenience init(template: @escaping @autoclosure ()->T, checks: [BaseCheck<T>]) {
            self.init(factory: template, checks: checks)
        }
        
        func run(file: StaticString = #file, line: UInt = #line) {
            if let obj = factory() as? NSObject {
                XCTAssertNotEqual(obj, NSObject(), file: file, line: line)
            }
            
            XCTAssertEqual(factory(), factory(), file: file, line: line)
            
            for nextCheck in checks {
                for leftValue in AppliedValueIndex.allCases {
                    for rightValue in AppliedValueIndex.allCases {
                        let lhs = factory()
                        let rhs = factory()
                        nextCheck.applyValue(leftValue, to: lhs)
                        nextCheck.applyValue(rightValue, to: rhs)
                        if leftValue == rightValue {
                            XCTAssertEqual(lhs, rhs, file: file, line: line)
                        } else {
                            XCTAssertNotEqual(lhs, rhs, file: file, line: line)
                        }
                    }
                }
            }
        }
    }
}
