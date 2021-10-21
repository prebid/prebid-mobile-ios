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
