//
//  OXMLogTest.swift
//  OpenX ApolloCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMLogTest: XCTestCase {
    
    private let sdkVersion = OXMFunctions.sdkVersion()
    private let message = "Test OXMLog"
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        
        OXMLog.singleton.logLevel = .info
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
            OXMLog.info("The Global Queue")
            logExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: { _ in
            let log = OXMLog.singleton.getLogFileAsString()
            
            let threadNumber = descr
                                .split(separator:"=")[1]
                                .split(separator:",").first?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            XCTAssert(log.contains("OpenX Apollo INFO [\(threadNumber!)]"))
            XCTAssertFalse(log.contains("[Line "))
        })
    }

    
    func testAllKinds() {
        
        // Test: default params
        
        logToFile = .init()
        
        OXMLog.info(message)
        checkLogAndClean(level: "INFO", withParams: false)
        
        OXMLog.warn(message)
        checkLogAndClean(level: "WARNING", withParams: false)
        
        OXMLog.error(message)
        checkLogAndClean(level: "ERROR", withParams: false)
        
        OXMLog.message(message)
        checkLogAndClean(level: "NONE", withParams: false)
        
        // Test: with params
        
        logToFile = nil
        logToFile = .init()
        
        OXMLog.info(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "INFO", withParams: true)
        
        OXMLog.warn(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "WARNING", withParams: true)
        
        OXMLog.error(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "ERROR", withParams: true)
        
        OXMLog.message(message, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "NONE", withParams: true)
    }
    
    func testLogObjC() {
        
        logToFile = .init()
        
        // Test: default params
        
        OXMLog.logObjC(message, logLevel: .warn, file: nil, line: 0, function: nil)
        checkLogAndClean(level: "WARNING", withParams: false)

        // Test: with params

        OXMLog.logObjC(message, logLevel: .warn, file: #file, line: #line, function: #function)
        checkLogAndClean(level: "WARNING", withParams: true)
    }
    
    func testLogLevel() {
        logToFile = .init()

        // Check default
        let initialLogLevel: OXALogLevel = .info
        XCTAssertEqual(OXMLog.singleton.logLevel, initialLogLevel)
        
        OXMLog.warn(message)
        checkLogAndClean(level: "WARNING", withParams: false)
        
        // Test: warning message should be skipped
        OXMLog.singleton.logLevel = .error
        
        OXMLog.warn(message)
        XCTAssertEqual(OXMLog.singleton.getLogFileAsString(), "")
        
        // Rreturn to the initial state
        OXMLog.singleton.logLevel = initialLogLevel

        OXMLog.warn(message)
        checkLogAndClean(level: "WARNING", withParams: false)
    }
    
    // MARK: Internal Methods
    
    func checkLogAndClean(level: String, withParams: Bool, file: StaticString = #file, line: UInt = #line) {
        let log = OXMLog.singleton.getLogFileAsString()
        
        let sdkVersionString = level != "ERROR" ? "" : "v\(sdkVersion) ";
        
        XCTAssert(log.contains(message), file: file, line: line)
        XCTAssert(log.contains("OpenX Apollo \(sdkVersionString)\(level) [MAIN]"), file: file, line: line)
        XCTAssert(log.contains("[Line ") == withParams, file: file, line: line)
        
        logToFile = nil
        logToFile = .init()
    }
    
    func testLogLevelDescription() {
        XCTAssertEqual("INFO", OXMLog.logLevelDescription(.info))
        XCTAssertEqual("WARNING", OXMLog.logLevelDescription(.warn))
        XCTAssertEqual("ERROR", OXMLog.logLevelDescription(.error))
        XCTAssertEqual("NONE", OXMLog.logLevelDescription(.none))
    }
    
    func testLogInternal() {
        logToFile = .init()
        
        OXMLog.singleton.logInternal("MSG", logLevel:.info, file:#file, line:10, function:#function)
        let log = OXMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains("OpenX Apollo INFO [MAIN]"))
        XCTAssert(log.contains("OXMLogTest.swift testLogInternal() [Line 10]: MSG"))
        
        logToFile = nil
        logToFile = .init()
        
        OXMLog.singleton.logLevel = .warn
        OXMLog.singleton.logInternal("MSG", logLevel:.info, file:#file, line:10, function:#function)
        XCTAssert(OXMLog.singleton.getLogFileAsString().isEmpty)
    }
}
