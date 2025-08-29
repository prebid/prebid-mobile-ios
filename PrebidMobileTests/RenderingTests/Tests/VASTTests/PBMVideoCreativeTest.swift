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

import UIKit
import XCTest
import AVFoundation

@testable @_spi(PBMInternal) import PrebidMobile

class VideoCreativeDelegateTest: XCTestCase, CreativeResolutionDelegate, CreativeViewDelegate, PBMVideoViewDelegate {
   
    var videoCreative:PBMVideoCreative!
    let connection = UtilitiesForTesting.createConnectionForMockedTest()

    var expectationDownloadCompleted:XCTestExpectation!
    var expectationVideoDidComplete:XCTestExpectation!
    var expectationVideoCreativeDidComplete:XCTestExpectation!
    var expectationDownloadFailed:XCTestExpectation!
    var expectationDidLeaveApp:XCTestExpectation!
    var expectationVideoViewCompletedDisplay:XCTestExpectation?
    var expectationCreativeDidSendRewardedEvent:XCTestExpectation?
    var isVideoViewCompletedDisplay = false;
    
    var expectationVideoMute: XCTestExpectation?
    var expectationVideoUnmute: XCTestExpectation?
    var expectationVideoPause: XCTestExpectation?
    var expectationVideoResume: XCTestExpectation?
    
    private var logToFile: LogToFileLock?

    override func setUp() {
        self.continueAfterFailure = true
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        logToFile = nil
        super.tearDown()
    }
    
    func testInit() {
        let model = CreativeModel(adConfiguration:AdConfiguration())
        self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        XCTAssertNotNil(self.videoCreative)
        XCTAssertNotNil(self.videoCreative.videoView)
        XCTAssertNotNil(self.videoCreative.videoView.videoViewDelegate)
    }
    /*
    func testButtonTouchUpInsideBlock() {
        let vc = UIViewController()
        let model = CreativeModel(adConfiguration:AdConfiguration())
        self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.viewControllerForPresentingModals = vc

        self.videoCreative.videoView.updateControls()
        
        let buttonDecorator = self.videoCreative.videoView.legalButtonDecorator
        XCTAssertNotNil(buttonDecorator)
        XCTAssertNotNil(buttonDecorator.buttonTouchUpInsideBlock)
        
        logToFile = .init()
        
        buttonDecorator.buttonTouchUpInsideBlock!()
        UtilitiesForTesting.checkLogContains("Attempted to pause a VideoView with no avPlayer")
    }
    */
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

        self.videoCreative.creativeModel.adConfiguration!.isInterstitialAd = true

        DispatchQueue.main.async {
            self.videoCreative.setupView()
        }
        
        self.waitForExpectations(timeout: 30, handler:nil)
    }
    
    func testDownloadFailed() {
        self.expectationDownloadFailed = self.expectation(description: "Expected downloadFailed to be called")
        self.expectationDidLeaveApp = self.expectation(description: "expectationDidLeaveApp")
        
        self.videoCreative = PBMVideoCreative(creativeModel:CreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.videoViewFailedWithError(NSError(domain: "PrebidMobile", code: 123, userInfo: [:]))

        //Create model
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.videoFileURL = "http://get_video/small.mp4"
        
        //Create PBMVideoCreative and start
        self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
        
        let state = Factory.createModalState(view: PBMVideoView(),
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties())
        self.videoCreative.modalManagerDidLeaveApp(state)
        
        waitForExpectations(timeout: 1)
    }
    
    func testClose() {
        
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 1.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
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
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
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
        
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.displayDurationInSeconds = 5

        self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        XCTAssertNotNil(self.videoCreative)
        
        let mockModalManager = MockModalManager()
        self.videoCreative.modalManager = mockModalManager
        mockModalManager.mock_pushModalClosure = { (_, _, _, _, completionHandler) in
            expectation.fulfill()
            completionHandler?()
        }
        
        let rootVC = UIViewController()
        let displayProperties = InterstitialDisplayProperties()
        self.videoCreative.showAsInterstitial(fromRootViewController: rootVC, displayProperties: displayProperties)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSkipOffset() {
        let expectation = self.expectation(description: "Should push Modal")
        
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.displayDurationInSeconds = 10
        model.skipOffset = 10
        
        self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        
        XCTAssertNotNil(self.videoCreative)
        
        let mockModalManager = MockModalManager()
        self.videoCreative.modalManager = mockModalManager
        self.videoCreative.creativeModel.hasCompanionAd = false
        self.videoCreative.creativeModel.adConfiguration?.isRewarded = false
        self.videoCreative.creativeModel.adConfiguration?.videoControlsConfig.skipDelay = 1000
        mockModalManager.mock_pushModalClosure = { (modalState, _, _, _, completionHandler) in
            expectation.fulfill()
            PBMAssertEq(model.skipOffset, modalState.displayProperties?.closeDelay as NSNumber?)
            completionHandler?()
        }
        
        let rootVC = UIViewController()
        let displayProperties = InterstitialDisplayProperties()
        self.videoCreative.showAsInterstitial(fromRootViewController: rootVC, displayProperties: displayProperties)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testMeassurementSession() {
        let mockViewController = MockViewController()
        let mockCreativeModel = MockPBMCreativeModel(adConfiguration: AdConfiguration())
        
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
        
        var transaction: Transaction? = UtilitiesForTesting.createEmptyTransaction()
        transaction?.measurementWrapper = measurement
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:mockCreativeModel,
            transaction:transaction!,
            videoData: Data()
        )
        
        XCTAssertNotNil(self.videoCreative)
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        
        self.videoCreative.display(rootViewController:mockViewController)
        
        transaction?.creatives.append(self.videoCreative!)
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
    
    func testRewardEvent() {
        let time: NSNumber = 5
        expectationCreativeDidSendRewardedEvent = expectation(description: "Reward event - creativeDidSendRewardedEvent called")
        
        let ortbRewarded = ORTBRewardedConfiguration()
        ortbRewarded.completion = ORTBRewardedCompletion()
        ortbRewarded.completion?.video = ORTBRewardedCompletionVideo()
        ortbRewarded.completion?.video?.time = time
        
        let adConfiguration = AdConfiguration()
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
        adConfiguration.isRewarded = true
        
        let creativeModel = CreativeModel(adConfiguration: adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:creativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
        
        self.videoCreative.videoViewCurrentPlayingTime(time)
        
        waitForExpectations(timeout: 1)
        
        // If video without endcard - we should show learn more button when reward completion is fired
        XCTAssertTrue(videoCreative.videoView.showLearnMore)
    }
    
    func testPostRewardEvent() {
        let rewardTime: NSNumber = 5
        let postRewardTime: NSNumber = 2
        expectationCreativeDidSendRewardedEvent = expectation(description: "Reward event - creativeDidSendRewardedEvent called")
        
        let ortbRewarded = ORTBRewardedConfiguration()
        ortbRewarded.completion = ORTBRewardedCompletion()
        ortbRewarded.completion?.video = ORTBRewardedCompletionVideo()
        ortbRewarded.completion?.video?.time = rewardTime
        ortbRewarded.close = ORTBRewardedClose()
        ortbRewarded.close?.postrewardtime = postRewardTime
        
        let adConfiguration = AdConfiguration()
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
        adConfiguration.isRewarded = true
        
        let creativeModel = CreativeModel(adConfiguration: adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:creativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
        
        self.videoCreative.videoViewCurrentPlayingTime(rewardTime)
        self.videoCreative.videoViewCurrentPlayingTime(postRewardTime)
        
        XCTAssertTrue(videoCreative.creativeModel.userPostRewardEventSent)
        
        waitForExpectations(timeout: 1)
    }
    
    func testVideoPlaybackEvents() {
        expectationVideoMute = expectation(description: "Should mute video")
        expectationVideoUnmute = expectation(description: "Should unmute video")
        expectationVideoPause = expectation(description: "Should pause video")
        expectationVideoResume = expectation(description: "Should resume video")
        
        let model = CreativeModel(adConfiguration: AdConfiguration())
        self.videoCreative = PBMVideoCreative(creativeModel: model,
                                              transaction: UtilitiesForTesting.createEmptyTransaction(),
                                              videoData: Data())
        
        videoCreative.creativeViewDelegate = self
        videoCreative.videoView.avPlayer = AVPlayer()
                
        XCTAssertNotNil(videoCreative)
        XCTAssertNotNil(videoCreative.videoView)
        
        videoCreative.mute()
        videoCreative.pause()
        wait(for: [expectationVideoMute!, expectationVideoPause!], timeout: 0.1)

        videoCreative.resume()
        videoCreative.unmute()
        wait(for: [expectationVideoResume!, expectationVideoUnmute!], timeout: 0.1)
    }

    
    // MARK: - PBMCreativeResolutionDelegate
    func creativeReady(_ creative: AbstractCreative) {
        self.expectationDownloadCompleted.fulfill()
        self.videoCreative.display(rootViewController: UIViewController())
    }
    
    func creativeFailed(_ error:Error) {
        self.expectationDownloadFailed.fulfill()
    }
    
    //MARK: - CreativeViewDelegate
    func creativeDidComplete(_ creative: AbstractCreative) {}
    func videoCreativeDidComplete(_ creative: AbstractCreative) {
        self.expectationVideoCreativeDidComplete.fulfill()
    }
    func creativeWasClicked(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {
        expectationDidLeaveApp.fulfill()
    }
    
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    
    // MARK: - PBMVideoViewDelegate
    
    func videoViewFailedWithError(_ error: Error) {
        self.expectationVideoDidComplete.fulfill()
    }
    
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func videoViewReadyToDisplay() {}
    
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {
        expectationCreativeDidSendRewardedEvent?.fulfill()
    }
    
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
    
    func videoViewCompletedDisplay() {
        isVideoViewCompletedDisplay = true
        self.expectationVideoViewCompletedDisplay?.fulfill()
    }
    
    func videoWasClicked() {}
    
    func videoDidPause(_ creative: any AbstractCreative) {
        expectationVideoPause?.fulfill()
    }
    
    func videoDidResume(_ creative: any AbstractCreative) {
        expectationVideoResume?.fulfill()
    }
    
    func videoWasMuted(_ creative: any AbstractCreative) {
        expectationVideoMute?.fulfill()
    }
    
    func videoWasUnmuted(_ creative: any AbstractCreative) {
        expectationVideoUnmute?.fulfill()
    }
    
    // MARK: - Helper Methods
    private func setupVideoCreative(videoFileURL:String = "http://get_video/small.mp4", localVideoFileName:String = "small.mp4") {
        let rule = MockServerRule(urlNeedle: videoFileURL, mimeType: MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: localVideoFileName)
        MockServer.shared.resetRules([rule])
        
        //Create model
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.videoFileURL = videoFileURL
        
        //Create and start creative
        self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: Data())
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
    }
}
