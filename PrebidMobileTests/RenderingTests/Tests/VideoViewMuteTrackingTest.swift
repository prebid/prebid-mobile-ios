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
import AVFoundation
@testable @_spi(PBMInternal) import PrebidMobile

// Records what the Open Measurement tracker would receive, and the VAST mute and unmute events.
private class VolumeTrackingSpy: NSObject, EventTrackerProtocol {
    private(set) var startVolumes: [Double] = []
    private(set) var volumeChanges: [Double] = []
    private(set) var muteEvents: [TrackingEvent] = []

    func trackEvent(_ event: TrackingEvent) {
        if event == .mute || event == .unmute {
            muteEvents.append(event)
        }
    }

    func trackVideoAdLoaded(_ parameters: VideoVerificationParameters) {}

    func trackStartVideo(duration: TimeInterval, volume: Double) {
        startVolumes.append(volume)
    }

    func trackVolumeChanged(playerVolume: Double, deviceVolume: Double) {
        volumeChanges.append(playerVolume)
    }
}

class VideoViewMuteTrackingTest: XCTestCase, CreativeResolutionDelegate {

    private let connection = UtilitiesForTesting.createConnectionForMockedTest()

    private var videoCreative: VideoCreative!
    private var spy: VolumeTrackingSpy!
    private var expectationCreativeReady: XCTestExpectation?

    private var videoView: VideoView {
        videoCreative.videoView
    }

    override func setUp() {
        MockServer.shared.reset()
        spy = VolumeTrackingSpy()
    }

    override func tearDown() {
        // Stop the video, so it doesn't keep playing during later tests.
        videoCreative?.close()
        videoCreative = nil
        spy = nil
        expectationCreativeReady = nil
        MockServer.shared.reset()
    }

    // MARK: - Open Measurement volume

    // Muting sets `AVPlayer.isMuted` and leaves `AVPlayer.volume` at 1, so a muted video
    // was reported to Open Measurement as audible.
    func testMutedStartIsReportedSilent() {
        loadVideoCreative(isMuted: true)
        applyConfiguredMuteStateBeforeStart()

        display()

        XCTAssertEqual(spy.startVolumes, [0])
        XCTAssertEqual(spy.volumeChanges, [], "The start event carries a mute state applied before it")
    }

    // The mute state can be applied to the player directly when playback starts, without `mute()`.
    func testPlayerMutedBeforeStartWithoutMuteIsReportedSilent() {
        loadVideoCreative(isMuted: true)
        videoView.avPlayer.isMuted = true

        display()

        XCTAssertEqual(spy.startVolumes, [0])
        XCTAssertEqual(spy.volumeChanges, [])
    }

    func testUnmutedStartIsReportedAtPlayerVolume() {
        loadVideoCreative()

        display()

        XCTAssertEqual(spy.startVolumes, [1])
    }

    // The configured mute state of a fullscreen video is applied asynchronously, so it can also
    // land after the start event. A mute or unmute never changes `AVPlayer.volume`, so the
    // volume observer doesn't report it.
    func testMuteAndUnmuteAfterStartReportVolumeChanges() {
        loadVideoCreative()
        display()

        videoView.mute()
        XCTAssertEqual(spy.volumeChanges, [0])

        videoView.unmute()
        XCTAssertEqual(spy.volumeChanges, [0, 1])
    }

    // A fullscreen video applies its configured state with `unmute()` even when it already plays with sound.
    func testMuteRequestThatKeepsTheStateReportsNoVolumeChange() {
        loadVideoCreative()
        display()

        videoView.unmute()
        XCTAssertEqual(spy.volumeChanges, [])

        videoView.mute()
        videoView.mute()
        XCTAssertEqual(spy.volumeChanges, [0])
    }

    // While the player is muted it plays no sound, whatever its own volume or the device volume.
    func testVolumeChangesWhileMutedAreReportedSilent() {
        loadVideoCreative()
        display()
        videoView.mute()

        // The volume observer records the first change of the player volume and reports the later ones.
        var reported = spy.volumeChanges.count
        videoView.avPlayer.volume = 0.5
        videoView.avPlayer.volume = 0.7
        waitUntil { self.spy.volumeChanges.count > reported }
        XCTAssertGreaterThan(spy.volumeChanges.count, reported, "A player volume change must be reported")
        XCTAssertTrue(spy.volumeChanges[reported...].allSatisfy { $0 == 0 }, "\(spy.volumeChanges)")

        reported = spy.volumeChanges.count
        simulateDeviceVolumeChange()
        waitUntil { self.spy.volumeChanges.count > reported }
        XCTAssertEqual(Array(spy.volumeChanges[reported...]), [0], "A device volume change must be reported")

        videoView.unmute()
        XCTAssertEqual(spy.volumeChanges.last ?? 0, 0.7, accuracy: 0.001, "Unmuting restores the player volume")
    }

    // MARK: - VAST mute and unmute

    func testSoundButtonTapsTrackMuteAndUnmute() {
        loadVideoCreative(isSoundButtonVisible: true)
        display()

        tapSoundButton("pbmMute")
        XCTAssertTrue(videoView.isMuted)
        XCTAssertEqual(spy.muteEvents, [.mute])
        XCTAssertEqual(spy.volumeChanges, [0])

        tapSoundButton("pbmUnmute")
        XCTAssertFalse(videoView.isMuted)
        XCTAssertEqual(spy.muteEvents, [.mute, .unmute])
        XCTAssertEqual(spy.volumeChanges, [0, 1])
    }

    // VAST defines mute and unmute as the user's action on the mute control. Applying the mute
    // state configured for the ad, before or after the start event, is not one.
    func testConfiguredMuteStateTracksNoMuteEvents() {
        loadVideoCreative(isMuted: true, isSoundButtonVisible: true)
        applyConfiguredMuteStateBeforeStart()

        display()
        videoView.unmute()
        videoView.mute()

        XCTAssertEqual(spy.muteEvents, [])
    }

    func testSoundButtonTapsRequestTheVastTrackingURLs() {
        let muteURL = "https://tracker.example.com/mute"
        let unmuteURL = "https://tracker.example.com/unmute"

        var requestedURLs: [String] = []
        // Any request beyond these two fails the test.
        let serverConnection = MockServerConnection(onFireAndForget: [
            { requestedURLs.append($0) },
            { requestedURLs.append($0) }
        ])

        loadVideoCreative(isMuted: true,
                          isSoundButtonVisible: true,
                          trackingURLs: ["mute": [muteURL], "unmute": [unmuteURL]],
                          serverConnection: serverConnection)
        applyConfiguredMuteStateBeforeStart()
        display()
        XCTAssertEqual(requestedURLs, [], "A video that starts muted requests no tracking URL")

        tapSoundButton("pbmUnmute")
        XCTAssertEqual(requestedURLs, [unmuteURL])

        tapSoundButton("pbmMute")
        XCTAssertEqual(requestedURLs, [unmuteURL, muteURL])
    }

    // MARK: - CreativeResolutionDelegate

    func creativeReady(_ creative: AbstractCreative) {
        expectationCreativeReady?.fulfill()
    }

    func creativeFailed(_ error: Error) {
        XCTFail("The video creative failed: \(error)")
    }

    // MARK: - Helper Methods

    // Loads a video creative and waits until its player is ready, without starting playback.
    private func loadVideoCreative(isMuted: Bool = false,
                                   isSoundButtonVisible: Bool = false,
                                   trackingURLs: [String: [String]] = [:],
                                   serverConnection: PrebidServerConnectionProtocol? = nil) {
        let videoFileURL = "http://get_video/small.mp4"
        let rule = MockServerRule(urlNeedle: videoFileURL,
                                  mimeType: MockServerMimeType.MP4.rawValue,
                                  connectionID: connection.internalID,
                                  fileName: "small.mp4")
        MockServer.shared.resetRules([rule])

        let adConfiguration = AdConfiguration()
        adConfiguration.videoControlsConfig.isMuted = isMuted
        adConfiguration.videoControlsConfig.isSoundButtonVisible = isSoundButtonVisible

        let model = CreativeModel(adConfiguration: adConfiguration)
        model.videoFileURL = videoFileURL
        model.displayDurationInSeconds = 6
        model.trackingURLs = trackingURLs
        if let serverConnection {
            model.eventTracker = AdModelEventTracker(creativeModel: model, serverConnection: serverConnection)
        }

        let downloadCompleted = expectation(description: "downloadCompleted")
        var videoData: Data?
        DownloadDataHelper(serverConnection: connection).downloadData(for: URL(string: videoFileURL),
                                                                      maxSize: VideoCreative.maxSizeForPreRenderContent) { data, _ in
            videoData = data
            downloadCompleted.fulfill()
        }
        wait(for: [downloadCompleted], timeout: 15)

        guard let videoData else {
            XCTFail("The video file was not downloaded")
            return
        }

        videoCreative = VideoCreative(creativeModel: model,
                                      transaction: UtilitiesForTesting.createEmptyTransaction(),
                                      videoData: videoData)
        videoCreative.creativeResolutionDelegate = self
        videoCreative.eventManager.registerTracker(spy)

        expectationCreativeReady = expectation(description: "expectationCreativeReady")
        videoCreative.setupView()
        wait(for: [expectationCreativeReady!], timeout: 10)
    }

    // A fullscreen video applies the configured mute state with `mute()` from an asynchronous block,
    // which can run before playback starts. This test creative is not shown fullscreen, so the
    // block is played here.
    private func applyConfiguredMuteStateBeforeStart() {
        videoView.mute()
    }

    // Starts playback: the start event is tracked synchronously.
    private func display() {
        videoCreative.display(rootViewController: UIViewController())
        XCTAssertEqual(videoView.playbackState, .playing)
    }

    private func tapSoundButton(_ accessibilityLabel: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let button = findButton(accessibilityLabel, in: videoView) else {
            XCTFail("No \(accessibilityLabel) button", file: file, line: line)
            return
        }

        XCTAssertFalse(button.isHidden, "Only the visible sound button can be tapped", file: file, line: line)

        // `sendActions(for:)` routes through the application, which this test bundle doesn't have,
        // so the button's actions are performed directly.
        for case let target as NSObject in button.allTargets {
            for action in button.actions(forTarget: target, forControlEvent: .touchUpInside) ?? [] {
                target.perform(Selector(action), with: button)
            }
        }
    }

    private func findButton(_ accessibilityLabel: String, in view: UIView) -> UIButton? {
        if let button = view as? UIButton, button.accessibilityLabel == accessibilityLabel {
            return button
        }

        for subview in view.subviews {
            if let button = findButton(accessibilityLabel, in: subview) {
                return button
            }
        }

        return nil
    }

    // The hardware volume can't be changed from a test, so this delivers the notification the
    // video view observes for it.
    private func simulateDeviceVolumeChange() {
        videoView.observeValue(forKeyPath: "outputVolume",
                               of: AVAudioSession.sharedInstance(),
                               change: [:],
                               context: nil)
    }

    // The volume observers report on the next pass of the main queue.
    private func waitUntil(timeout: TimeInterval = 2, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.01))
        }
    }
}
