/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

final class PrebidGAMVersionCheckerTest: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        super.tearDown()
        logToFile = nil
    }

    func testCheckDeprecatedGMAVersion_higherVersion() {
        let checker = PrebidGAMVersionChecker()
        
        let warningMessage = """
        The current version of Prebid SDK is not validated with the latest version of GMA SDK. Please update the Prebid SDK or post a ticket on the github.
        """
        logToFile = .init()
        
        checker.checkGMAVersionDeprecated("afma-sdk-i-v100.1.0")
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(warningMessage))
    }
    
    func testCheckDeprecatedGMAVersion_ok() {
        logToFile = .init()
        let checker = PrebidGAMVersionChecker()
        
        let latestTestedGMAVersion = checker.latestTestedGMAVersion
        let version = "\(latestTestedGMAVersion.0).\(latestTestedGMAVersion.1).\(latestTestedGMAVersion.2)"
        
        checker.checkGMAVersionDeprecated("afma-sdk-i-v\(version)")
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.isEmpty)
    }
    
    func testCheckDeprecatedGMAVersion_parseFailure() {
        logToFile = .init()
        let checker = PrebidGAMVersionChecker()
        
        let errorMessage = """
        Error occured during GMA SDK version parsing.
        """
        
        checker.checkGMAVersionDeprecated("ver.10")
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(errorMessage))
    }
    
    func testCheckGMAVersion_higherVersion() {
        let checker = PrebidGAMVersionChecker()
        
        let warningMessage = """
        The current version of Prebid SDK is not validated with the latest version of GMA SDK. Please update the Prebid SDK or post a ticket on the github.
        """
        logToFile = .init()
        
        checker.checkGMAVersion("100.1.0")
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(warningMessage))
    }
    
    func testCheckGMAVersion_ok() {
        logToFile = .init()
        let checker = PrebidGAMVersionChecker()
        
        let latestTestedGMAVersion = checker.latestTestedGMAVersion
        let version = "\(latestTestedGMAVersion.0).\(latestTestedGMAVersion.1).\(latestTestedGMAVersion.2)"
        
        checker.checkGMAVersion(version)
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.isEmpty)
    }
    
    func testCheckGMAVersion_parseFailure() {
        logToFile = .init()
        let checker = PrebidGAMVersionChecker()
        
        let errorMessage = """
        Error occured during GMA SDK version parsing.
        """
        
        checker.checkGMAVersion("v10")
        
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(errorMessage))
    }

}
