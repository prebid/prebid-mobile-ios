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

class PBMCreativeFactoryJobTest: XCTestCase {
    
    func testVastCreativeFail() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = ServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "PBMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL")
                expectationFailure.fulfill()
            }
        }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = PBMCreativeFactoryJobStateRunning
        job.attemptVASTCreative()
        
        waitForExpectations(timeout: 5)
    }
    
    func testTimerExpiring() {
        let expectationFailure = self.expectation(description: "Expected creative factory job timer expire")
        
        let connection = ServerConnection()
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true)
        let model = transaction.creativeModels[0]
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "SDK internal error: PBMCreativeFactoryJob: Failed to complete in specified time interval")
                expectationFailure.fulfill()
            }
        }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.start(withTimeInterval: 0.01)
        
        waitForExpectations(timeout: 5)
    }
    
    func testStartWithWrongState() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = ServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "SDK internal error: PBMCreativeFactoryJob: Tried to start PBMCreativeFactory twice")
                expectationFailure.fulfill()
            }
        }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = PBMCreativeFactoryJobStateRunning
        job.start()
        
        waitForExpectations(timeout: 5)
    }
    
    func testCreativeDownloadDelegateSuccess() {
        let expectationSuccess = self.expectation(description: "Expected creative factory job success callback")
        
        let connection = ServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in
            if job.state == PBMCreativeFactoryJobStateSuccess && error == nil {
                expectationSuccess.fulfill()
            }
        }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = PBMCreativeFactoryJobStateRunning
        
        job.success(with: UtilitiesForTesting.createHTMLCreative())
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(job.state, PBMCreativeFactoryJobStateSuccess)
        })
    }
    
    func testCreativeDownloadDelegateFailure() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = ServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in
            if (error != nil) {
                expectationFailure.fulfill()
            }
        }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = PBMCreativeFactoryJobStateRunning
        job.failWithError(PBMError.error(description: ""))
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(job.state, PBMCreativeFactoryJobStateError)
        })
    }
}
