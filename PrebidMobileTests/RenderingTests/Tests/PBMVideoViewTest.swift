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

class PBMVideoViewTest: XCTestCase, PBMCreativeResolutionDelegate, PBMCreativeViewDelegate, PBMVideoViewDelegate {
    
    var vc: UIViewController?
    let connection = UtilitiesForTesting.createConnectionForMockedTest()
    
    var videoCreative:PBMVideoCreative!
    var expectationDownloadCompleted:XCTestExpectation?
    var expectationCreativeReady:XCTestExpectation?
    var expectationCreativeDidComplete:XCTestExpectation?
    var expectationCreativeWasClicked:XCTestExpectation?
    var expectationClickthroughBrowserClosed:XCTestExpectation?
    var expectationVideoViewCompletedDisplay:XCTestExpectation?
    
    var isVideoViewCompletedDisplay = false;
    
    // MARK: - Setup
    
    override func setUp() {
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        MockServer.shared.reset()
        self.videoCreative = nil
        self.expectationDownloadCompleted = nil
        self.expectationCreativeReady = nil
        self.expectationCreativeDidComplete = nil
        self.expectationCreativeWasClicked = nil
        self.expectationClickthroughBrowserClosed = nil
        self.expectationVideoViewCompletedDisplay = nil
    }
    
    // MARK: - Tests
    
    func testLearnMoreButton() {
        self.setupVideoCreative()
        
        self.videoCreative.creativeModel!.clickThroughURL = "www.openx.com"
        
        self.vc = UIViewController()
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 15, handler:nil)
        
        //Wait half a second, then force a click
        self.vc?.view.addSubview(videoCreative.view!)
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        self.expectationCreativeWasClicked = expectation(description: "expectationCreativeWasClicked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            
            guard let strongSelf = self else {
                XCTFail("Self deallocated")
                return
            }
            
            guard let videoView = strongSelf.videoCreative.view as? PBMVideoView else {
                XCTFail("Couldn't get Video View")
                return
            }
            
            videoView.btnLearnMoreClick()
        })
        
        
        self.waitForExpectations(timeout: 15, handler:nil)
    }
    
    func testVastDuration() {
        // Expected duration of video medium.mp4 is 60 sec
        let expectedVastDuration = 10.0
        setupVideoCreative(videoFileURL: "http://get_video/medium.mp4", localVideoFileName: "medium.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVastDuration as NSNumber // VAST Duration
        
        setupVideoDurationTest(expectedDuration: expectedVastDuration)
    }
    
    func testVideoDuration() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = 10 // VAST Duration
        
        setupVideoDurationTest(expectedDuration: expectedVideoDuration)
    }
    
    func testPauseVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        self.expectationVideoViewCompletedDisplay?.isInverted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:{
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
            videoView.pause()
        })
        
        waitForExpectations(timeout: 8, handler:nil)
    }
    
    func testUnpauseVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedPausedTime = 3.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        
        // Pause video
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:{
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
            videoView.pause()
            
            // Unpause video
            DispatchQueue.main.asyncAfter(deadline: .now() + expectedPausedTime, execute:{
                XCTAssertFalse(self.isVideoViewCompletedDisplay)
                videoView.resume()
            })
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedPausedTime + 0.5, handler:nil)
    }
    
    func testStopVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 3.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + expectedStoppedDely, execute:{
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
            videoView.stop()
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedStoppedDely + 0.5, handler:nil)
    }
    
    func testStopOnCloseButton() {
        
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 1.0
        let event = PBMTrackingEvent.closeLinear
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        self.expectationVideoViewCompletedDisplay?.isInverted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + expectedStoppedDely, execute:{
            videoView.stop(onCloseButton: event)
            XCTAssertFalse(self.isVideoViewCompletedDisplay)
        })
        
        waitForExpectations(timeout: expectedVideoDuration + expectedStoppedDely + 0.5, handler:nil)
    }
    
    func testIsMuted() {
        let adConfig = AdConfiguration()
        XCTAssertTrue(adConfig.videoControlsConfig.isMuted == false)
        
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel!.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        XCTAssertTrue(self.videoCreative.videoView.avPlayer.isMuted == false)
    }
    
    func testSetupSkipButton() {
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        guard let videoView = self.videoCreative.videoView else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(videoView.skipButtonDecorator.buttonArea, 0.1)
        XCTAssertEqual(videoView.skipButtonDecorator.buttonPosition, .topLeft)
        XCTAssertEqual(videoView.skipButtonDecorator.button.isHidden, true)
        XCTAssertEqual(videoView.skipButtonDecorator.button.image(for: .normal)?.pngData(), PrebidImagesRepository.skipButton.base64DecodedImage?.pngData())
    }
    
    func testHandleSkipDelay() {
        let expectation = expectation(description: "Test Skip Button Active")
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        
        guard let videoView = self.videoCreative.videoView else {
            XCTFail()
            return
        }
        
        self.videoCreative.creativeModel = PBMCreativeModel()
        self.videoCreative.creativeModel?.adConfiguration = AdConfiguration()
        self.videoCreative.creativeModel?.adConfiguration?.videoControlsConfig.skipDelay = 1
        self.videoCreative.creativeModel?.displayDurationInSeconds = 10
        self.videoCreative.creativeModel?.hasCompanionAd = true
        
        videoView.handleSkipDelay(0, videoDuration: 10)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if !videoView.skipButtonDecorator.button.isHidden {
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testCalculateProgressBarDuration_whenNotRewardedAndHasCompanionAd() {
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        mockVideoView.mockRequiredVideoDuration = 10
        
        let expectedDuration = mockVideoView.requiredVideoDuration()
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenPlaybackEventIsStart() {
        let postRewardTime: NSNumber = 5
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, playbackevent: "start")
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        mockVideoView.mockRequiredVideoDuration = 10
        
        let expectedDuration = postRewardTime.doubleValue
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenPlaybackEventIsFirstQuartile() {
        let postRewardTime: NSNumber = 5
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, playbackevent: "firstquartile")
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = 0.25 * mockVideoView.requiredVideoDuration() + postRewardTime.doubleValue
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenPlaybackEventIsMidpoint() {
        let postRewardTime: NSNumber = 5
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, playbackevent: "midpoint")
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = 0.5 * mockVideoView.requiredVideoDuration() + postRewardTime.doubleValue
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenPlaybackEventIsThirdQuartile() {
        let postRewardTime: NSNumber = 5
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, playbackevent: "thirdquartile")
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = 0.5 * mockVideoView.requiredVideoDuration() + postRewardTime.doubleValue
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenPlaybackEventIsComplete() {
        let postRewardTime: NSNumber = 5
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, playbackevent: "complete")
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = mockVideoView.requiredVideoDuration()
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenCompletionCriteriaIsTime() {
        let rewardTime: NSNumber = 2
        let postRewardTime: NSNumber = 5
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, time: rewardTime)
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = rewardTime.doubleValue + postRewardTime.doubleValue
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_whenCompletionCriteriaIsTimeAndExceedsVideoDuration() {
        let rewardTime: NSNumber = 100
        let postRewardTime: NSNumber = 5
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = createRewardedConfig(postRewardTime: postRewardTime, time: rewardTime)
        
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = mockVideoView.requiredVideoDuration()
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    func testCalculateProgressBarDuration_default() {
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: PBMORTBRewardedConfiguration())
        
        let model = PBMCreativeModel(adConfiguration: adConfiguration)
        
        self.videoCreative = PBMVideoCreative(
            creativeModel:model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            videoData:Data()
        )
        
        let mockVideoView = MockVideoView(creative: self.videoCreative)
        
        let expectedDuration = mockVideoView.requiredVideoDuration()
        let result = mockVideoView.calculateProgressBarDuration().doubleValue
        
        XCTAssertEqual(result, expectedDuration)
    }
    
    
    // MARK: - PBMCreativeDownloadDelegate
    
    func creativeReady(_ creative: PBMAbstractCreative) {
        self.expectationCreativeReady?.fulfill()
    }
    
    func creativeFailed(_ error:Error) {}
    
    // MARK: - PBMVideoViewDelegate
    
    
    func videoViewFailedWithError(_ error: Error) {}
    func videoViewReadyToDisplay() {}
    
    func videoViewCompletedDisplay() {
        isVideoViewCompletedDisplay = true
        self.expectationVideoViewCompletedDisplay?.fulfill()
    }
    
    func videoWasClicked() {}
    
    func videoClickthroughBrowserClosed() {
        self.expectationClickthroughBrowserClosed?.fulfill()
    }
    
    func trackEvent(_ trackingEvent: PBMTrackingEvent) {}
    
    // MARK: - CreativeViewDelegate
    
    func creativeDidComplete(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidComplete?.fulfill()
    }
    
    func creativeWasClicked(_ creative: PBMAbstractCreative) {
        self.expectationCreativeWasClicked?.fulfill()
    }
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: PBMAbstractCreative) {}
    func creativeReady(toReimplant creative: PBMAbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: PBMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: PBMAbstractCreative) {}
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {}
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative) {}
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
    
    // MARK: - Helper Methods
    
    private func setupVideoCreative(videoFileURL:String = "http://get_video/small.mp4", localVideoFileName:String = "small.mp4", adConfiguration: AdConfiguration = AdConfiguration()) {
        let rule = MockServerRule(urlNeedle: videoFileURL, mimeType: MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: localVideoFileName)
        MockServer.shared.resetRules([rule])
        
        //Create model
        let model = PBMCreativeModel(adConfiguration:adConfiguration)
        model.videoFileURL = videoFileURL
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        let url = URL(string: model.videoFileURL!)
        let downloader = PBMDownloadDataHelper(serverConnection: connection)
        downloader.downloadData(for: url, maxSize: PBMVideoCreative.maxSizeForPreRenderContent, completionClosure: { (data:Data?, error:Error?) in
            
            DispatchQueue.main.async {
                //Create and start creative
                self.videoCreative = PBMVideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: data!)
                self.videoCreative.creativeResolutionDelegate = self
                self.videoCreative.creativeViewDelegate = self
                
                self.expectationDownloadCompleted?.fulfill()
            }
        })
        
        wait(for: [self.expectationDownloadCompleted!], timeout: 15)
    }
    
    private func setupVideoDurationTest(expectedDuration: Double) {
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 15, handler:nil)
        
        self.videoCreative?.display(withRootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View")
            return
        }
        
        videoView.videoViewDelegate = self
        
        self.expectationVideoViewCompletedDisplay = expectation(description: "expectationVideoViewCompletedDisplay")
        
        waitForExpectations(timeout: expectedDuration + 5, handler:nil)
        
        XCTAssertTrue(self.isVideoViewCompletedDisplay)
    }
    
    private func createRewardedConfig(postRewardTime: NSNumber = 0, playbackevent: String? = nil,
                                      time: NSNumber? = nil) -> RewardedConfig {
        let ortbRewarded = PBMORTBRewardedConfiguration()
        ortbRewarded.completion = PBMORTBRewardedCompletion()
        ortbRewarded.completion?.video = PBMORTBRewardedCompletionVideo()
        ortbRewarded.completion?.video?.playbackevent = playbackevent
        ortbRewarded.completion?.video?.time = time
        ortbRewarded.close = PBMORTBRewardedClose()
        ortbRewarded.close?.postrewardtime = postRewardTime
        
        return RewardedConfig(ortbRewarded: ortbRewarded)
    }
}
