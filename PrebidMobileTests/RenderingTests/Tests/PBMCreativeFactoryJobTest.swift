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

@_spi(PBMInternal) @testable import PrebidMobile

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
        let model = CreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "PBMCreativeFactoryJob: Could not initialize VideoCreative without videoFileURL")
                expectationFailure.fulfill()
            }
        }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = .running
        job.attemptVASTCreative()
        
        waitForExpectations(timeout: 5)
    }
    
    func testTimerExpiring() {
        let expectationFailure = self.expectation(description: "Expected creative factory job timer expire")
        
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true)
        let model = transaction.creativeModels[0]
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "SDK internal error: PBMCreativeFactoryJob: Failed to complete in specified time interval")
                expectationFailure.fulfill()
            }
        }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.start(timeInterval: 0.01)
        
        waitForExpectations(timeout: 5)
    }
    
    func testStartWithWrongState() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = CreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in
            if error != nil {
                XCTAssertEqual(error?.localizedDescription ?? "", "SDK internal error: PBMCreativeFactoryJob: Tried to start PBMCreativeFactory twice")
                expectationFailure.fulfill()
            }
        }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = .running
        job.start()
        
        waitForExpectations(timeout: 5)
    }
    
    func testCreativeDownloadDelegateSuccess() {
        let expectationSuccess = self.expectation(description: "Expected creative factory job success callback")
        
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = CreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in
            if job.state == .success && error == nil {
                expectationSuccess.fulfill()
            }
        }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = .running
        
        job.succeed(with: UtilitiesForTesting.createHTMLCreative())
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(job.state, .success)
        })
    }
    
    func testCreativeDownloadDelegateFailure() {
        let expectationFailure = self.expectation(description: "Expected creative factory job failure callback")
        
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let model = CreativeModel(adConfiguration: AdConfiguration())
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in
            if (error != nil) {
                expectationFailure.fulfill()
            }
        }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
        job.state = .running
        job.fail(with: PBMError.error(description: ""))
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(job.state, .error)
        })
    }
    
    func testGetTimeInterval_default() {
        // CTF values are default
        let connection = PrebidServerConnection()
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let adConfig = AdConfiguration()
        let model = CreativeModel(adConfiguration: adConfig)
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
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
        let model = CreativeModel(adConfiguration: adConfig)
        
        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in }
        
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)
        
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
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        sdkConfiguration.prebidServerAccountId = Prebid.devintAccountID
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 300, height: 250))
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.makeValidResponseWithCTF(bidPrice: 0.5, ctfBanner: creativeFactoryTimeout, ctfPreRender: creativeFactoryTimeoutPreRenderContent))
        }])
        
        let requester = Factory.createBidRequester(connection: connection,
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
        let model = CreativeModel(adConfiguration: adConfig)

        let finishedCallback = { (job: CreativeFactoryJob, error: Error?) in }

        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection, finishedCallback: finishedCallback)

        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeout)
        
        // video
        adConfig.winningBidAdFormat = .video
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeoutPreRenderContent)
        
        // interstitial
        adConfig.winningBidAdFormat = .banner
        adConfig.isInterstitialAd = true
        XCTAssertEqual(job.getTimeInterval(), creativeFactoryTimeoutPreRenderContent)
    }
    
    // MARK: - VAST Error URIs
    
    // One URI with the plain macro, one with the percent-encoded form.
    private let vastErrorURIs = ["https://example.com/error?code=[ERRORCODE]",
                                 "https://example.com/wrapper-error/%5BERRORCODE%5D"]
    
    private func expectedErrorRequests(_ code: Int) -> [String] {
        ["https://example.com/error?code=\(code)", "https://example.com/wrapper-error/\(code)"]
    }
    
    // A creative model as `CreativeModelCollectionMakerVAST` makes it for the Linear creative.
    private func makeVideoModel(connection: PrebidServerConnectionProtocol) -> CreativeModel {
        let adConfiguration = AdConfiguration()
        adConfiguration.winningBidAdFormat = .video
        let model = CreativeModel(adConfiguration: adConfiguration)
        model.eventTracker = AdModelEventTracker(creativeModel: model, serverConnection: connection)
        model.videoFileURL = "https://example.com/video.mp4"
        model.trackingURLs[TrackingEvent.error.description] = vastErrorURIs
        return model
    }
    
    // Handlers for the two Error URIs. They record the requests and fulfill `expectation` twice.
    private func errorRequestHandlers(fulfilling expectation: XCTestExpectation,
                                      into requests: Box<[String]>) -> [MockServerConnection.FireAndForgetHandler] {
        expectation.expectedFulfillmentCount = 2
        let handler: MockServerConnection.FireAndForgetHandler = { url in
            requests.value.append(url)
            expectation.fulfill()
        }
        return [handler, handler]
    }
    
    func testVastErrorURIs_mediaFileDownloadFailed() {
        let errorRequested = expectation(description: "Error URIs requested")
        let jobFailed = expectation(description: "Job failed")
        let requests = Box<[String]>([])
        
        let connection = MockServerConnection(
            onFireAndForget: errorRequestHandlers(fulfilling: errorRequested, into: requests),
            onHead: [{ _, _, callback in
                let response = PrebidServerResponse()
                response.responseHeaders = ["Content-Length": "1024"]
                callback(response)
            }],
            onDownload: [{ _, callback in
                let response = PrebidServerResponse()
                response.error = PBMError.error(description: "The media file request failed")
                callback(response)
            }])
        
        let model = makeVideoModel(connection: connection)
        let job = CreativeFactoryJob(creativeModel: model,
                                     transaction: UtilitiesForTesting.createEmptyTransaction(),
                                     serverConnection: connection) { _, error in
            XCTAssertEqual(error?.localizedDescription, "The media file request failed")
            jobFailed.fulfill()
        }
        
        job.state = .running
        job.attemptVASTCreative()
        
        wait(for: [errorRequested, jobFailed], timeout: 5)
        XCTAssertEqual(requests.value, expectedErrorRequests(401))
    }
    
    // The path of a MediaFile that downloads but cannot be decoded: `VideoView` reports the failed player item.
    func testVastErrorURIs_playerFailed() {
        let errorRequested = expectation(description: "Error URIs requested")
        let jobFailed = expectation(description: "Job failed")
        let requests = Box<[String]>([])
        
        let connection = MockServerConnection(onFireAndForget: errorRequestHandlers(fulfilling: errorRequested, into: requests))
        let model = makeVideoModel(connection: connection)
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection) { _, error in
            XCTAssertNotNil(error)
            jobFailed.fulfill()
        }
        
        let videoCreative = VideoCreative(creativeModel: model, transaction: transaction, videoData: Data())
        videoCreative.creativeResolutionDelegate = job
        job.creative = videoCreative
        job.state = .running
        
        videoCreative.videoViewFailedWithError(PBMError.error(description: "Cannot Decode"))
        
        wait(for: [errorRequested, jobFailed], timeout: 5)
        XCTAssertEqual(requests.value, expectedErrorRequests(405))
    }
    
    func testVastErrorURIs_timeout() {
        let errorRequested = expectation(description: "Error URIs requested")
        let jobFailed = expectation(description: "Job failed")
        let requests = Box<[String]>([])
        
        // The media file request never completes.
        let connection = MockServerConnection(onFireAndForget: errorRequestHandlers(fulfilling: errorRequested, into: requests),
                                              onHead: [{ _, _, _ in }])
        let model = makeVideoModel(connection: connection)
        let job = CreativeFactoryJob(creativeModel: model,
                                     transaction: UtilitiesForTesting.createEmptyTransaction(),
                                     serverConnection: connection) { _, error in
            XCTAssertEqual(error?.localizedDescription, "SDK internal error: PBMCreativeFactoryJob: Failed to complete in specified time interval")
            jobFailed.fulfill()
        }
        
        job.start(timeInterval: 0.1)
        
        wait(for: [errorRequested, jobFailed], timeout: 5)
        XCTAssertEqual(requests.value, expectedErrorRequests(304))
    }
    
    // The URIs are requested for the failure the job reports, so once. A failure after the job has finished is not reported.
    func testVastErrorURIs_requestedOnlyForReportedFailure() {
        let errorRequested = expectation(description: "Error URIs requested")
        let jobFailed = expectation(description: "Job failed")
        let requestedAgain = expectation(description: "Error URIs requested again")
        requestedAgain.isInverted = true
        let requests = Box<[String]>([])
        
        let connection = MockServerConnection(
            onFireAndForget: errorRequestHandlers(fulfilling: errorRequested, into: requests) + [{ _ in requestedAgain.fulfill() }])
        let model = makeVideoModel(connection: connection)
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection) { _, _ in
            jobFailed.fulfill()
        }
        
        let videoCreative = VideoCreative(creativeModel: model, transaction: transaction, videoData: Data())
        videoCreative.creativeResolutionDelegate = job
        job.creative = videoCreative
        job.state = .running
        
        job.fail(with: PBMError.error(description: "First failure"), vastErrorCode: .mediaFileNotFound)
        videoCreative.videoViewFailedWithError(PBMError.error(description: "Second failure"))
        
        wait(for: [errorRequested, jobFailed], timeout: 5)
        wait(for: [requestedAgain], timeout: 0.5)
        XCTAssertEqual(requests.value, expectedErrorRequests(401))
    }
    
    func testVastErrorURIs_notRequestedAfterSuccess() {
        let jobSucceeded = expectation(description: "Job succeeded")
        let errorRequested = expectation(description: "Error URIs requested")
        errorRequested.isInverted = true
        
        let connection = MockServerConnection(onFireAndForget: [{ _ in errorRequested.fulfill() }])
        let model = makeVideoModel(connection: connection)
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        let job = CreativeFactoryJob(creativeModel: model, transaction: transaction, serverConnection: connection) { job, error in
            XCTAssertNil(error)
            XCTAssertEqual(job.state, .success)
            jobSucceeded.fulfill()
        }
        
        let videoCreative = VideoCreative(creativeModel: model, transaction: transaction, videoData: Data())
        videoCreative.creativeResolutionDelegate = job
        job.state = .running
        
        job.creativeReady(videoCreative)
        wait(for: [jobSucceeded], timeout: 5)
        
        videoCreative.videoViewFailedWithError(PBMError.error(description: "Late failure"))
        wait(for: [errorRequested], timeout: 0.5)
    }
}

// Lets the test read what a handler running on another queue recorded.
private final class Box<Value> {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}
