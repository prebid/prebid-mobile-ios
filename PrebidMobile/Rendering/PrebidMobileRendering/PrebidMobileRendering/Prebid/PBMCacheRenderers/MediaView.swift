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

fileprivate let defaultViewabilityPollingInterval: TimeInterval = 0.2

enum MediaViewState {
    case undefined, playbackNotStarted, playing, pausedByUser, pausedAuto, playbackFinished
}

public class MediaView: UIView, PBMPlayable, PBMAdViewManagerDelegate {
    
    @IBInspectable @objc public weak var delegate: MediaViewDelegate?
    
    @objc private(set) public var mediaData: MediaData?     // filled on successful load
    var mediaDataToLoad: MediaData?                         // present during the loading
    
    var adConfiguration: PBMAdConfiguration?
    
    var connection: PBMServerConnectionProtocol?
    var pollingInterval: TimeInterval?
    var scheduledTimerFactory: PBMScheduledTimerFactory?
    
    var vastTransactionFactory: PBMVastTransactionFactory?
    var adViewManager: PBMAdViewManager?
    
    var state: MediaViewState = .undefined
    var isPaused: Bool { state == .pausedAuto || state == .pausedByUser }
    var isActive: Bool { state == .playing || isPaused }
    
    @IBInspectable @objc public var autoPlayOnVisible = true {
        didSet {
            bindPlaybackToViewability = shouldBindPlaybackToViewability
        }
    }
    
    var viewabilityPlaybackBinder: PBMViewabilityPlaybackBinder?
    
    var bindPlaybackToViewability: Bool {
        get {
            viewabilityPlaybackBinder != nil
        }
        set(bindPlaybackToViewability) {
            if !bindPlaybackToViewability {
                // -> turn OFF
                viewabilityPlaybackBinder = nil;
                return;
            }
            if viewabilityPlaybackBinder != nil {
                // already ON
                return;
            }
            // -> turn ON
            let exposureProvider = PBMViewExposureProviders.visibilityAsExposure(for: self)
            let timerFactory = scheduledTimerFactory ?? Timer.pbmScheduledTimerFactory()
            viewabilityPlaybackBinder = PBMViewabilityPlaybackBinder(exposureProvider: exposureProvider,
                                                                     pollingInterval: pollingInterval ?? defaultViewabilityPollingInterval,
                                                                     scheduledTimerFactory: timerFactory,
                                                                     playable: self)
        }
    }
    
     var shouldBindPlaybackToViewability: Bool {
        autoPlayOnVisible && mediaData != nil
    }
    
    @objc public func load(_ mediaData: MediaData) {
        
        guard self.mediaData == nil else {
            reportFailureWithError(PBMError.replacingMediaDataInMediaView, markLoadingStopped: false)
            return
        }
        
        guard vastTransactionFactory == nil && mediaDataToLoad == nil else {
            // the Ad is being loaded
            return
        }
        
        guard let vasttag = mediaData.mediaAsset.video?.vasttag else {
            reportFailureWithError(PBMError.noVastTagInMediaData, markLoadingStopped: true)
            return
        }
        
        state = .undefined
        mediaDataToLoad = mediaData
        adConfiguration = PBMAdConfiguration()
        adConfiguration?.adFormat = .videoInternal
        adConfiguration?.isNative = true
        adConfiguration?.isInterstitialAd = false
        adConfiguration?.isBuiltInVideo = true
        

        adConfiguration?.clickHandlerOverride =  { onClickthroughExitBlock in
            onClickthroughExitBlock();
        }
        
        let connection = self.connection ?? PBMServerConnection.shared
        vastTransactionFactory = PBMVastTransactionFactory(connection: connection,
                                                                adConfiguration: adConfiguration!,
                                                                callback: { [weak self] transaction, error in
                if let transaction = transaction {
                    self?.display(transaction: transaction)
                } else {
                    self?.reportFailureWithError(error, markLoadingStopped: true)
                }
        })
        
        vastTransactionFactory?.load(withAdMarkup: vasttag)
    }
    
    @objc public func mute() {
        guard let adViewManager = adViewManager, isActive && !adViewManager.isMuted else {
            return
        }
        adViewManager.mute()
        delegate?.onMediaViewPlaybackMuted(self)
    }
    
    @objc public func unmute() {
        guard let adViewManager = adViewManager, isActive && adViewManager.isMuted else {
            return
        }
        adViewManager.unmute()
        delegate?.onMediaViewPlaybackUnmuted(self)
    }
    
    // MARK: - PBMPlayable protocol
    @objc public func canPlay() -> Bool {
        state == .playbackNotStarted
    }
    
    @objc public func play() {
        guard canPlay(), let adViewManager = adViewManager  else {
            return
        }
        state = .playing
        adViewManager.show()
        delegate?.onMediaViewPlaybackStarted(self)
    }

    @objc public func pause() {
        pauseWith(state: .pausedByUser)
    }
    
    @objc public func autoPause() {
        pauseWith(state: .pausedAuto)
    }
    
    func pauseWith(state: MediaViewState) {
        guard state == .playing, let adViewManager = adViewManager  else {
            return
        }
        self.state = state
        adViewManager.pause()
        delegate?.onMediaViewPlaybackPaused(self)
    }
    
    @objc public func canAutoResume() -> Bool {
        state == .pausedAuto
    }
    
    @objc public func resume() {
        guard isPaused, let adViewManager = adViewManager  else {
            return
        }
        state = .playing
        adViewManager.resume()
        delegate?.onMediaViewPlaybackResumed(self)
    }
    
    // MARK: - PBMAdViewManagerDelegate protocol
    
    @objc public func viewControllerForModalPresentation() -> UIViewController? {
        let mediaData = self.mediaData ?? mediaDataToLoad
        let provider = mediaData?.nativeAdHooks.viewControllerProvider
        return provider?()
    }
    
    @objc public func adLoaded(_ pbmAdDetails: PBMAdDetails) {
        state = .playbackNotStarted
        reportSuccess()
    }

    @objc public func failed(toLoad error: Error) {
        reportFailureWithError(error, markLoadingStopped: true)
    }

    @objc public func adDidComplete() {
        // FIXME: Implement
    }

    @objc public func videoAdDidFinish() {
        state = .playbackFinished
        delegate?.onMediaViewPlaybackFinished(self)
    }

    @objc public func videoAdWasMuted() {
        delegate?.onMediaViewPlaybackMuted(self)
    }

    @objc public func videoAdWasUnmuted() {
        delegate?.onMediaViewPlaybackUnmuted(self)
    }

    @objc public func adDidDisplay() {
        // FIXME: Implement
    }

    @objc public func adWasClicked() {
        // FIXME: Implement
    }

    @objc public func adViewWasClicked() {
        // FIXME: Implement
    }

    @objc public func adDidExpand() {
        // FIXME: Implement
    }

    @objc public func adDidCollapse() {
        // FIXME: Implement
    }

    @objc public func adDidLeaveApp() {
        // FIXME: Implement
    }

    @objc public func adClickthroughDidClose() {
        // FIXME: Implement
    }

    @objc public func adDidClose() {
        // FIXME: Implement
    }

    @objc public func displayView() -> UIView { self }
    
    // MARK: - Private Helpers

    func reportFailureWithError(_ error: Error?, markLoadingStopped: Bool) {
        if markLoadingStopped {
            vastTransactionFactory = nil
            mediaDataToLoad = nil
        }
        // FIXME: Implement
    }

    func reportSuccess() {
        mediaData = mediaDataToLoad
        vastTransactionFactory = nil
        bindPlaybackToViewability = shouldBindPlaybackToViewability
        delegate?.onMediaViewLoadingFinished(self)
    }

    func display(transaction: PBMTransaction) {
        let connection = self.connection ?? PBMServerConnection.shared
        adViewManager = PBMAdViewManager(connection: connection, modalManagerDelegate: nil)
        adViewManager?.adViewManagerDelegate = self
        adViewManager?.adConfiguration = adConfiguration!
        adViewManager?.autoDisplayOnLoad = false
        adViewManager?.handleExternalTransaction(transaction)
    }
}
