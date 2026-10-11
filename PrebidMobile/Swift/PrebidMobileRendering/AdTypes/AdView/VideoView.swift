//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers

private let playerObserverKeyStatus = "status"
private let playerObserverKeyVolume = "volume"
private let audioSessionObserverKeyVolume = "outputVolume"

private let learnMoreButtonTitle = "Learn More"
private let watchAgainButtonTitle = "Watch Again"

private let enableOutstreamTapToExpand = false
private let muteButtonSize = CGSize(width: 24, height: 24)

// Not final: `MockVideoView` in the test target overrides `requiredVideoDuration()`.
@objc(PBMVideoView) @_spi(PBMInternal) public
class VideoView: UIView, AVAssetResourceLoaderDelegate, UIGestureRecognizerDelegate {

    // MARK: - Public properties

    @objc public weak var videoViewDelegate: VideoViewDelegate?
    @objc public var progressBar: CircularProgressBarView?

    @objc public var showLearnMore = false
    @objc public var isSoundButtonVisible = false

    @objc public private(set) var playbackState = VideoViewPlaybackState.unstarted

    // `nil` while no player has been attached (the ObjC property was declared nonnull but returned nil).
    var avPlayer: AVPlayer! {
        get { (layer as? AVPlayerLayer)?.player }
        set { (layer as? AVPlayerLayer)?.player = newValue }
    }

    @objc public var isMuted: Bool {
        get { avPlayer?.isMuted ?? false }
        set {
            avPlayer?.isMuted = newValue
            updateMuteControls()
        }
    }

    // MARK: - Internal properties

    // Weak, like the ObjC original: the creative owns the view.
    weak var creative: AbstractCreative?
    var eventManager: EventManager?

    var skipButtonDecorator: AdViewButtonDecorator!
    var progressBarDuration: NSNumber = 0
    var btnWatchAgain: UIButton?

    // MARK: - Private properties

    private var tapGestureRecognizer: UITapGestureRecognizer?

    private var btnLearnMore: UIButton?
    private weak var btnMute: UIButton?
    private weak var btnUnmute: UIButton?
    private weak var muteControlsView: UIView?

    private var preloadedData: Data?

    private var timeObserver: Any?
    private var previousCompletionPercentage: CGFloat = 0

    private var isInitialVolumeTracked: Float?

    // Optimization: since we show only preloaded data we can free the buffer when data is sent to the player.
    // This property holds the amount of data that was sent to the player.
    private var requestedDataLength = 0

    private var adConfiguration: AdConfiguration? {
        creative?.creativeModel.adConfiguration
    }

    // MARK: - Layer

    public override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc public init(eventManager: EventManager) {
        super.init(frame: .zero)
        setup(eventManager: eventManager)
        progressBarDuration = calculateProgressBarDuration()
    }

    @objc public init(creative: AbstractCreative) {
        let frame = CGRect(x: 0.0,
                           y: 0.0,
                           width: CGFloat(creative.creativeModel.width),
                           height: CGFloat(creative.creativeModel.height))

        super.init(frame: frame)
        self.creative = creative
        setup(eventManager: creative.eventManager)
        progressBarDuration = calculateProgressBarDuration()
    }

    deinit {
        Log.whereAmI()

        NotificationCenter.default.removeObserver(self)

        if let player = avPlayer {
            player.currentItem?.removeObserver(self, forKeyPath: playerObserverKeyStatus)
            player.removeObserver(self, forKeyPath: playerObserverKeyVolume)

            if let timeObserver {
                player.removeTimeObserver(timeObserver)
            }

            player.pause()

            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: audioSessionObserverKeyVolume)
        }
    }

    private func setup(eventManager: EventManager) {
        showLearnMore = false
        playbackState = .unstarted
        self.eventManager = eventManager
        accessibilityIdentifier = "PBMVideoView"

        if !(adConfiguration?.isInterstitialAd ?? false) || !(adConfiguration?.isRewarded ?? false) {
            setupTapRecognizer()
        }

        setupSkipButton()

        isSoundButtonVisible = adConfiguration?.videoControlsConfig.isSoundButtonVisible ?? false
    }

    // MARK: - Public

    // The parameters stay optional: ObjC callers (`PBMVideoCreative`, `PBMMRAIDController`) can still pass `nil`.
    @objc(showMediaFileURL:preloadedData:)
    public func showMediaFileURL(_ mediaFileURL: URL?, preloadedData: Data?) {
        Log.whereAmI()

        if mediaFileURL == nil || preloadedData == nil {
            Log.error("Invalid input parameters")
        }

        guard mediaFileURL != nil else {
            return
        }

        self.preloadedData = preloadedData

        // Pass it to an AVURLAsset via AVAssetResourceLoaderDelegate
        let dummyURL = URL(string: "dummy://url")!
        let avURLAsset = AVURLAsset(url: dummyURL)

        let queue = DispatchQueue(label: "avResourceLoader")
        avURLAsset.resourceLoader.setDelegate(self, queue: queue)

        let playerItem = AVPlayerItem(asset: avURLAsset)

        // `self` is captured strongly, like the ObjC block (no `__weak`).
        DispatchQueue.main.async {
            self.avPlayer = AVPlayer(playerItem: playerItem)

            self.avPlayer.addObserver(self, forKeyPath: playerObserverKeyVolume, options: .new, context: nil)
        }

        // Add Observers
        setupObservers(playerItem: playerItem)
    }

    func updateControls() {
        updateLearnMoreButtonVisibility()
        updateLearnMoreButton()

        resetMuteControls()
        updateMuteControls()

        updateProgressBar()
    }

    private func updateLearnMoreButtonVisibility() {

        guard videoViewDelegate != nil else {
            // We have no way to respond to the Learn More button click
            // Is used to show the MRAID video.
            showLearnMore = false
            return
        }

        guard adConfiguration?.presentAsInterstitial ?? false else {
            showLearnMore = false
            return
        }

        // For rewarded ad learn more should be hidden
        if adConfiguration?.isRewarded ?? false {
            showLearnMore = false
            return
        }

        guard let creativeModel = creative?.creativeModel else {
            showLearnMore = false
            return
        }

        let hasCompanionAd = creativeModel.hasCompanionAd || creativeModel.isCompanionAd

        /*
         If this interstitial video ad has companions or is a companion ad,
         do not show a learn more button during the video, and only show the end card

         Since rewarded video ads can have companions (i.e. the current creative is the primary
         rewarded ad and has companions) or is a companion ad (i.e. we've displayed the primary and
         now we're displaying as series of 1 or more companions) we'll show the learn more only
         at the end.
         */
        showLearnMore = !hasCompanionAd
    }

    private func setupObservers(playerItem: AVPlayerItem) {
        // This will fire when the view is ready to play or fails
        playerItem.addObserver(self, forKeyPath: playerObserverKeyStatus, options: .initial, context: nil)

        // This will fire when end of content is reached
        // NOTE: there is a possibility of duplicate notification
        // https://stackoverflow.com/questions/16248496/observer-in-nsnotification-itemdidfinishplaying-randomly-to-called-twice
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)

        // Note: intentionally not calling `setActive:YES` here. Activating the shared audio session
        // is a synchronous call that can block the main thread and interrupts audio already playing
        // in other apps, even though this is only needed to observe `outputVolume` via KVO, which
        // works without activating the session.
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: audioSessionObserverKeyVolume, options: .new, context: nil)
    }

    // MARK: - AVAssetResourceLoaderDelegate

    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                               shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let preloadedData else {
            loadingRequest.finishLoading(with: PBMError.error(description: "data was not pre-fetched"))
            return false
        }

        guard let dataRequest = loadingRequest.dataRequest else {
            loadingRequest.finishLoading(with: PBMError.error(description: "No data request"))
            return false
        }

        let dataLength = preloadedData.count
        if dataLength == 0 {
            loadingRequest.finishLoading(with: PBMError.error(description: "preloadedData is empty!"))
            return false
        }

        // Get the subset of data to send.
        // Typically the first request wants the first 2 bytes, then a subsequent request will ask for all the bytes.
        let start = Int(dataRequest.requestedOffset)
        let (end, didOverflow) = start.addingReportingOverflow(dataRequest.requestedLength)
        let range = NSRange(location: start, length: dataRequest.requestedLength)

        // ObjC wrapped on overflow and then failed the `end > dataLength` check; Swift would trap instead.
        if didOverflow || end > dataLength {
            let message = "Requested range of \(NSStringFromRange(range)) goes past the end of preloadedData (length is \(dataLength))"
            loadingRequest.finishLoading(with: PBMError.error(description: message))
            return false
        }

        let dataToSend = preloadedData.subdata(in: start..<end)

        // Convert the MIMEType to a UTI
        // TODO: This always identifies the preloaded file as an mp4. This works (since it's already passed other checks) but should
        // be updated to use its true mimetype.
        if let contentType = UTType(mimeType: "video/mp4") {
            loadingRequest.contentInformationRequest?.contentType = contentType.identifier
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        }

        // Send the full length of the content (Note that this is not neccessarily the amount of data being sent!)
        loadingRequest.contentInformationRequest?.contentLength = Int64(dataLength)
        dataRequest.respond(with: dataToSend)

        // Tell the request that we are finished sending data for now.
        loadingRequest.finishLoading()

        // If all data is transfered to the player we can free the memory for preloaded data.
        requestedDataLength += range.length
        if requestedDataLength == dataLength {
            self.preloadedData = nil
            requestedDataLength = 0
        }

        return true
    }

    // MARK: - Modal manager delegate

    @objc(modalManagerDidFinishPop:)
    public func modalManagerDidFinishPop(_ state: ModalState) {
        if let creative {
            creative.resume()
        } else {
            resume() // MRAID video
        }
    }

    @objc(modalManagerDidLeaveApp:)
    public func modalManagerDidLeaveApp(_ state: ModalState) {
        creative?.modalManagerDidLeaveApp(state)
    }

    // MARK: - View buttons

    @objc public func updateLearnMoreButton() {
        btnLearnMore?.removeFromSuperview()

        if !showLearnMore {
            return
        }

        let learnMoreButton = createButton(title: learnMoreButtonTitle, action: #selector(btnLearnMoreClick))
        btnLearnMore = learnMoreButton
        addSubview(learnMoreButton)

        learnMoreButton.PBMAddBottomRightConstraintsWithMarginSize(CGSize(width: -25.0, height: -25.0))
    }

    private func updateProgressBar() {
        progressBar?.removeFromSuperview()

        if !(adConfiguration?.isRewarded ?? false) {
            return
        }

        let progressBar = CircularProgressBarView(frame: CGRect(x: 30, y: 60, width: 36, height: 36))
        progressBar.emptyCapType = 1

        progressBar.valueFontName = ".SFUIText-Medium"
        progressBar.valueFontSize = 16
        progressBar.fontColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        progressBar.progressLineWidth = 2
        progressBar.progressLinePadding = 1
        progressBar.progressColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        progressBar.backgroundColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 0.75)

        addSubview(progressBar)
        progressBar.PBMAddBottomLeftConstraints(viewSize: CGSize(width: 36, height: 36),
                                                marginSize: CGSize(width: 25.0, height: -25.0))

        self.progressBar = progressBar
    }

    private func updateWatchAgainButton() {
        btnWatchAgain?.removeFromSuperview()

        let watchAgainButton = createButton(title: watchAgainButtonTitle, action: #selector(btnWatchAgainClick))
        btnWatchAgain = watchAgainButton
        addSubview(watchAgainButton)

        watchAgainButton.PBMAddCropAndCenterConstraints(initialWidth: watchAgainButton.frame.size.width,
                                                        initialHeight: watchAgainButton.frame.size.height)
    }

    private func resetMuteControls() {
        muteControlsView?.removeFromSuperview()
        muteControlsView = nil
    }

    private func setupMuteControls() {
        if muteControlsView != nil {
            return
        }

        if !isSoundButtonVisible {
            return
        }

        let muteButton = createButton(encodedString: PrebidImagesRepository.muteDisabled,
                                      accessibilityLabel: "pbmMute",
                                      action: #selector(btnMuteClick(_:)))

        let unmuteButton = createButton(encodedString: PrebidImagesRepository.muteEnabled,
                                        accessibilityLabel: "pbmUnmute",
                                        action: #selector(btnUnmuteClick(_:)))

        muteButton.translatesAutoresizingMaskIntoConstraints = false
        unmuteButton.translatesAutoresizingMaskIntoConstraints = false

        let muteControlsView = UIView()
        muteControlsView.translatesAutoresizingMaskIntoConstraints = false

        muteControlsView.addSubview(muteButton)
        muteControlsView.addSubview(unmuteButton)

        NSLayoutConstraint.activate([
            muteControlsView.widthAnchor.constraint(equalToConstant: muteButtonSize.width),
            muteControlsView.heightAnchor.constraint(equalToConstant: muteButtonSize.height),

            muteButton.centerXAnchor.constraint(equalTo: muteControlsView.centerXAnchor),
            muteButton.centerYAnchor.constraint(equalTo: muteControlsView.centerYAnchor),
            muteButton.widthAnchor.constraint(lessThanOrEqualTo: muteControlsView.widthAnchor),
            muteButton.heightAnchor.constraint(lessThanOrEqualTo: muteControlsView.heightAnchor),

            unmuteButton.centerXAnchor.constraint(equalTo: muteControlsView.centerXAnchor),
            unmuteButton.centerYAnchor.constraint(equalTo: muteControlsView.centerYAnchor),
            unmuteButton.widthAnchor.constraint(lessThanOrEqualTo: muteControlsView.widthAnchor),
            unmuteButton.heightAnchor.constraint(lessThanOrEqualTo: muteControlsView.heightAnchor)
        ])

        addSubview(muteControlsView)
        if adConfiguration?.presentAsInterstitial ?? false {
            NSLayoutConstraint.activate([
                muteControlsView.leftAnchor.constraint(equalTo: leftAnchor, constant: 25),
                muteControlsView.topAnchor.constraint(equalTo: topAnchor, constant: 18)
            ])
        } else {
            NSLayoutConstraint.activate([
                muteControlsView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
                muteControlsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
            ])
        }

        btnMute = muteButton
        btnUnmute = unmuteButton
        self.muteControlsView = muteControlsView
    }

    private func updateMuteControls() {
        if muteControlsView == nil {
            setupMuteControls()
        }
        let muted = isMuted
        btnMute?.isHidden = muted
        btnUnmute?.isHidden = !muted
    }

    private func setupSkipButton() {
        let decorator = AdViewButtonDecorator()
        skipButtonDecorator = decorator
        decorator.button.isHidden = true
        // ObjC read these through a possibly-nil `adConfiguration`, giving 0 (`topLeft`) when it was missing.
        decorator.buttonArea = adConfiguration?.videoControlsConfig.skipButtonArea ?? 0
        decorator.buttonPosition = adConfiguration?.videoControlsConfig.skipButtonPosition ?? .topLeft

        if let skipButtonImage = PrebidImagesRepository.skipButton.base64DecodedImage {
            decorator.setImage(skipButtonImage)
        }
        decorator.addButton(to: self, displayView: self)

        decorator.buttonTouchUpInsideBlock = { [weak self] in
            self?.skipButtonTapped()
        }
    }

    private func skipButtonTapped() {
        skipButtonDecorator?.removeButtonFromSuperview()
        avPlayer?.pause()
        completeVideoViewDisplay(with: .skip)
    }

    func handleSkipDelay(_ skipDelay: TimeInterval, videoDuration: TimeInterval) {
        if skipDelay >= videoDuration {
            return
        }

        if !(creative?.creativeModel.hasCompanionAd ?? false) ||
            (adConfiguration?.isRewarded ?? false) ||
            (adConfiguration?.isBuiltInVideo ?? false) {
            return
        }

        // Note: the delay comes from the configuration, not from the `skipDelay` parameter (as in the ObjC original).
        // NaN is no delay and a negative delay is already due; the upper bound keeps the deadline arithmetic from trapping.
        let configuredDelay = adConfiguration?.videoControlsConfig.skipDelay ?? 0
        let delay = configuredDelay.isNaN ? 0 : min(max(configuredDelay, 0), 3_000_000_000)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.skipButtonDecorator?.button.isHidden = false
        }
    }

    private func createButton(encodedString: String, accessibilityLabel: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setImage(encodedString.base64DecodedImage, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.isAccessibilityElement = true
        button.accessibilityLabel = accessibilityLabel
        button.layer.cornerRadius = 5
        button.layer.backgroundColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 0.75).cgColor
        button.sizeToFit()

        return button
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.isAccessibilityElement = true
        button.accessibilityLabel = title

        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2

        button.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
        button.layer.backgroundColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 0.75).cgColor

        let font = UIFont(name: ".SFUIText-Medium", size: 16.0) ?? UIFont.systemFont(ofSize: 16, weight: .medium)

        button.titleLabel?.font = font

        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.sizeToFit()

        return button
    }

    // MARK: - Button Events

    @objc public func btnLearnMoreClick() {
        videoViewDelegate?.learnMoreWasClicked()
    }

    @objc func btnWatchAgainClick() {
        avPlayer?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        avPlayer?.play()
        playbackState = .playing

        btnWatchAgain?.removeFromSuperview()
        btnWatchAgain = nil

        trackStartPlaybackEvents()
        notifyVideoDidStart()
    }

    @objc private func btnMuteClick(_ button: UIButton) {
        mute()
    }

    @objc private func btnUnmuteClick(_ button: UIButton) {
        unmute()
    }

    // MARK: - Interface

    @objc public func startPlayback() {
        Log.whereAmI()

        guard let player = avPlayer else {
            Log.error("Attempted to display a VideoView with no avPlayer")
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: Functions.sharedApplication)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: Functions.sharedApplication)

        updateControls()
        initTimeObserver()

        let isFirstPlayback = playbackState == .unstarted

        player.play()
        playbackState = .playing

        handleSkipDelay(adConfiguration?.videoControlsConfig.skipDelay ?? 0,
                        videoDuration: creative?.creativeModel.displayDurationInSeconds?.doubleValue ?? 0)

        if isFirstPlayback {
            trackStartPlaybackEvents()
            notifyVideoDidStart()
        }
    }

    func initTimeObserver() {
        // Create observer if it doesn't exist
        if timeObserver == nil {
            // Have the timeObserver fire 33 times per seconds
            let thirtyThreeFPS = CMTimeMake(value: 33, timescale: 1000)
            timeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: thirtyThreeFPS, queue: .main) { [weak self] _ in
                self?.handlePeriodicTimeEvent()
            }
        }

        if adConfiguration?.isRewarded ?? false {
            progressBar?.duration = CGFloat(progressBarDuration.doubleValue)
        }
    }

    @objc public func pause() {
        guard let player = avPlayer else {
            Log.error("Attempted to pause a VideoView with no avPlayer")
            return
        }

        if player.error != nil || playbackState == .finished {
            return
        }

        player.pause()
        playbackState = .paused
        eventManager?.trackEvent(.pause)
        if let creative {
            creative.creativeViewDelegate?.videoDidPause?(creative)
        }
    }

    @objc public func resume() {
        guard let player = avPlayer else {
            Log.error("Attempted to pause a VideoView with no avPlayer")
            return
        }

        if player.error != nil || playbackState == .finished {
            return
        }

        player.play()
        playbackState = .playing
        eventManager?.trackEvent(.resume)
        if let creative {
            creative.creativeViewDelegate?.videoDidResume?(creative)
        }
    }

    /// Pauses playback because the ad view left the viewport.
    /// Does nothing unless the video is currently playing, so that a pause
    /// made for another reason (clickthrough, background) is not overwritten.
    @objc public func pauseForVisibilityChange() {
        if playbackState != .playing {
            return
        }

        pause()
        playbackState = .pausedByVisibility
    }

    /// Resumes playback that was paused by `pauseForVisibilityChange`.
    /// Does nothing if the video was paused for any other reason.
    @objc public func resumeAfterVisibilityChange() {
        if playbackState != .pausedByVisibility {
            return
        }

        resume()
    }

    func stop() {
        stop(with: .skip)
    }

    @objc(stopWithTrackingEvent:)
    public func stop(with trackingEvent: TrackingEvent) {
        guard let player = avPlayer else {
            Log.error("No AVPlayer to stop")
            return
        }

        player.pause()
        playbackState = .finished
        eventManager?.trackEvent(trackingEvent)
        videoViewDelegate?.videoViewCompletedDisplay()
    }

    @objc public func mute() {
        isMuted = true

        if let creative {
            creative.creativeViewDelegate?.videoWasMuted?(creative)
        }
    }

    @objc public func unmute() {
        isMuted = false

        if let creative {
            creative.creativeViewDelegate?.videoWasUnmuted?(creative)
        }
    }

    // handles scenario when the user presses the close button before the video has ended.
    // Triggers the tracking event but purposely does not call videoViewCompletedDisplay method
    // since the video hasn't finished displaying.
    @objc(stopOnCloseButton:)
    public func stop(onCloseButton trackingEvent: TrackingEvent) {
        guard let player = avPlayer else {
            Log.error("No AVPlayer to stop")
            return
        }

        player.pause()
        playbackState = .paused
        eventManager?.trackEvent(trackingEvent)
    }

    // The ObjC call passed `nil` obstructions through to the OM session (which logged an error for each);
    // the Swift protocol takes non-optional views, so absent ones are skipped.
    @objc(addFriendlyObstructionsToMeasurementSession:)
    public func addFriendlyObstructions(to session: OMSession) {
        if let btnLearnMore {
            session.addFriendlyObstruction(btnLearnMore, purpose: .videoViewLearnMoreButton)
        }
        if let progressBar {
            session.addFriendlyObstruction(progressBar, purpose: .videoViewProgressBar)
        }
    }

    // MARK: - Observers

    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if keyPath == playerObserverKeyStatus {
            onPlayerStatusChanged()
        } else if keyPath == playerObserverKeyVolume && (object as? AVPlayer) === avPlayer {
            onPlayerVolumeChanged()
        } else if keyPath == audioSessionObserverKeyVolume {
            onDeviceVolumeChanged()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    @objc private func applicationWillResignActive(_ notification: Notification) {
        // If the video is not playing (e.g. already paused for a clickthrough overlay),
        // leave its state untouched - it will be resumed by whoever paused it.
        if playbackState != .playing {
            return
        }

        pause()
        playbackState = .pausedByBackground
    }

    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        if playbackState == .pausedByBackground {
            resume()
        }
    }

    @objc private func playerItemDidPlayToEndTime(_ notification: Notification) {
        handleDidPlayToEndTime()
    }

    private func completeVideoViewDisplay(with trackingEvent: TrackingEvent) {
        if playbackState != .finished {
            playbackState = .finished
            eventManager?.trackEvent(trackingEvent)
        }

        videoViewDelegate?.videoViewCompletedDisplay()

        if adConfiguration?.isRewarded ?? false {
            progressBar?.isHidden = true
        }

        let isBuiltInVideo = adConfiguration?.isBuiltInVideo ?? false
        let presentAsInterstitial = adConfiguration?.presentAsInterstitial ?? false
        let isRewarded = adConfiguration?.isRewarded ?? false
        let isAutoCloseOnCompletionEnabled = adConfiguration?.videoControlsConfig.isAutoCloseOnCompletionEnabled ?? false

        let shouldOfferReplay = isBuiltInVideo || (presentAsInterstitial && !isRewarded && !isAutoCloseOnCompletionEnabled)
        if shouldOfferReplay && !(creative?.creativeModel.hasCompanionAd ?? false) {
            // UI: need to give some time to hide the interstitial before showing the Watch Again
            if presentAsInterstitial {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.updateWatchAgainButton()
                }
            } else {
                updateWatchAgainButton()
            }
        }
    }

    func handleDidPlayToEndTime() {
        if playbackState == .finished {
            return
        }

        completeVideoViewDisplay(with: .complete)
    }

    /*
        This method is called by the avPlayer so we can do following:
            1) send events to track progress.
            2) compare VAST Duration with actual video playing time
    */
    @discardableResult
    func handlePeriodicTimeEvent() -> CGFloat {
        guard let player = avPlayer else {
            return 0
        }

        // Grab the time at the moment and the time that this media will end at
        let currentTime = player.currentTime()
        let endTime = CMTimeConvertScale(player.currentItem?.asset.duration ?? .invalid,
                                         timescale: currentTime.timescale,
                                         method: .roundHalfAwayFromZero)
        if CMTimeCompare(endTime, .zero) != 0 {
            // calculate the current percent complete
            let playbackPercent = CGFloat(currentTime.value) / CGFloat(endTime.value)

            if previousCompletionPercentage < 0.25 && playbackPercent >= 0.25 {
                eventManager?.trackEvent(.firstQuartile)
                Log.info("Video Playback Progress: PBMTrackingEventFirstQuartile")
            }

            if previousCompletionPercentage < 0.50 && playbackPercent >= 0.50 {
                eventManager?.trackEvent(.midpoint)
                Log.info("Video Playback Progress: PBMTrackingEventMidpoint")
            }

            if previousCompletionPercentage < 0.75 && playbackPercent >= 0.75 {
                eventManager?.trackEvent(.thirdQuartile)
                Log.info("Video Playback Progress: PBMTrackingEventThirdQuartile")
            }

            previousCompletionPercentage = playbackPercent
        }

        let playingTime = CGFloat(CMTimeGetSeconds(currentTime))
        let remainingTime = CGFloat(progressBarDuration.doubleValue) - playingTime

        if adConfiguration?.isRewarded ?? false {

            // Update progress bar
            if remainingTime >= 0 {
                progressBar?.updateProgress(remainingTime)
            } else {
                if progressBar?.superview != nil {
                    progressBar?.removeFromSuperview()
                }
            }
        }

        videoViewDelegate?.videoViewCurrentPlayingTime(NSNumber(value: Double(playingTime)))

        stopAdIfNeeded()

        return remainingTime
    }

    func requiredVideoDuration() -> CGFloat {
        // The countdown timer and video duration should correspond to the general rule of VAST ads:
        // We should use the shorter of the 2: VAST duration and video duration.

        let videoDuration = CGFloat(CMTimeGetSeconds(avPlayer?.currentItem?.asset.duration ?? .invalid))
        let vastDuration = CGFloat(creative?.creativeModel.displayDurationInSeconds?.doubleValue ?? 0)
        // Not `min(_:_:)`: with no player item `videoDuration` is NaN, and the ObjC `MIN` macro (`a < b ? a : b`)
        // then yields `vastDuration`, while `min` would yield NaN.
        return videoDuration < vastDuration ? videoDuration : vastDuration
    }

    private func trackStartPlaybackEvents() {
        eventManager?.trackEvent(.normal)

        eventManager?.trackEvent(.creativeView)

        // The duration is passed as the raw `CMTime.value` (not seconds), as in the ObjC original.
        eventManager?.trackStartVideo(duration: TimeInterval(avPlayer?.currentItem?.asset.duration.value ?? 0),
                                      volume: Double(avPlayer?.volume ?? 0))

        Log.info("Video Playback Progress: PBMTrackingEventCreativeView/PBMTrackingEventStart")
    }

    private func notifyVideoDidStart() {
        if let creative {
            creative.creativeViewDelegate?.videoDidStart?(creative)
        }
    }

    // pause avPlayer and notify videoViewCompletedDisplay if video reached the VAST Duration
    private func stopAdIfNeeded() {

        if playbackState == .finished {
            return
        }

        guard let player = avPlayer else {
            return
        }

        let vastDuration = creative?.creativeModel.displayDurationInSeconds?.doubleValue ?? 0
        if vastDuration == 0 {
            return
        }

        guard let currentItem = player.currentItem else {
            return
        }

        let playerCurrentTime = CMTimeGetSeconds(currentItem.currentTime())
        if playerCurrentTime >= vastDuration {
            player.pause()
            completeVideoViewDisplay(with: .complete)
        }
    }

    // MARK: - Helper Methods

    private func onPlayerStatusChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if let player = self.avPlayer, player.currentItem != nil {
                switch player.status {
                case .readyToPlay:
                    Log.info("readyToPlay")
                    self.videoViewDelegate?.videoViewReadyToDisplay()

                case .unknown:
                    Log.info("unknown (This is normal at launch)")

                case .failed:
                    let error: Error = player.currentItem?.error ?? PBMError.error(description: "Unknown Error")
                    self.videoViewDelegate?.videoViewFailedWithError(error)

                @unknown default:
                    break
                }
            }
        }
    }

    private func onPlayerVolumeChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let newVolume = self.avPlayer?.volume ?? 0
            if let initialVolume = self.isInitialVolumeTracked {
                if newVolume != initialVolume {
                    self.eventManager?.trackVolumeChanged(playerVolume: Double(newVolume),
                                                          deviceVolume: Double(AVAudioSession.sharedInstance().outputVolume))
                }
            } else {
                self.isInitialVolumeTracked = newVolume
            }
        }
    }

    private func onDeviceVolumeChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.eventManager?.trackVolumeChanged(playerVolume: Double(self.avPlayer?.volume ?? 0),
                                                  deviceVolume: Double(AVAudioSession.sharedInstance().outputVolume))
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer !== tapGestureRecognizer {
            return true
        }

        // The video controls (mute, Learn More, Watch Again) handle their own taps
        // and must not be reported as a click on the ad.
        var touchedView = touch.view
        while let view = touchedView, view !== self {
            if view is UIControl {
                return false
            }
            touchedView = view.superview
        }

        return true
    }

    // MARK: - Utilities

    private func setupTapRecognizer() {
        if let tapGestureRecognizer {
            removeGestureRecognizer(tapGestureRecognizer)
        }

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(recordTapEvent(_:)))
        tapGestureRecognizer = recognizer
        recognizer.cancelsTouchesInView = false
        addGestureRecognizer(recognizer)
        recognizer.delegate = self
    }

    @objc private func recordTapEvent(_ tap: UITapGestureRecognizer) {
        if tapGestureRecognizer !== tap {
            return
        }

        if enableOutstreamTapToExpand {
            videoViewDelegate?.videoViewWasTapped()
        } else {
            if !showLearnMore {
                btnLearnMoreClick()
            }
        }
    }

    func calculateProgressBarDuration() -> NSNumber {
        // Get video duration
        let videoDuration = requiredVideoDuration()

        // If creative is not rewarded or has companion ad - return video duration.
        if !(adConfiguration?.isRewarded ?? false) || (creative?.creativeModel.hasCompanionAd ?? false) {
            return NSNumber(value: Double(videoDuration))
        }

        let rewardedConfig = adConfiguration?.rewardedConfig

        var ortbPlaybackevent = rewardedConfig?.videoPlaybackevent
        let ortbVideoTime = rewardedConfig?.videoTime
        let ortbPostrewardedTime = rewardedConfig?.postRewardTime ?? 0

        // If both completion criteria are missing (playbackevent and time) - use default configuration
        if ortbPlaybackevent == nil && ortbVideoTime == nil {
            ortbPlaybackevent = rewardedConfig?.defaultVideoPlaybackEvent
        }

        var progressBarDuration = (ortbPostrewardedTime.doubleValue >= 0) ? ortbPostrewardedTime.doubleValue : 0.0

        // If completion criteria is playback event
        if let ortbPlaybackevent {
            let event = TrackingEventDescription.getEvent(with: ortbPlaybackevent)

            switch event {
            case .start:
                break
            case .firstQuartile:
                progressBarDuration += 0.25 * Double(videoDuration)
            case .midpoint:
                progressBarDuration += 0.5 * Double(videoDuration)
            case .thirdQuartile:
                progressBarDuration += 0.75 * Double(videoDuration)
            case .complete:
                progressBarDuration = Double(videoDuration)
            default:
                break
            }

            // if calculated value is bigger than video duration => return video duration
            return (progressBarDuration > Double(videoDuration)) ? NSNumber(value: Double(videoDuration)) : NSNumber(value: progressBarDuration)
        }

        // If completion criteria is time
        if let ortbVideoTime, ortbVideoTime.doubleValue >= 0.0 {
            progressBarDuration += ortbVideoTime.doubleValue

            // if calculated value is bigger than video duration => return video duration
            return (progressBarDuration > Double(videoDuration)) ? NSNumber(value: Double(videoDuration)) : NSNumber(value: progressBarDuration)
        }

        // Return video duration by default
        return NSNumber(value: Double(requiredVideoDuration()))
    }
}
