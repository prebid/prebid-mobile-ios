//
//  PBMCreativeFactoryJobTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class PBMCreativeFactoryJobTest: XCTestCase {
    
    func testVastCreativeFail() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = PBMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: PBMAdConfiguration())
        
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
        
        let connection = PBMServerConnection()
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
        
        let connection = PBMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: PBMAdConfiguration())
        
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
        
        let connection = PBMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: PBMAdConfiguration())
        
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
        
        let connection = PBMServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = PBMCreativeModel(adConfiguration: PBMAdConfiguration())
        
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
