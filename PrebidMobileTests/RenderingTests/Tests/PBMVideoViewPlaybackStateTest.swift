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

    override func setUp() {
        MockServer.shared.reset()
    }

    override func tearDown() {
        MockServer.shared.reset()
        self.videoCreative = nil
        self.expectationDownloadCompleted = nil
        self.expectationCreativeReady = nil
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

    // Loads the video creative, starts playback and runs assertions
    // one second later, when the player is actually playing.
    private func runWithStartedPlayback(file: StaticString = #file,
                                        line: UInt = #line,
                                        assertions: @escaping (PBMVideoView) -> Void) {
        setupVideoCreative()
        self.videoCreative.creativeModel.displayDurationInSeconds = 6

        self.expectationCreativeReady = self.expectation(description: "expectationCreativeReady")

        DispatchQueue.main.async {
            self.videoCreative?.setupView()
        }
        self.waitForExpectations(timeout: 10, handler: nil)

        self.videoCreative?.display(rootViewController: UIViewController())

        guard let videoView = self.videoCreative.view as? PBMVideoView else {
            XCTFail("Couldn't get Video View", file: file, line: line)
            return
        }

        let expectationAssertionsCompleted = expectation(description: "expectationAssertionsCompleted")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            assertions(videoView)
            expectationAssertionsCompleted.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)
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
                                    localVideoFileName: String = "small.mp4") {
        let rule = MockServerRule(urlNeedle: videoFileURL,
                                  mimeType: MockServerMimeType.MP4.rawValue,
                                  connectionID: connection.internalID,
                                  fileName: localVideoFileName)
        MockServer.shared.resetRules([rule])

        let model = CreativeModel(adConfiguration: AdConfiguration())
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
