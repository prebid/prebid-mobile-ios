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

class PBMLogTest: XCTestCase {
    
    private let sdkVersion = PBMFunctions.sdkVersion()
    private let message = "Test PBMLog"
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        
        PBMLog.shared.logLevel = .info
    }
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    
    func testLogGlobalQueue() {
        
        // Test: default params
        
        logToFile = .init()
        let logExpectation = expectation(description: "logExpectation")
        
        var descr = ""
        DispatchQueue.global().async {
            descr = Thread.current.description
            PBMLog.info("The Global Queue")
            logExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: { _ in
            let log = Log.getLogFileAsString() ?? ""
            
            let threadNumber = descr
                .split(separator:"=")[1]
                .split(separator:",").first?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            XCTAssert(log.contains("prebid-mobile-sdk INFO [\(threadNumber!)]"))
            XCTAssertFalse(log.contains("[Line "))
        })
    }
    
    
    func testAllKinds() {
        
        // Test: default params
        
        logToFile = .init()
        
        PBMLog.info(message)
        checkLogAndClean(level: "INFO", withParams: false)
        
        PBMLog.warn(message)
        checkLogAndClean(level: "WARNING", withParams: false)
        
        PBMLog.error(message)
        checkLogAndClean(level: "ERROR", withParams: false)
        
        PBMLog.message(message)
        checkLogAndClean(level: "NONE", withParams: false)
        
        // Test: with params
        
        logToFile = nil
        logToFile = .init()
        
        PBMLog.info(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "INFO", withParams: true)
        
        PBMLog.warn(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "WARNING", withParams: true)
        
        PBMLog.error(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "ERROR", withParams: true)
        
        PBMLog.message(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "NONE", withParams: true)
    }
    
    func testLogObjC() {
        
        logToFile = .init()
        
        // Test: default params
        
        PBMLog.logObjC(message, logLevel: .warn, file: nil, line: 0, function: nil)
        checkLogAndClean(level: "WARNING", withParams: false)
        
        // Test: with params
        
        PBMLog.logObjC(message, logLevel: .warn, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "WARNING", withParams: true)
    }
    
    func testLogLevel() {
        logToFile = .init()
        
        // Check default
        let initialLogLevel: LogLevel = .info
        XCTAssertEqual(Log.logLevel, initialLogLevel)
        
        Log.warn(message)
        checkLogAndClean(level: "WARNING", withParams: false)
        
        // Test: warning message should be skipped
        Log.logLevel = .error
        
        Log.warn(message)
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertEqual(log, "")
        
        // Rreturn to the initial state
        Log.logLevel = initialLogLevel
        
        Log.warn(message)
        checkLogAndClean(level: "WARNING", withParams: false)
    }
    
    // MARK: Internal Methods
    
    func checkLogAndClean(level: String, withParams: Bool, file: StaticString = #file, line: UInt = #line) {
        let log = Log.getLogFileAsString() ?? ""
        
        let sdkVersionString = level != "ERROR" ? "" : "v\(sdkVersion) ";
        
        XCTAssert(log.contains(message), file: file, line: line)
        XCTAssert(log.contains("prebid-mobile-sdk \(sdkVersionString)\(level) [MAIN]"), file: file, line: line)
        XCTAssert(log.contains("[Line ") == withParams, file: file, line: line)
        
        logToFile = nil
        logToFile = .init()
    }
    
    
//    func testLogInternal() {
//        logToFile = .init()
//        
//        PBMLog.shared.logInternal("MSG", logLevel:.info, file:#file, line:10, function:#function)
//        let log = PBMLog.shared.getLogFileAsString()
//        XCTAssert(log.contains("prebid-mobile-sdk INFO [MAIN]"))
//        XCTAssert(log.contains("PBMLogTest.swift testLogInternal() [Line 10]: MSG"))
//        
//        logToFile = nil
//        logToFile = .init()
//        
//        PBMLog.shared.logLevel = .warn
//        PBMLog.shared.logInternal("MSG", logLevel:.info, file:#file, line:10, function:#function)
//        XCTAssert(PBMLog.shared.getLogFileAsString().isEmpty)
//    }
}
