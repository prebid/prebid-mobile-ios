//
//  RepeatedUITestCase.swift
//  OpenXInternalTestAppUITests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

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
                recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
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
                recordFailure(withDescription: failure.0, inFile: failure.1, atLine: Int(failure.2), expected: true)
            }
        }
        continueAfterFailure = false
        XCTFail("Failed to get successful iteration after \(times) time(s)", file: file, line: line)
    }
    
}

