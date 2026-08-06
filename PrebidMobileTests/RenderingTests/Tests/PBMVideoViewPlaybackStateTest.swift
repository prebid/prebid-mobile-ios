/*   Copyright 2018-2026 Prebid.org, Inc.

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
@testable @_spi(PBMInternal) import PrebidMobile

private class EventTrackerSpy: NSObject, EventTrackerProtocol {
    var events: [TrackingEvent] = []

    var pauseAndResumeEvents: [TrackingEvent] {
        events.filter { $0 == .pause || $0 == .resume }
    }

    func trackEvent(_ event: TrackingEvent) {
        events.append(event)
    }

    func trackVideoAdLoaded(_ parameters: VideoVerificationParameters) {}
    func trackStartVideo(duration: TimeInterval, volume: Double) {}
    func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {}
}

class PBMVideoViewPlaybackStateTest: XCTestCase, CreativeResolutionDelegate {

    let connection = UtilitiesForTesting.createConnectionForMockedTest()

    var videoCreative: PBMVideoCreative!
    var expectationDownloadCompleted: XCTestExpectation?
    var expectationCreativeReady: XCTestExpectation?

    private var adWindow: UIWindow!
    private var adContainer: UIView!

    override func setUp() {
        MockServer.shared.reset()
        // Viewability is driven by the real view hierarchy in this suite.
        Prebid.forcedIsViewable = false
    }

    override func tearDown() {
        MockServer.shared.reset()
        self.videoCreative = nil
        self.expectationDownloadCompleted = nil
        self.expectationCreativeReady = nil
        self.adWindow?.isHidden = true
        self.adWindow = nil
        self.adContainer = nil
    }

    // MARK: - States without a player

    func testInitialStateIsUnstarted() {
        let videoView = PBMVideoView(eventManager: EventManager())
        XCTAssertEqual(videoView.playbackState, .unstarted)
    }

    func testPauseAndResumeWithoutPlayerKeepState() {
        let videoView = PBMVideoView(eventManager: EventManager())

        videoView.pause()
        XCTAssertEqual(videoView.playbackState, .unstarted)

        videoView.resume()
        XCTAssertEqual(videoView.playbackState, .unstarted)
    }

    // MARK: - Explicit transitions

    func testStartPlaybackSetsPlaying() {
        runWithStartedPlayback { videoView in
            XCTAssertEqual(videoView.playbackState, .playing)
            XCTAssertNotEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testPauseAndResumeTransitions() {
        runWithStartedPlayback { videoView in
            videoView.pause()
            XCTAssertEqual(videoView.playbackState, .paused)
            XCTAssertEqual(videoView.avPlayer.rate, 0)

            videoView.resume()
            XCTAssertEqual(videoView.playbackState, .playing)
            XCTAssertNotEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testStopSetsFinished() {
        runWithStartedPlayback { videoView in
            videoView.stop()
            XCTAssertEqual(videoView.playbackState, .finished)
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testPlayToEndSetsFinished() {
        runWithStartedPlayback { videoView in
            videoView.handleDidPlayToEndTime()
            XCTAssertEqual(videoView.playbackState, .finished)
        }
    }

    func testResumeAfterFinishKeepsFinished() {
        runWithStartedPlayback { videoView in
            videoView.handleDidPlayToEndTime()

            // resume() must not restart a finished video
            videoView.resume()
            XCTAssertEqual(videoView.playbackState, .finished)
        }
    }

    func testWatchAgainRestartsPlayback() {
        runWithStartedPlayback { videoView in
            videoView.handleDidPlayToEndTime()
            XCTAssertEqual(videoView.playbackState, .finished)

            videoView.btnWatchAgainClick()
            XCTAssertEqual(videoView.playbackState, .playing)
            XCTAssertNotEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testFullscreenVideoWithAutoCloseDisabledOffersReplay() {
        runWithStartedPlayback(
            isInterstitial: true,
            autoCloseOnCompletion: false,
            hasCompanionAd: false,
            beforeAssertions: { $0.handleDidPlayToEndTime() },
            delayBeforeAssertions: 0.6
        ) { videoView in
            XCTAssertNotNil(videoView.btnWatchAgain)
        }
    }

    func testFullscreenVideoWithAutoCloseEnabledDoesNotOfferReplay() {
        runWithStartedPlayback(
            isInterstitial: true,
            hasCompanionAd: false,
            beforeAssertions: { $0.handleDidPlayToEndTime() },
            delayBeforeAssertions: 0.6
        ) { videoView in
            XCTAssertNil(videoView.btnWatchAgain)
        }
    }

    // MARK: - App lifecycle transitions

    func testResignActiveWhilePlayingSetsPausedByBackground() {
        runWithStartedPlayback { videoView in
            self.postWillResignActive()
            XCTAssertEqual(videoView.playbackState, .pausedByBackground)
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testBecomeActiveResumesOnlyBackgroundPause() {
        runWithStartedPlayback { videoView in
            self.postWillResignActive()
            XCTAssertEqual(videoView.playbackState, .pausedByBackground)

            self.postDidBecomeActive()
            XCTAssertEqual(videoView.playbackState, .playing)
            XCTAssertNotEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testBecomeActiveKeepsExplicitPause() {
        runWithStartedPlayback { videoView in
            // Simulate the video being paused by a clickthrough overlay
            // (App Store or SafariViewController)
            videoView.pause()

            // Simulate the app being backgrounded and foregrounded
            // while the overlay is still displayed
            self.postWillResignActive()
            XCTAssertEqual(videoView.playbackState, .paused,
                           "Explicit pause must not be converted to a background pause")

            self.postDidBecomeActive()
            XCTAssertEqual(videoView.playbackState, .paused,
                           "Video must not resume while it was paused before resigning active")
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testBecomeActiveKeepsCloseButtonPause() {
        runWithStartedPlayback { videoView in
            videoView.stop(onCloseButton: .closeLinear)
            XCTAssertEqual(videoView.playbackState, .paused)

            self.postWillResignActive()
            self.postDidBecomeActive()
            XCTAssertEqual(videoView.playbackState, .paused,
                           "Video must not resume after it was stopped by the close button")
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testBecomeActiveKeepsFinishedState() {
        runWithStartedPlayback { videoView in
            videoView.stop()

            self.postWillResignActive()
            self.postDidBecomeActive()
            XCTAssertEqual(videoView.playbackState, .finished,
                           "Video must not resume after playback has finished")
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testMultipleBackgroundCycles() {
        runWithStartedPlayback { videoView in
            for _ in 0..<2 {
                self.postWillResignActive()
                XCTAssertEqual(videoView.playbackState, .pausedByBackground)
                XCTAssertEqual(videoView.avPlayer.rate, 0)

                self.postDidBecomeActive()
                XCTAssertEqual(videoView.playbackState, .playing)
                XCTAssertNotEqual(videoView.avPlayer.rate, 0)
            }
        }
    }

    // MARK: - Viewability transitions

    func testScrollingOffScreenPausesPlayback() {
        runWithStartedPlayback { videoView in
            self.scrollAdOffScreen()
            self.waitForViewabilityPolling()

            XCTAssertEqual(videoView.playbackState, .pausedByVisibility)
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testScrollingBackOnScreenResumesPlayback() {
        runWithStartedPlayback { videoView in
            self.scrollAdOffScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(videoView.playbackState, .pausedByVisibility)

            self.scrollAdOnScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(videoView.playbackState, .playing)
            XCTAssertNotEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testScrollingOffScreenKeepsExplicitPause() {
        runWithStartedPlayback { videoView in
            // Simulate the video being paused by a clickthrough overlay
            videoView.pause()

            self.scrollAdOffScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(videoView.playbackState, .paused,
                           "Explicit pause must not be converted to a visibility pause")

            self.scrollAdOnScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(videoView.playbackState, .paused,
                           "Becoming viewable again must not resume a video paused by a clickthrough")
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testScrollingOffScreenKeepsFinishedState() {
        runWithStartedPlayback { videoView in
            videoView.stop()

            self.scrollAdOffScreen()
            self.scrollAdOnScreen()
            self.waitForViewabilityPolling()

            XCTAssertEqual(videoView.playbackState, .finished,
                           "Video must not resume after playback has finished")
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testBecomeActiveKeepsVisibilityPause() {
        runWithStartedPlayback { videoView in
            self.scrollAdOffScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(videoView.playbackState, .pausedByVisibility)

            self.postWillResignActive()
            self.postDidBecomeActive()
            XCTAssertEqual(videoView.playbackState, .pausedByVisibility,
                           "Returning to foreground must not resume an off-screen video")
            XCTAssertEqual(videoView.avPlayer.rate, 0)
        }
    }

    func testFullscreenVideoIgnoresViewability() {
        runWithStartedPlayback(isInterstitial: true) { videoView in
            self.scrollAdOffScreen()
            self.waitForViewabilityPolling()

            XCTAssertEqual(videoView.playbackState, .playing,
                           "Fullscreen video playback must not be driven by the viewability tracker")
        }
    }

    // MARK: - Tracking events

    func testBackgroundCycleTracksPauseAndResume() {
        let eventTrackerSpy = EventTrackerSpy()

        runWithStartedPlayback { videoView in
            self.videoCreative.eventManager.registerTracker(eventTrackerSpy)

            self.postWillResignActive()
            XCTAssertEqual(eventTrackerSpy.pauseAndResumeEvents, [.pause])

            self.postDidBecomeActive()
            XCTAssertEqual(eventTrackerSpy.pauseAndResumeEvents, [.pause, .resume])
        }
    }

    func testVisibilityCycleTracksPauseAndResume() {
        let eventTrackerSpy = EventTrackerSpy()

        runWithStartedPlayback { videoView in
            self.videoCreative.eventManager.registerTracker(eventTrackerSpy)

            self.scrollAdOffScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(eventTrackerSpy.pauseAndResumeEvents, [.pause])

            self.scrollAdOnScreen()
            self.waitForViewabilityPolling()
            XCTAssertEqual(eventTrackerSpy.pauseAndResumeEvents, [.pause, .resume])
        }
    }

    func testStayingOffScreenTracksSinglePause() {
        let eventTrackerSpy = EventTrackerSpy()

        runWithStartedPlayback { videoView in
            self.videoCreative.eventManager.registerTracker(eventTrackerSpy)

            self.scrollAdOffScreen()
            // Several polls happen while the ad stays off-screen
            self.waitForViewabilityPolling()
            self.waitForViewabilityPolling()

            XCTAssertEqual(eventTrackerSpy.pauseAndResumeEvents, [.pause],
                           "Polling an off-screen ad must not track a pause event on every poll")
        }
    }

    func testBackgroundCycleWhilePausedTracksNoEvents() {
        let eventTrackerSpy = EventTrackerSpy()

        runWithStartedPlayback { videoView in
            videoView.pause()
            self.videoCreative.eventManager.registerTracker(eventTrackerSpy)

            self.postWillResignActive()
            self.postDidBecomeActive()

            XCTAssertEqual(eventTrackerSpy.pauseAndResumeEvents, [],
                           "Backgrounding an already paused video must not track extra pause/resume events")
        }
    }

    // MARK: - CreativeResolutionDelegate

    func creativeReady(_ creative: AbstractCreative) {
        self.expectationCreativeReady?.fulfill()
    }

    func creativeFailed(_ error: Error) {}

    // MARK: - Helper Methods

    // Loads the video creative, puts it on screen, starts playback and runs
    // assertions one second later, when the player is actually playing.
    private func runWithStartedPlayback(isInterstitial: Bool = false,
                                        autoCloseOnCompletion: Bool = true,
                                        hasCompanionAd: Bool = true,
                                        beforeAssertions: ((PBMVideoView) -> Void)? = nil,
                                        delayBeforeAssertions: TimeInterval = 0,
                                        file: StaticString = #file,
                                        line: UInt = #line,
                                        assertions: @escaping (PBMVideoView) -> Void) {
        setupVideoCreative(
            isInterstitial: isInterstitial,
            autoCloseOnCompletion: autoCloseOnCompletion,
            hasCompanionAd: hasCompanionAd
        )
        self.videoCreative.creativeModel.displayDurationInSeconds = 6

        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")

        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler: nil)

        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View", file: file, line: line)
            return
        }

        // The ad has to be on screen, otherwise the viewability tracker
        // pauses playback as soon as it starts.
        showOnScreen(videoView)

        self.videoCreative?.display(rootViewController: UIViewController())

        let expectationAssertionsCompleted = expectation(description: "expectationAssertionsCompleted")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            beforeAssertions?(videoView)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeAssertions) {
                assertions(videoView)
                expectationAssertionsCompleted.fulfill()
            }
        })

        waitForExpectations(timeout: 5, handler: nil)
    }

    // Puts the ad into an on-screen window, inside a container that stands for
    // the publisher's scrollable content.
    private func showOnScreen(_ adView: UIView) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let container = UIView(frame: window.bounds)

        window.isHidden = false
        window.addSubview(container)
        container.addSubview(adView)

        self.adWindow = window
        self.adContainer = container
    }

    // Moves the ad fully out of the window, the way scrolling it off-screen does.
    private func scrollAdOffScreen() {
        adContainer.frame = adContainer.frame.offsetBy(dx: 0, dy: adWindow.bounds.height)
    }

    private func scrollAdOnScreen() {
        adContainer.frame = adWindow.bounds
    }

    // Spins the run loop so that the viewability tracker gets a chance to poll.
    private func waitForViewabilityPolling() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.5))
    }

    private func postWillResignActive() {
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification,
                                        object: UIApplication.shared)
    }

    private func postDidBecomeActive() {
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification,
                                        object: UIApplication.shared)
    }

    private func setupVideoCreative(videoFileURL: String = "http://get_video/small.mp4",
                                    localVideoFileName: String = "small.mp4",
                                    isInterstitial: Bool = false,
                                    autoCloseOnCompletion: Bool = true,
                                    hasCompanionAd: Bool = true) {
        let rule = MockServerRule(urlNeedle: videoFileURL,
                                  mimeType: MockServerMimeType.MP4.rawValue,
                                  connectionID: connection.internalID,
                                  fileName: localVideoFileName)
        MockServer.shared.resetRules([rule])

        let adConfiguration = AdConfiguration()
        adConfiguration.isInterstitialAd = isInterstitial
        adConfiguration.videoControlsConfig.isAutoCloseOnCompletionEnabled = autoCloseOnCompletion

        let model = CreativeModel(adConfiguration: adConfiguration)
        model.hasCompanionAd = hasCompanionAd
        model.videoFileURL = videoFileURL

        self.expectationDownloadCompleted = self.expectation(description: "expectationDownloadCompleted")

        let url = URL(string: model.videoFileURL!)
        let downloader = PBMDownloadDataHelper(serverConnection: connection)
        downloader.downloadData(for: url,
                                maxSize: PBMVideoCreative.maxSizeForPreRenderContent,
                                completionClosure: { (data: Data?, error: Error?) in
            DispatchQueue.main.async {
                self.videoCreative = PBMVideoCreative(creativeModel: model,
                                                      transaction: UtilitiesForTesting.createEmptyTransaction(),
                                                      videoData: data!)
                self.videoCreative.creativeResolutionDelegate = self

                self.expectationDownloadCompleted?.fulfill()
            }
        })

        wait(for: [self.expectationDownloadCompleted!], timeout: 15)
    }
}
