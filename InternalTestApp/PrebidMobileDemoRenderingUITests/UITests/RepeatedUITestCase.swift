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

import XCTest

class RepeatedUITestCase: BaseUITestCase, Failable {
    private var iterationFailed = false
    private var iterationFailures: [[(String, String, UInt)]] = []
    private var isIterating = false
    private var noThrowCount = 0
    
    override func setUp() {
        super.setUp()
        
        iterationFailed = false
        iterationFailures = []
        isIterating = false
    }
    
    // MARK: Failable
    
    @objc func failTest(withMessage message: String, file: String, line: UInt, error errorPtr: NSErrorPointer) {
        failWithMessage(message, file: file, line: line, nothrow: false)
    }
    
    func failWithMessage(_ message: String, file: String, line: UInt, nothrow: Bool) {
        func performFailure() {
            if isIterating, iterationFailures.count > 0 {
                continueAfterFailure = true
                defer {
                    continueAfterFailure = false
                }
                
                iterationFailed = true
                iterationFailures[iterationFailures.count - 1].append((message, file, line))
                if noThrowCount == 0 {
                    failIterationRunning()
                }
            } else {
                record(XCTIssue(type: .assertionFailure, compactDescription: message))
            }
        }
        
        if nothrow {
            doNotThrowing {
                performFailure()
            }
        } else {
            performFailure()
        }
    }
    
    private func doNotThrowing(operation: () -> ()) {
        noThrowCount += 1
        defer {
            noThrowCount -= 1
        }
        operation()
    }
    
    // MARK: Iterative testing
    
    func failUnless(_ condition: @autoclosure () -> Bool, message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        if !condition() {
            failWithMessage(message(), file: "\(file)", line: line, nothrow: false)
        }
    }
    
    func repeatTesting(times: Int, file: StaticString = #file, line: UInt = #line, testClosure: () -> ()) {
        XCTAssertFalse(isIterating)
        isIterating = true
        defer {
            isIterating = false
        }
        for _ in 0..<times {
            iterationFailed = false
            iterationFailures.append([])
            
            iterationFailed = attemptRunningIteration(testClosure) == false
            
            Thread.sleep(forTimeInterval: 1)
            
            guard iterationFailed else {
                return
            }
        }
        continueAfterFailure = true
        for failureArray in iterationFailures {
            for failure in failureArray {
                record(XCTIssue(type: .assertionFailure, compactDescription: failure.0))
            }
        }
        continueAfterFailure = false
        XCTFail("Failed to get successful iteration after \(times) time(s)", file: file, line: line)
    }
    
}

