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

class PBMCreativeFactoryTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        PrebidJSLibraryManager.shared.downloadLibraries()
    }
    
    func testNoCreativeModelsFactoryFail() {
        let expectation = self.expectation(description: "Expected creative factory failure callback")
        
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        
        let creativeFactory =
        PBMCreativeFactory(serverConnection: connection, transaction: transaction, finishedCallback: {
            creatives, error in
            if error != nil {
                expectation.fulfill()
            }
        }
        )
        
        creativeFactory.start()
        
        waitForExpectations(timeout: 5)
    }
    
    
    func testCreativeFactorySuccess() {
        let expectationSuccess = self.expectation(description: "Expected creative factory success callback")
        let expectationFail = self.expectation(description: "Creative Factory fails")
        expectationFail.isInverted = true
        
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
        
        let creativeFactory =
        PBMCreativeFactory(serverConnection: connection, transaction: transaction, finishedCallback: {
            creatives, error in
            if error != nil {
                expectationFail.fulfill()
            }
            if let _ = creatives?.first {
                expectationSuccess.fulfill()
            }
        })
        
        creativeFactory.start()
        
        waitForExpectations(timeout: 10)
    }
}
