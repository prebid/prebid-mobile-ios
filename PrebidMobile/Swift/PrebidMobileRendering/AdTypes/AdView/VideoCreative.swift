/*   Copyright 2018-2025 Prebid.org, Inc.

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

import Foundation
import UIKit

class VideoCreative: AbstractCreativeImpl, VideoViewDelegate {

    static var maxSizeForPreRenderContent: Int {
        // 25 MiB
        25 * 1024 * 1024
    }

    private(set) var videoView: VideoView!

    private let data: Data?
    private var rewardedConfig: RewardedConfig?

    // Whether playback should follow the viewability of the ad view.
    private var isVisibilityDrivenPlayback: Bool {
        !(adConfiguration?.presentAsInterstitial ?? false)
    }

    // MARK: - Initialization

    // `videoData` stays optional: `CreativeFactoryJob` passes the downloader's nullable result
    // (the ObjC original only asserted on it and went on without data).
    init(creativeModel: CreativeModel, transaction: Transaction, videoData: Data?) {
        data = videoData

        super.init(creativeModel: creativeModel, transaction: transaction)

        videoView = VideoView(creative: self)
        videoView.videoViewDelegate = self
        view = videoView

        rewardedConfig = adConfiguration?.rewardedConfig
        creativeModel.rewardTime = calculateRewardTime()
        creativeModel.postRewardTime = calculatePostRewardTime(with: creativeModel.rewardTime)
    }

    // The inherited ObjC initializer built a creative without a video view; nothing calls it. The creative is built like the
    // designated one, without data.
    required convenience init(creativeModel: CreativeModel, transaction: Transaction) {
        self.init(creativeModel: creativeModel, transaction: transaction, videoData: nil)
    }

    // MARK: - AbstractCreative

    override func setupView() {
        super.setupView()
        showVideoViewWithPreloadedData(data)
    }

    override func display(rootViewController viewController: UIViewController) {
        super.display(rootViewController: viewController)
        viewabilityTracker?.start()

        videoView.startPlayback()
        videoView.addFillSuperviewConstraints()
    }

    override func showAsInterstitial(fromRootViewController uiViewController: UIViewController,
                                            displayProperties: InterstitialDisplayProperties) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if self.adConfiguration?.videoControlsConfig.isMuted ?? false {
                self.videoView.mute()
            } else {
                self.videoView.unmute()
            }
        }

        //Create a copy of the interstitialDisplayProperties and modify the closeDelay to take the video length into account.
        let newDisplayProperties = createInterstitialPropertiesForCurrentVideoState(for: displayProperties)
        super.showAsInterstitial(fromRootViewController: uiViewController, displayProperties: newDisplayProperties)
    }

    override func onAdDisplayed() {
        super.onAdDisplayed()

        // An outstream video lives in the publisher's view hierarchy and may leave
        // the viewport at any moment, so the tracker must keep running after the impression
        // in order to pause playback. A fullscreen video always covers the screen.
        if !isVisibilityDrivenPlayback {
            viewabilityTracker?.stop()
            viewabilityTracker = nil
        }
    }

    override func onViewabilityChanged(_ viewable: Bool, viewExposure: ViewExposure) {
        super.onViewabilityChanged(viewable, viewExposure: viewExposure)

        if !isVisibilityDrivenPlayback {
            return
        }

        if viewable {
            videoView.resumeAfterVisibilityChange()
        } else {
            videoView.pauseForVisibilityChange()
        }
    }

    override func pause() {
        videoView.pause()
    }

    override func resume() {
        videoView.resume()
    }

    override func mute() {
        videoView.mute()
    }

    override func unmute() {
        videoView.unmute()
    }

    override var isMuted: Bool {
        videoView.isMuted
    }

    // Should the concept of "close" or dismiss be moved to AbstractCreativeImpl?
    func close() {
        videoView.stop(onCloseButton: .closeLinear)
    }

    var isPlaybackFinished: Bool {
        videoView.playbackState == .finished
    }

    override func createOpenMeasurementSession() {

        if !Thread.current.isMainThread {
            Log.error("Open Measurement session can only be created on the main thread")
            return
        }

        // ObjC messaged a nil transaction (no-op, nothing created).
        guard let transaction else {
            return
        }

        transaction.measurementSession = transaction.measurementWrapper
            .initializeNativeVideoSession(videoView, verificationParameters: creativeModel.verificationParameters)

        // The ObjC gate was `isKindOfClass:PBMOpenMeasurementSession`. A non-nil check is kept on purpose: the test mocks are
        // `OMSession` conformers, not `OpenMeasurementSession`, so a typed gate would stop the creative tests reaching this path.
        if let session = transaction.measurementSession {
            videoView.addFriendlyObstructions(to: session)
            session.start()
            eventManager.registerTracker(session.eventTracker)
            eventManager.trackVideoAdLoaded(VideoVerificationParameters())
        }
    }

    // MARK: - VideoViewDelegate

    func videoViewCompletedDisplay() {
        creativeViewDelegate?.videoCreativeDidComplete?(self)

        // Companion ad:
        // forward the event to the delegate so that it can display the next creative, if any.
        if creativeModel.hasCompanionAd {
            creativeViewDelegate?.creativeDidComplete(self)
            return
        }

        if adConfiguration?.presentAsInterstitial ?? false {
            // No companion ads, so pass completion to the modal manager. Rewarded ads use
            // rwdd.close.action; non-rewarded interstitials use the video controls setting.
            modalManager?.creativeDisplayCompleted(self)
            if !(adConfiguration?.isRewarded ?? false)
                && (adConfiguration?.videoControlsConfig.isAutoCloseOnCompletionEnabled ?? false),
               let dismissInterstitialModalState {
                dismissInterstitialModalState()
            }
        } else {
            creativeViewDelegate?.creativeDidComplete(self)
        }
    }

    func videoViewFailedWithError(_ error: Error) {
        creativeResolutionDelegate?.creativeFailed(error)
    }

    func videoViewReadyToDisplay() {
        creativeResolutionDelegate?.creativeReady(self)
    }

    func learnMoreWasClicked() {
        creativeViewDelegate?.creativeWasClicked(self)
        eventManager.trackEvent(.click)

        // `NSURL(string:)`, not `URL(string:)`: the ObjC original accepted what `NSURL` accepts (an empty string is a valid, empty `NSURL`).
        let url = creativeModel.clickThroughURL.flatMap { NSURL(string: $0) as URL? }

        pause()
        super.handleClickthrough(url, completionHandler: { _ in
            // nop
        }, onExit: { [weak self] in
            guard let self else { return }

            self.resume()
        })
    }

    func videoViewCurrentPlayingTime(_ currentPlayingTime: NSNumber) {
        // NOTE: Rewarded API only
        // Signal to the application that the user has earned the reward after
        // the certain period of time that the ad is on the screen.
        if !(adConfiguration?.isRewarded ?? false) {
            return
        }

        // NOTE: This logic apllicable only to the creatives without endcard.
        if creativeModel.hasCompanionAd {
            return
        }

        // A missing time reads as 0, like a message to `nil` in the ObjC original.
        let rewardTime = creativeModel.rewardTime?.doubleValue ?? 0
        let postRewardTime = creativeModel.postRewardTime?.doubleValue ?? 0

        // Try track reward event
        if !creativeModel.userHasEarnedReward
            && rewardTime >= 0
            && currentPlayingTime.doubleValue >= rewardTime {

            creativeModel.userHasEarnedReward = true
            creativeViewDelegate?.creativeDidSendRewardedEvent(self)

            // The SDK shows the Learn More button only when the reward clause is met.
            videoView.showLearnMore = true
            videoView.updateLearnMoreButton()
        }

        // Try track post-reward event
        if !creativeModel.userPostRewardEventSent
            && postRewardTime >= 0
            && currentPlayingTime.doubleValue >= postRewardTime {

            creativeModel.userPostRewardEventSent = true
            modalManager?.creativeDisplayCompleted(self)
        }
    }

    func videoViewWasTapped() {
        if let clickHandlerOverride = adConfiguration?.clickHandlerOverride {
            eventManager.trackEvent(.click)
            pause()
            // `self` is captured strongly, like the ObjC block (no `__weak`).
            clickHandlerOverride {
                self.resume()
            }
            return
        }

        // Do not process the click if video is finished
        if isPlaybackFinished {
            return
        }

        creativeViewDelegate?.creativeViewWasClicked(self)
    }

    // MARK: - ModalManager events

    override func modalManagerDidFinishPop(_ state: ModalState?) {

        //Clickthrough
        if clickthroughVisible {
            creativeViewDelegate?.creativeClickthroughDidClose(self)
            clickthroughVisible = false
            return
        }

        if adConfiguration?.isBuiltInVideo ?? false {
            creativeViewDelegate?.creativeFullScreenDidFinish(self)
            return
        }

        close()

        //Creative presented as Interstitial
        creativeViewDelegate?.creativeDidComplete(self)
        creativeViewDelegate?.creativeInterstitialDidClose(self)
    }

    override func modalManagerDidLeaveApp(_ state: ModalState?) {
        creativeViewDelegate?.creativeInterstitialDidLeaveApp(self)
    }

    // MARK: - Internal methods

    private func showVideoViewWithPreloadedData(_ preloadedData: Data?) {
        // `self` is captured weakly (`@weakify`) like the ObjC original.
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self else { return }

            // `NSURL(string:)`, see `learnMoreWasClicked`.
            let mediaFileURL = self.creativeModel.videoFileURL.flatMap { NSURL(string: $0) as URL? }
            self.videoView.showMediaFileURL(mediaFileURL, preloadedData: preloadedData)
        }
    }

    // MARK: - Utility

    private func createInterstitialPropertiesForCurrentVideoState(for initialProperties: InterstitialDisplayProperties) -> InterstitialDisplayProperties {
        // `copy()` always returns an `InterstitialDisplayProperties`.
        let newDisplayProperties = initialProperties.copy() as? InterstitialDisplayProperties ?? initialProperties
        newDisplayProperties.closeDelay = calculateCloseDelay(forPubCloseDelay: newDisplayProperties.closeDelay)
        newDisplayProperties.closeDelayLeft = newDisplayProperties.closeDelay
        return newDisplayProperties
    }

    // TODO: - Clarify the requirements and fix calculation logic
    func calculateCloseDelay(forPubCloseDelay pubCloseDelay: TimeInterval) -> TimeInterval {
        // A missing value reads as 0, like a message to `nil` in the ObjC original.
        let displayDuration = creativeModel.displayDurationInSeconds?.doubleValue ?? 0
        let skipDelay = adConfiguration?.videoControlsConfig.skipDelay ?? 0

        if creativeModel.hasCompanionAd {
            return displayDuration
        } else if skipDelay != 0 && skipDelay <= displayDuration {
            return skipDelay
        } else if let skipOffset = creativeModel.skipOffset, skipOffset.doubleValue <= displayDuration {
            return skipOffset.doubleValue
        } else {
            let videoDuration = displayDuration
            if videoDuration <= 0 {
                return PrebidConstants.CLOSE_DELAY_MIN
            }

            let lowerBound = PrebidConstants.CLOSE_DELAY_MIN
            // The `MIN` macro of the ObjC original, spelled out: it yields the second operand for a `NaN` duration (Swift's `min` does not).
            let upperBound = videoDuration < PrebidConstants.CLOSE_DELAY_MAX ? videoDuration : PrebidConstants.CLOSE_DELAY_MAX
            return Functions.clamp(pubCloseDelay, lowerBound: lowerBound, upperBound: upperBound)
        }
    }

    private func calculateRewardTime() -> NSNumber {
        if !(adConfiguration?.isRewarded ?? false) {
            return -1
        }

        var ortbPlaybackevent = rewardedConfig?.videoPlaybackevent
        let ortbVideoTime = rewardedConfig?.videoTime

        // If both complition criteria are missing (playbackevent and time) - use default configuration
        if ortbPlaybackevent == nil && ortbVideoTime == nil {
            ortbPlaybackevent = rewardedConfig?.defaultVideoPlaybackEvent
        }

        let videoDuration = creativeModel.displayDurationInSeconds?.doubleValue ?? 0

        // If completion criteria is playback event
        if let ortbPlaybackevent {
            let event = TrackingEvent(ortbPlaybackevent)

            switch event {
            case .start:
                return 0
            case .firstQuartile:
                return NSNumber(value: 0.25 * videoDuration)
            case .midpoint:
                return NSNumber(value: 0.5 * videoDuration)
            case .thirdQuartile:
                return NSNumber(value: 0.75 * videoDuration)
            case .complete:
                return NSNumber(value: videoDuration)
            default:
                return NSNumber(value: videoDuration)
            }
        }

        // If completion criteria is time and if 0 <= completion.video.time <= videoDuration
        if let ortbVideoTime, ortbVideoTime.doubleValue >= 0, ortbVideoTime.doubleValue <= videoDuration {
            return NSNumber(value: ortbVideoTime.doubleValue)
        }

        // Return video duration by default
        return NSNumber(value: videoDuration)
    }

    private func calculatePostRewardTime(with calculatedRewardTime: NSNumber?) -> NSNumber {
        let checkedRewardTime: NSNumber = (calculatedRewardTime == nil || calculatedRewardTime!.doubleValue < 0.0)
            ? 0.0 : calculatedRewardTime!

        let ortbPostrewardedTime = rewardedConfig?.postRewardTime
        let checkedPostrewardedTime: NSNumber = (ortbPostrewardedTime == nil || ortbPostrewardedTime!.doubleValue < 0.0)
            ? 0.0 : ortbPostrewardedTime!

        return NSNumber(value: checkedRewardTime.doubleValue + checkedPostrewardedTime.doubleValue)
    }
}
