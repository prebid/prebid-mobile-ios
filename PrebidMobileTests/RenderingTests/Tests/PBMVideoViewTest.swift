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

class PBMVideoViewTest: XCTestCase, CreativeResolutionDelegate, CreativeViewDelegate, VideoViewDelegate {
    
    var vc: UIViewController?
    let connection = UtilitiesForTesting.createConnectionForMockedTest()
    
    var videoCreative:VideoCreative!
    var expectationDownloadCompleted:XCTestExpectation?
    var expectationCreativeReady:XCTestExpectation?
    var expectationCreativeFailed:XCTestExpectation?
    var expectationCreativeDidComplete:XCTestExpectation?
    var expectationCreativeWasClicked:XCTestExpectation?
    var expectationClickthroughBrowserClosed:XCTestExpectation?
    var expectationVideoViewCompletedDisplay:XCTestExpectation?
    
    var isVideoViewCompletedDisplay = false;
    
    // MARK: - Setup
    
    override func setUp() {
        MockServer.shared.reset()
        Prebid.forcedIsViewable = true
    }

    override func tearDown() {
        MockServer.shared.reset()
        Prebid.forcedIsViewable = false
        self.videoCreative = nil
        self.expectationDownloadCompleted = nil
        self.expectationCreativeReady = nil
        self.expectationCreativeFailed = nil
        self.expectationCreativeDidComplete = nil
        self.expectationCreativeWasClicked = nil
        self.expectationClickthroughBrowserClosed = nil
        self.expectationVideoViewCompletedDisplay = nil
    }
    
    // MARK: - Tests
    
    func testLearnMoreButton() {
        self.setupVideoCreative()
        
        self.videoCreative.creativeModel.clickThroughURL = "www.openx.com"
        
        self.vc = UIViewController()
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 15, handler:nil)
        
        //Wait half a second, then force a click
        self.vc?.view.addSubview(videoCreative.view!)
        self.videoCreative?.display(rootViewController: UIViewController())
        
        self.expectationCreativeWasClicked = expectation(description: "expectationCreativeWasClicked")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            
            guard let strongSelf = self else {
                XCTFail("Self deallocated")
                return
            }
            
            guard let videoView = strongSelf.videoCreative.view as? VideoView else {
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
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVastDuration as NSNumber // VAST Duration
        
        setupVideoDurationTest(expectedDuration: expectedVastDuration)
    }
    
    func testVideoDuration() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = 10 // VAST Duration
        
        setupVideoDurationTest(expectedDuration: expectedVideoDuration)
    }
    
    func testPauseVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? VideoView else {
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
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? VideoView else {
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
    
    func testVideoStaysPausedWhenAppBecomesActiveWhilePaused() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber

        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")

        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)

        self.videoCreative?.display(rootViewController: UIViewController())

        guard let videoView = self.videoCreative.view as? VideoView else {
            XCTFail("Couldn't get Video View")
            return
        }

        videoView.videoViewDelegate = self

        let expectationVideoStaysPaused = expectation(description: "expectationVideoStaysPaused")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            XCTAssertEqual(videoView.playbackState, .playing)

            // Simulate the video being paused by a clickthrough overlay
            // (App Store or SafariViewController)
            videoView.pause()
            XCTAssertEqual(videoView.playbackState, .paused)

            // Simulate the app being backgrounded and foregrounded
            // while the overlay is still displayed
            NotificationCenter.default.post(name: UIApplication.willResignActiveNotification,
                                            object: UIApplication.shared)
            XCTAssertEqual(videoView.playbackState, .paused, "Explicit pause must not be converted to a background pause")

            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification,
                                            object: UIApplication.shared)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                XCTAssertEqual(videoView.playbackState, .paused)
                XCTAssertEqual(videoView.avPlayer.rate, 0, "Video must not resume while it was paused before resigning active")
                expectationVideoStaysPaused.fulfill()
            })
        })

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testVideoResumesWhenAppBecomesActiveWhilePlaying() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber

        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")

        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)

        self.videoCreative?.display(rootViewController: UIViewController())

        guard let videoView = self.videoCreative.view as? VideoView else {
            XCTFail("Couldn't get Video View")
            return
        }

        videoView.videoViewDelegate = self

        let expectationVideoResumed = expectation(description: "expectationVideoResumed")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            XCTAssertNotEqual(videoView.avPlayer.rate, 0)
            XCTAssertEqual(videoView.playbackState, .playing)

            // Simulate the app being backgrounded while the video is playing
            NotificationCenter.default.post(name: UIApplication.willResignActiveNotification,
                                            object: UIApplication.shared)
            XCTAssertEqual(videoView.avPlayer.rate, 0, "Video must be paused when the app resigns active")
            XCTAssertEqual(videoView.playbackState, .pausedByBackground)

            // Simulate the app returning to the foreground
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification,
                                            object: UIApplication.shared)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                XCTAssertNotEqual(videoView.avPlayer.rate, 0, "Video must resume when it was playing before resigning active")
                XCTAssertEqual(videoView.playbackState, .playing)
                expectationVideoResumed.fulfill()
            })
        })

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testStopVideo() {
        // Expected duration of video small.mp4 is 6 sec
        let expectedVideoDuration = 6.0
        let expectedStoppedDely = 3.0
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? VideoView else {
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
        let event = TrackingEvent.closeLinear
        
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? VideoView else {
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
        self.videoCreative.creativeModel.displayDurationInSeconds = expectedVideoDuration as NSNumber
        
        //Wait for creativeReady
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler:nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
        XCTAssertTrue(self.videoCreative.videoView.avPlayer.isMuted == false)
    }
    
    // An outstream (banner) video is rendered as a plain creative, never through `showAsInterstitial`,
    // and a refreshed banner is a new creative built from a fresh copy of the ad unit's config. The
    // configured mute state must apply to each of them, whatever the user did with the previous one.
    func testConfiguredMuteStateAppliesToEveryOutstreamCreative() {
        let adConfig = AdConfiguration()
        adConfig.videoControlsConfig.isMuted = true
        
        // First creative
        displayOutstreamCreative(adConfiguration: adConfig)
        let firstVideoView: VideoView = self.videoCreative.videoView
        XCTAssertTrue(firstVideoView.avPlayer.isMuted, "A muted banner video must start muted")
        
        // The user turns the sound on: only the creative on screen changes
        firstVideoView.unmute()
        XCTAssertFalse(firstVideoView.avPlayer.isMuted)
        XCTAssertTrue(adConfig.videoControlsConfig.isMuted, "A user action must not rewrite the publisher's setting")
        
        // Refresh: a new creative from the same configuration
        displayOutstreamCreative(adConfiguration: adConfig)
        XCTAssertTrue(self.videoCreative.videoView !== firstVideoView)
        XCTAssertTrue(self.videoCreative.videoView.avPlayer.isMuted, "A refreshed banner video must start muted again")
        
        // The publisher turns the sound on for later ads
        adConfig.videoControlsConfig.isMuted = false
        displayOutstreamCreative(adConfiguration: adConfig)
        XCTAssertFalse(self.videoCreative.videoView.avPlayer.isMuted, "The next creative follows the new setting")
    }
    
    // The mute button is created from the configuration when the creative is set up, so it must
    // show on a refreshed outstream creative as well, and stay away when it is not asked for.
    func testSoundButtonVisibilityFollowsTheConfigurationForEveryOutstreamCreative() {
        let adConfig = AdConfiguration()
        
        displayOutstreamCreative(adConfiguration: adConfig)
        XCTAssertNil(muteButton(in: self.videoCreative.videoView), "No mute button by default")
        
        adConfig.videoControlsConfig.isSoundButtonVisible = true
        displayOutstreamCreative(adConfiguration: adConfig)
        XCTAssertNotNil(muteButton(in: self.videoCreative.videoView), "The next creative shows the mute button")
        
        displayOutstreamCreative(adConfiguration: adConfig)
        XCTAssertNotNil(muteButton(in: self.videoCreative.videoView), "And so does the one after the refresh")
    }
    
    // Regression: the controls were drawn before the player was muted, so a muted creative showed
    // the "tap to mute" icon over a silent video.
    func testSoundButtonReflectsTheConfiguredMuteState() {
        let adConfig = AdConfiguration()
        adConfig.videoControlsConfig.isMuted = true
        adConfig.videoControlsConfig.isSoundButtonVisible = true
        
        displayOutstreamCreative(adConfiguration: adConfig)
        let videoView: VideoView = self.videoCreative.videoView
        
        XCTAssertTrue(videoView.avPlayer.isMuted)
        XCTAssertEqual(button(labelled: "pbmUnmute", in: videoView)?.isHidden, false, "A muted video offers to unmute")
        XCTAssertEqual(button(labelled: "pbmMute", in: videoView)?.isHidden, true)
        
        videoView.unmute()
        XCTAssertEqual(button(labelled: "pbmUnmute", in: videoView)?.isHidden, true)
        XCTAssertEqual(button(labelled: "pbmMute", in: videoView)?.isHidden, false, "An unmuted video offers to mute")
    }
    
    // Every combination of the two settings, each rendered as a fresh outstream creative from a
    // configuration that is reused across the cases, the way a refreshing banner reuses it.
    func testEveryCombinationOfMuteAndSoundButtonSettingsIsApplied() {
        let adConfig = AdConfiguration()
        
        let cases: [(isMuted: Bool, isSoundButtonVisible: Bool)] = [
            (false, false), (true, false), (false, true), (true, true)
        ]
        
        for testCase in cases {
            adConfig.videoControlsConfig.isMuted = testCase.isMuted
            adConfig.videoControlsConfig.isSoundButtonVisible = testCase.isSoundButtonVisible
            displayOutstreamCreative(adConfiguration: adConfig)
            
            let videoView: VideoView = self.videoCreative.videoView
            let detail = "isMuted=\(testCase.isMuted) isSoundButtonVisible=\(testCase.isSoundButtonVisible)"
            
            XCTAssertEqual(videoView.avPlayer.isMuted, testCase.isMuted, "Player mute state: \(detail)")
            
            let muteButton = button(labelled: "pbmMute", in: videoView)
            let unmuteButton = button(labelled: "pbmUnmute", in: videoView)
            
            if testCase.isSoundButtonVisible {
                XCTAssertNotNil(muteButton, "Mute button must exist: \(detail)")
                XCTAssertNotNil(unmuteButton, "Unmute button must exist: \(detail)")
                // Exactly one of the two is shown, and it offers the opposite of the current state
                XCTAssertEqual(muteButton?.isHidden, testCase.isMuted, "Mute button visibility: \(detail)")
                XCTAssertEqual(unmuteButton?.isHidden, !testCase.isMuted, "Unmute button visibility: \(detail)")
            } else {
                XCTAssertNil(muteButton, "No mute button was asked for: \(detail)")
                XCTAssertNil(unmuteButton, "No unmute button was asked for: \(detail)")
            }
        }
    }
    
    private func muteButton(in view: UIView) -> UIView? {
        button(labelled: "pbmMute", in: view)
    }
    
    private func button(labelled label: String, in view: UIView) -> UIView? {
        if view.accessibilityLabel == label {
            return view
        }
        for subview in view.subviews {
            if let button = button(labelled: label, in: subview) {
                return button
            }
        }
        return nil
    }
    
    private func displayOutstreamCreative(adConfiguration: AdConfiguration) {
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4", adConfiguration: adConfiguration)
        self.videoCreative.creativeModel.displayDurationInSeconds = 6
        
        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
        
        self.videoCreative?.display(rootViewController: UIViewController())
    }
    
    // The data loads through the resource loader but can't be decoded, so the player item fails
    // while the AVPlayer itself can still report readyToPlay.
    func testUndecodableVideoDataFailsCreative() {
        let model = CreativeModel(adConfiguration: AdConfiguration())
        model.videoFileURL = "http://get_video/broken.mp4"
        
        self.videoCreative = VideoCreative(creativeModel: model,
                                           transaction: UtilitiesForTesting.createEmptyTransaction(),
                                           videoData: Data(repeating: 0xAB, count: 4096))
        self.videoCreative.creativeResolutionDelegate = self
        self.videoCreative.creativeViewDelegate = self
        
        self.expectationCreativeFailed = self.expectation(description: "expectationCreativeFailed")
        let expectationCreativeReady = self.expectation(description: "expectationCreativeReady")
        expectationCreativeReady.isInverted = true
        self.expectationCreativeReady = expectationCreativeReady
        
        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        
        wait(for: [self.expectationCreativeFailed!], timeout: 10)
        wait(for: [expectationCreativeReady], timeout: 1)
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
    
    func testSetupTapRecognizer() {
        setupVideoCreative(
            videoFileURL: "http://get_video/small.mp4",
            localVideoFileName: "small.mp4"
        )

        guard let videoView = self.videoCreative.videoView else {
            XCTFail()
            return
        }

        let tapRecognizers = (videoView.gestureRecognizers ?? []).compactMap { $0 as? UITapGestureRecognizer }
        XCTAssertEqual(tapRecognizers.count, 1)

        XCTAssertTrue(tapRecognizers.first.map { type(of: $0) == UITapGestureRecognizer.self } ?? false)
        XCTAssertEqual(tapRecognizers.first?.numberOfTapsRequired, 1)
        XCTAssertEqual(tapRecognizers.first?.cancelsTouchesInView, false)
    }

    func testHandleSkipDelay() {
        let expectation = expectation(description: "Test Skip Button Active")
        setupVideoCreative(videoFileURL: "http://get_video/small.mp4", localVideoFileName: "small.mp4")
        
        guard let videoView = self.videoCreative.videoView else {
            XCTFail()
            return
        }
        
        self.videoCreative.creativeModel.adConfiguration = AdConfiguration()
        self.videoCreative.creativeModel.adConfiguration?.videoControlsConfig.skipDelay = 1
        self.videoCreative.creativeModel.displayDurationInSeconds = 10
        self.videoCreative.creativeModel.hasCompanionAd = true
        
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        
        let model = CreativeModel(adConfiguration:adConfiguration)
        
        self.videoCreative = VideoCreative(
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
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ORTBRewardedConfiguration())
        
        let model = CreativeModel(adConfiguration: adConfiguration)
        
        self.videoCreative = VideoCreative(
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
    
    func creativeReady(_ creative: AbstractCreative) {
        self.expectationCreativeReady?.fulfill()
    }
    
    func creativeFailed(_ error:Error) {
        self.expectationCreativeFailed?.fulfill()
    }
    
    // MARK: - VideoViewDelegate
    
    
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
    
    func trackEvent(_ trackingEvent: TrackingEvent) {}
    
    // MARK: - CreativeViewDelegate
    
    func creativeDidComplete(_ creative: AbstractCreative) {
        self.expectationCreativeDidComplete?.fulfill()
    }
    
    func creativeWasClicked(_ creative: AbstractCreative) {
        self.expectationCreativeWasClicked?.fulfill()
    }
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {}
    func creativeReadyToReimplant(_ creative: AbstractCreative) {}
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {}
    func creativeMraidDidExpand(_ creative: AbstractCreative) {}
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func videoViewWasTapped() {}
    func learnMoreWasClicked() {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {}
    
    // MARK: - Helper Methods
    
    private func setupVideoCreative(videoFileURL:String = "http://get_video/small.mp4", localVideoFileName:String = "small.mp4", adConfiguration: AdConfiguration = AdConfiguration()) {
        let rule = MockServerRule(urlNeedle: videoFileURL, mimeType: MockServerMimeType.MP4.rawValue, connectionID: connection.internalID, fileName: localVideoFileName)
        MockServer.shared.resetRules([rule])
        
        //Create model
        let model = CreativeModel(adConfiguration:adConfiguration)
        model.videoFileURL = videoFileURL
        
        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")
        
        let url = URL(string: model.videoFileURL!)
        let downloader = DownloadDataHelper(serverConnection: connection)
        downloader.downloadData(for: url, maxSize: VideoCreative.maxSizeForPreRenderContent, completionClosure: { (data:Data?, error:Error?) in
            
            DispatchQueue.main.async {
                //Create and start creative
                self.videoCreative = VideoCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction(), videoData: data!)
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
        
        self.videoCreative?.display(rootViewController: UIViewController())
        
        guard let videoView = self.videoCreative.view as? VideoView else {
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
        let ortbRewarded = ORTBRewardedConfiguration()
        ortbRewarded.completion = ORTBRewardedCompletion()
        ortbRewarded.completion?.video = ORTBRewardedCompletionVideo()
        ortbRewarded.completion?.video?.playbackevent = playbackevent
        ortbRewarded.completion?.video?.time = time
        ortbRewarded.close = ORTBRewardedClose()
        ortbRewarded.close?.postrewardtime = postRewardTime
        
        return RewardedConfig(ortbRewarded: ortbRewarded)
    }
}
