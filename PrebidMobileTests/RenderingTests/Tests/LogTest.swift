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
@testable import PrebidMobile

class LogTest: XCTestCase {

    private let sdkVersion = PBMFunctions.sdkVersion()
    private let message = "Test Log"

    private var logToFile: LogToFileLock?

    override func setUp() {
        super.setUp()

        Log.logLevel = .debug
    }

    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testLogToFileViaLogInfo() {
        logToFile = .init()
        let logExpectation = expectation(description: "logExpectation")

        Log.info(self.message)
        logExpectation.fulfill()

        waitForExpectations(timeout: 1, handler: { _ in
            let log = Log.getLogFileAsString() ?? ""
            XCTAssertTrue(log.contains(self.message))
            XCTAssertTrue(log.contains(LogLevel.info.stringValue))
        })
    }
    
    func testGetLogFileAsString() {
        logToFile = .init()
        
        var log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.isEmpty)
        
        Log.writeToLogFile(message)
        
        log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log == message.appending("\n"))
    }
    
    func testClearLogFile() {
        
        logToFile = .init()
        Log.writeToLogFile(message)
        
        
        guard let log = Log.getLogFileAsString() else {
            XCTFail()
            return
        }
        XCTAssertTrue(!log.isEmpty)
        
        Log.clearLogFile()
        
        
        guard let log = Log.getLogFileAsString() else {
            XCTFail()
            return
        }
        XCTAssertTrue(log.isEmpty)
        
    }
    
    func testAllKinds() {
        // Test: default params

        logToFile = .init()
        
        Log.error(message)
        checkLogAndClean(level: .error)
        
        Log.info(message)
        checkLogAndClean(level: .info)
        
        Log.debug(message)
        checkLogAndClean(level: .debug)
        
        Log.verbose(message)
        checkLogAndClean(level: .verbose)
        
        Log.warn(message)
        checkLogAndClean(level: .warn)
        
        Log.severe(message)
        checkLogAndClean(level: .severe)
    }
    
    func testWhereAmI() {
        logToFile = .init()
        
        Log.whereAmI()
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(LogLevel.info.stringValue))
    }
    
    func testLogLevel() {
        logToFile = .init()

        // Check default
        let initialLogLevel: LogLevel = .debug
        XCTAssertEqual(Log.logLevel, initialLogLevel)

        Log.warn(message)
        checkLogAndClean(level: .warn)

        // Test: warning message should be skipped
        Log.logLevel = .error

        Log.warn(message)
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertEqual(log, "")

        // Rreturn to the initial state
        Log.logLevel = initialLogLevel

        Log.warn(message)
        checkLogAndClean(level: .warn)
    }
    
    // MARK: Internal Methods

    func checkLogAndClean(level: LogLevel, file: StaticString = #file, line: UInt = #line) {
        let log = Log.getLogFileAsString() ?? ""
        
        XCTAssert(log.contains(message), file: file, line: line)
        XCTAssert(log.contains(level.stringValue))
        
        logToFile = nil
        logToFile = .init()
    }
}
