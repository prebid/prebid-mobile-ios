//
//  OXMCreativeFactoryJobTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMCreativeFactoryJobTest: XCTestCase {
    
    func testVastCreativeFail() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        
        let finishedCallback = { (job: OXMCreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "OXMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL")
                expectationFailure.fulfill()
            }
        }
        
        let job = OXMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = OXMCreativeFactoryJobStateRunning
        job.attemptVASTCreative()
        
        waitForExpectations(timeout: 5)
    }
    
    func testTimerExpiring() {
        let expectationFailure = self.expectation(description: "Expected creative factory job timer expire")
        
        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true)
        let model = transaction.creativeModels[0]
        
        let finishedCallback = { (job: OXMCreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "SDK internal error: OXMCreativeFactoryJob: Failed to complete in specified time interval")
                expectationFailure.fulfill()
            }
        }
        
        let job = OXMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.start(withTimeInterval: 0.01)
        
        waitForExpectations(timeout: 5)
    }
    
    func testStartWithWrongState() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        
        let finishedCallback = { (job: OXMCreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "SDK internal error: OXMCreativeFactoryJob: Tried to start OXMCreativeFactory twice")
                expectationFailure.fulfill()
            }
        }
        
        let job = OXMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = OXMCreativeFactoryJobStateRunning
        job.start()
        
        waitForExpectations(timeout: 5)
    }
    
    func testCreativeDownloadDelegateSuccess() {
        let expectationSuccess = self.expectation(description: "Expected creative factory job success callback")
        
        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        
        let finishedCallback = { (job: OXMCreativeFactoryJob, error: Error?) in
            if job.state == OXMCreativeFactoryJobStateSuccess && error == nil {
                expectationSuccess.fulfill()
            }
        }
        
        let job = OXMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = OXMCreativeFactoryJobStateRunning
        
        job.success(with: UtilitiesForTesting.createHTMLCreative())
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(job.state, OXMCreativeFactoryJobStateSuccess)
        })
    }
    
    func testCreativeDownloadDelegateFailure() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = OXMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        
        let finishedCallback = { (job: OXMCreativeFactoryJob, error: Error?) in
            if (error != nil) {
                expectationFailure.fulfill()
            }
        }
        
        let job = OXMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = OXMCreativeFactoryJobStateRunning
        job.failWithError(OXMError.error(description: ""))
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(job.state, OXMCreativeFactoryJobStateError)
        })
    }
}
