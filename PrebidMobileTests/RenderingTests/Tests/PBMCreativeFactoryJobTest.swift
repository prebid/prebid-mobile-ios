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
    
    private var sdkConfiguration: Prebid!
    private let targeting = Targeting.shared
    
    override func setUp() {
        super.setUp()
        sdkConfiguration = Prebid.mock
    }
    
    override func tearDown() {
        sdkConfiguration = nil
        Prebid.reset()
        super.tearDown()
    }
    
    func testVastCreativeFail() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = PrebidServerConnection()
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
        
        let connection = PrebidServerConnection()
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
        
        let connection = PrebidServerConnection()
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
        
        let connection = PrebidServerConnection()
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
        
        let connection = PrebidServerConnection()
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
    
    func testGetTimeInterval_default() {
        // CTF values are default
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let adConfig = AdConfiguration()
        let model = PBMCreativeModel(adConfiguration: adConfig)
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        // display banner
        XCTAssertEqual(job.getTimeInterval(), 6.0)
        
        // video
        adConfig.winningBidAdFormat = .video
        XCTAssertEqual(job.getTimeInterval(), 30.0)
        
        // interstitial
        adConfig.winningBidAdFormat = .banner
        adConfig.isInterstitialAd = true
        XCTAssertEqual(job.getTimeInterval(), 30.0)
    }
    
    func testTimeoutInterval_apiProvided() {
        let creativeFactoryTimeout = 11.1
        let creativeFactoryTimeoutPreRenderContent = 22.2
        
        // CTF is provided via API
        Prebid.shared.creativeFactoryTimeout = creativeFactoryTimeout
        Prebid.shared.creativeFactoryTimeoutPreRenderContent = creativeFactoryTimeoutPreRenderContent
        
        // display banner
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let adConfig = AdConfiguration()
        let model = PBMCreativeModel(adConfiguration: adConfig)
        
        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in }
        
        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeout)
        
        // video
        adConfig.winningBidAdFormat = .video
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeoutPreRenderContent)
        
        // interstitial
        adConfig.isInterstitialAd = true
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeoutPreRenderContent)
    }
    
    func testGetTimeInterval_serverSide() {
        let creativeFactoryTimeout = 11.1
        let creativeFactoryTimeoutPreRenderContent = 22.2
        
        // CTF values are provided by PBS
        try! sdkConfiguration.setCustomPrebidServer(url: Prebid.devintServerURL)
        sdkConfiguration.prebidServerAccountId = Prebid.devintAccountID
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(PBMBidResponseTransformer.makeValidResponseWithCTF(bidPrice: 0.5, ctfBanner: creativeFactoryTimeout, ctfPreRender: creativeFactoryTimeoutPreRenderContent))
        }])
        
        let requester = PBMBidRequester(connection: connection,
                                        sdkConfiguration: sdkConfiguration,
                                        targeting: targeting,
                                        adUnitConfiguration: adUnitConfig)
        
        let exp = expectation(description: "exp")
        requester.requestBids { (bidResponse, error) in
            exp.fulfill()
            if let error = error {
                XCTFail(error.localizedDescription)
                return
            }
            XCTAssertNotNil(bidResponse)
        }
        waitForExpectations(timeout: 5)
        
        // banner display
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let adConfig = AdConfiguration()
        let model = PBMCreativeModel(adConfiguration: adConfig)

        let finishedCallback = { (job: PBMCreativeFactoryJob, error: Error?) in }

        let job = PBMCreativeFactoryJob(from: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)

        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeout)
        
        // video
        adConfig.winningBidAdFormat = .video
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeoutPreRenderContent)
        
        // interstitial
        adConfig.winningBidAdFormat = .banner
        adConfig.isInterstitialAd = true
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeoutPreRenderContent)
    }
}
