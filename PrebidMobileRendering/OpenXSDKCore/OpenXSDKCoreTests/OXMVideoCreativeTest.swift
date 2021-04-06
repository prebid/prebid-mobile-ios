

import Foundation
import UIKit
import XCTest
import AVFoundation
@testable import OpenXApolloSDK


class VideoCreativeDelegateTest: XCTestCase, OXMCreativeResolutionDelegate, OXMCreativeViewDelegate, OXMVideoViewDelegate {
   
    var videoCreative:OXMVideoCreative!
    let connection = UtilitiesForTesting.createConnectionForMockedTest()

    var expectationDownloadCompleted:XCTestExpectation!
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationVideoCreativeDidComplete:XCTestExpectation!
    var expectationDownloadFailed:XCTestExpectation!
    var expectationDidLeaveApp:XCTestExpectation!
    var expectationVideoViewCompletedDisplay:XCTestExpectation?
    var isVideoViewCompletedDisplay = false;
    
    private var logToFile: LogToFileLock?

    override func setUp() {
        self.continueAfterFailure = true
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        MockServer.singleton().reset()
        logToFile = nil
        super.tearDown()
    }
    
    func testInit() {
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        XCTAssertNotNil(self.videoCreative)
        XCTAssertNotNil(self.videoCreative.videoView)
        XCTAssertNotNil(self.videoCreative.videoView.videoViewDelegate)
    }
    
    func testButtonTouchUpInsideBlock() {
        let vc = UIViewController()
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.viewControllerForPresentingModals = vc

        self.videoCreative.videoView.updateControls()
        
        let buttonDecorator = self.videoCreative.videoView.legalButtonDecorator
        XCTAssertNotNil(buttonDecorator)
        XCTAssertNotNil(buttonDecorator.buttonTouchUpInsideBlock)
        
        logToFile = .init()
        
        buttonDecorator.buttonTouchUpInsideBlock!()
        UtilitiesForTesting.checkLogContains("Attempted to pause a VideoView with no avPlayer")
    }
    
    func testCreativeDisplayabilityDelegate() {
        self.setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")

        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        
        //10 Seconds to download the video, plus about 7 seconds to play it.
        self.waitForExpectations(timeout: 20, handler:nil)
    }
    
    //As testCreativeDisplayabilityDelegate, but isInterstitial is set to true.
    //This causes the video to pre-load.
    func testCreativeDisplayabilityDelegatePreload() {
        self.setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")

        self.videoCreative.creativeModel!.adConfiguration!.isInterstitialAd = true

        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        
        self.waitForExpectations(timeout: 30, handler:nil)
    }
    
    func testDownloadFailed() {
        self.expectationDownloadFailed = self.expectation(description: "Expected downloadFailed to be called")
        self.expectationDidLeaveApp = self.expectation(description: "expectationDidLeaveApp")
        
        self.videoCreative = OXMVideoCreative(creativeModel:OXMCreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.videoViewFailedWithError(NSError(domain: "OpenXSDK", code: 123, userInfo: [:]))

        //Create model
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.videoFileURL = "http://get_video/small.mp4"
        
        //Create OXMVideoCreative and start
        self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
        
        let state = OXMModalState(view: OXMVideoView(), adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        self.videoCreative.modalManagerDidLeaveApp(state)
        
        waitForExpectations(timeout: 1)
    }
    
    func testClose() {
        
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 1.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        self.expectationVideoViewCompletedDisplay?.isInverted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + expectedStoppedDely, execute:{
            self.videoCreative.close()
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedStoppedDely + 0.5, handler:nil)
    }
    
    func testFinished() {
        
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 1.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? OXMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        self.expectationVideoCreativeDidComplete = expectation(description: "expectationVideoCreativeDidComplete")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + expectedStoppedDely, execute:{
            videoView.stop()
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedStoppedDely + 0.5, handler:nil)
    }
    
    func testShowAsInterstitial() {
        let expectation = self.expectation(description: "Should push Modal")
        
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.displayDurationInSeconds = 5

        self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        XCTAssertNotNil(self.videoCreative)
        
        let mockModalManager = MockModalManager()
        self.videoCreative.modalManager = mockModalManager
        mockModalManager.mock_pushModalClosure = { (_, _, _, _, completionHandler) in
            expectation.fulfill()
            completionHandler?()
        }
        
        let rootVC = UIViewController()
        let displayProperties = OXMInterstitialDisplayProperties()
        self.videoCreative.showAsInterstitial(fromRootViewController: rootVC, displayProperties: displayProperties)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSkipOffset() {
        let expectation = self.expectation(description: "Should push Modal")
        
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.displayDurationInSeconds = 5
        model.skipOffset = 10
        
        self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        XCTAssertNotNil(self.videoCreative)
        
        let mockModalManager = MockModalManager()
        self.videoCreative.modalManager = mockModalManager
        mockModalManager.mock_pushModalClosure = { (modalState, _, _, _, completionHandler) in
            expectation.fulfill()
            OXMAssertEq(model.skipOffset, modalState.displayProperties?.closeDelay as NSNumber?)
            completionHandler?()
        }
        
        let rootVC = UIViewController()
        let displayProperties = OXMInterstitialDisplayProperties()
        self.videoCreative.showAsInterstitial(fromRootViewController: rootVC, displayProperties: displayProperties)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMeassurementSession() {
        let mockViewController = MockViewController()
        let mockCreativeModel = MockOXMCreativeModel(adConfiguration: OXMAdConfiguration())
        
        let measurement = MockMeasurementWrapper()        
        
        // Session's expectations
        let expectationInitializeSession = self.expectation(description:"expectationInitializeSession")
        let expectationSessionStart = self.expectation(description:"expectationSessionStart")
        let expectationSessionStop = self.expectation(description:"expectationSessionStop")
        
        measurement.initializeSessionClosure = { session in
            guard let session = session as? MockMeasurementSession else {
                XCTFail()
                return
            }
            
            session.startClosure = {
                expectationSessionStart.fulfill()
            }
            
            session.stopClosure = {
                expectationSessionStop.fulfill()
            }
            
            expectationInitializeSession.fulfill()
        }
        
        let measurementExpectations = [
            expectationInitializeSession, // The session must be initialized after WebView had finished loading OM script
            expectationSessionStart,
            ]
        
        var transaction: OXMTransaction? = UtilitiesForTesting.createEmptyTransaction()
        transaction?.measurementWrapper = measurement
        
        self.videoCreative = OXMVideoCreative(
            creativeModel:mockCreativeModel,
            transaction:transaction!,
            videoData: Data()
        )
        
        XCTAssertNotNil(self.videoCreative)
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        
        self.videoCreative.display(withRootViewController:mockViewController)
        
        transaction?.creatives.add(self.videoCreative!)
        self.videoCreative.createOpenMeasurementSession();
        
        wait(for: measurementExpectations, timeout: 5, enforceOrder: true);
        
        self.videoCreative = nil
        transaction = nil
        
        wait(for: [expectationSessionStop], timeout: 1)
    }
    
    func testMeassurementSessionInBackground() {
        
        let expectation = self.expectation(description:"expectation background")
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        
        logToFile = .init()

        DispatchQueue.global(qos: .background).async {
            self.videoCreative.createOpenMeasurementSession();
            UtilitiesForTesting.checkLogContains("Open Measurement session can only be created on the main thread")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    //MARK: - OXMCreativeResolutionDelegate
    func creativeReady(_ creative:OXMAbstractCreative) {
        self.expectationDownloadCompleted.fulfill()
        self.videoCreative.display(withRootViewController: UIViewController())
    }
    
    func creativeFailed(_ error:Error) {
        self.expectationDownloadFailed.fulfill()
    }
    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative:OXMAbstractCreative) {}
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {
        self.expectationVideoCreativeDidComplete.fulfill()
    }
    func creativeWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative:OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative:OXMAbstractCreative) {}
    func creativeReady(toReimplant creative: OXMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative:OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative:OXMAbstractCreative) {}
    
    func creativeInterstitialDidLeaveApp(_ creative:OXMAbstractCreative) {
        expectationDidLeaveApp.fulfill()
    }
    
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
    
    // MARK: - OXMVideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {
        self.expectationVideoDidComplete.fulfill()
    }
    
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        isVideoViewCompletedDisplay = true
        self.expectationVideoViewCompletedDisplay?.fulfill()
    }
    
    func videoWasClicked() {}
    
    // MARK: - Helper Methods
    private func setupVideoCreative(videoFileURL:String = "http://get_video/small.mp4", localVideoFileName:String = "small.mp4") {
        let rule = MockServerRule(urlNeedle: videoFileURL, mimeType: MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: localVideoFileName)
        MockServer.singleton().resetRules([rule])
        
        //Create model
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.videoFileURL = videoFileURL
        
        //Create and start creative
        self.videoCreative = OXMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
    }
}
