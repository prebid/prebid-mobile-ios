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

import Foundation
import UIKit

// ObjC class name preserved so Factory.AdViewManagerType = NSClassFromString("PBMAdViewManager_Objc") resolves at runtime
@objc(PBMAdViewManager_Objc) @_spi(PBMInternal) public
class AdViewManagerImpl: NSObject, AdViewManager {

    public var adConfiguration: AdConfiguration
    public var modalManager: ModalManager
    public weak var adViewManagerDelegate: AdViewManagerDelegate?
    public var autoDisplayOnLoad: Bool

    public weak var currentCreative: AbstractCreative?
    public var externalTransaction: Transaction?

    private let serverConnection: PrebidServerConnectionProtocol
    private var videoInterstitialDidClose = false

    private var currentTransaction: Transaction? {
        externalTransaction
    }

    private var isInterstitial: Bool {
        adConfiguration.presentAsInterstitial
    }

    private var isRewarded: Bool {
        adConfiguration.isRewarded
    }

    public required init(connection: PrebidServerConnectionProtocol, modalManagerDelegate: ModalManagerDelegate?) {
        autoDisplayOnLoad = true
        serverConnection = connection
        modalManager = ModalManager(delegate: modalManagerDelegate)
        adConfiguration = AdConfiguration()
        super.init()
    }

    // MARK: - API

    public func revenueForNextCreative() -> String? {
        guard let currentTransaction else {
            return nil
        }

        guard let currentCreative else {
            return currentTransaction.getFirstCreative()?.creativeModel.revenue
        }

        return currentTransaction.revenueForCreative(after: currentCreative)
    }

    public func isAbleToShowCurrentCreative() -> Bool {
        if currentCreative == nil {
            Log.error("No creative to display")
            return false
        }

        if isInterstitial && adViewManagerDelegate?.viewControllerForModalPresentation() == nil {
            Log.error("viewControllerForModalPresentation returned nil")
            return false
        }

        return true
    }

    public func show() {
        guard isAbleToShowCurrentCreative() else {
            return
        }

        guard let viewController = adViewManagerDelegate?.viewControllerForModalPresentation() else {
            Log.error("viewControllerForModalPresentation is nil. Check the implementation of Ad View Delegate.")
            return
        }

        currentCreative?.creativeViewDelegate = self

        if isInterstitial {
            guard let displayProperties = adViewManagerDelegate?.interstitialDisplayProperties else {
                Log.error("interstitialDisplayProperties is nil. Check the implementation of Ad View Delegate.")
                return
            }

            // set interstitial display properties from ad configuration parameters
            InterstitialLayoutConfigurator.configureProperties(with: adConfiguration, displayProperties: displayProperties)
            // we need to force orientation if device is not in the expected one
            if displayProperties.interstitialLayout == .landscape {
                modalManager.forceOrientation(.landscapeLeft)
            } else if displayProperties.interstitialLayout == .portrait {
                modalManager.forceOrientation(.portrait)
            }
            currentCreative?.showAsInterstitial(fromRootViewController: viewController, displayProperties: displayProperties)
        } else {
            guard let creativeView = currentCreative?.view else {
                Log.error("Creative has no view")
                return
            }

            if Thread.isMainThread {
                displayCreativeView(creativeView, rootViewController: viewController)
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }

                    displayCreativeView(creativeView, rootViewController: viewController)
                }
            }
        }
    }

    public func pause() {
        currentCreative?.pause()
    }

    public func resume() {
        currentCreative?.resume()
    }

    public func mute() {
        currentCreative?.mute()
    }

    public func unmute() {
        currentCreative?.unmute()
    }

    public var isMuted: Bool {
        currentCreative?.isMuted ?? false
    }

    public func handleExternalTransaction(_ transaction: Transaction) {
        externalTransaction = transaction
        onTransactionIsReady(transaction)
    }

    // MARK: - CreativeViewDelegate

    public func videoDidStart(_ creative: AbstractCreative) {
        adViewManagerDelegate?.videoAdDidStart?()
    }

    public func videoCreativeDidComplete(_ creative: AbstractCreative) {
        adViewManagerDelegate?.videoAdDidFinish?()
    }

    public func videoWasMuted(_ creative: AbstractCreative) {
        adViewManagerDelegate?.videoAdWasMuted?()
    }

    public func videoWasUnmuted(_ creative: AbstractCreative) {
        adViewManagerDelegate?.videoAdWasUnmuted?()
    }

    public func videoDidPause(_ creative: AbstractCreative) {
        adViewManagerDelegate?.videoAdDidPause?()
    }

    public func videoDidResume(_ creative: AbstractCreative) {
        adViewManagerDelegate?.videoAdDidResume?()
    }

    public func creativeDidComplete(_ creative: AbstractCreative) {
        Log.whereAmI()

        if !adConfiguration.isBuiltInVideo, let creativeView = currentCreative?.view, creativeView.superview != nil {
            creativeView.removeFromSuperview()
        }

        // When a creative completes, show the next one in the transaction
        if let nextCreative = creativeAfterCurrent(in: currentTransaction), !videoInterstitialDidClose {
            setupCreative(nextCreative)
            return
        }

        // In the case of 300x250 video, the finish of playback does not mean the completion of the ad.
        // User could Watch Again the same creative so it still should be alive.
        if adConfiguration.isBuiltInVideo {
            return
        }

        // If there is no next creative, the transaction is complete.
        adViewManagerDelegate?.adDidComplete()
    }

    public func creativeDidDisplay(_ creative: AbstractCreative) {
        videoInterstitialDidClose = false
        adViewManagerDelegate?.adDidDisplay()
    }

    public func creativeWasClicked(_ creative: AbstractCreative) {
        adViewManagerDelegate?.adWasClicked()
    }

    public func creativeInterstitialDidClose(_ creative: AbstractCreative) {
        if adConfiguration.winningBidAdFormat == .video {
            videoInterstitialDidClose = true
        }

        adViewManagerDelegate?.adDidClose()
    }

    public func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {
        adViewManagerDelegate?.adDidLeaveApp()
    }

    public func creativeClickthroughDidClose(_ creative: AbstractCreative) {
        adViewManagerDelegate?.adClickthroughDidClose()
    }

    public func creativeMraidDidCollapse(_ creative: AbstractCreative) {
        adViewManagerDelegate?.adDidCollapse()
    }

    public func creativeMraidDidExpand(_ creative: AbstractCreative) {
        adViewManagerDelegate?.adDidExpand()
    }

    // TODO: Describe what implanting means
    public func creativeReadyToReimplant(_ creative: AbstractCreative) {
        guard let creativeView = creative.view else {
            return
        }

        if !isInterstitial {
            adViewManagerDelegate?.displayView?.addSubview(creativeView)
        }

        creativeView.addFillSuperviewConstraints()
    }

    public func creativeViewWasClicked(_ creative: AbstractCreative) {
        // POTENTIAL BUG: if publisher did not provide the controller for modal presentation
        // and we did not check it before 'show'
        // the video will disappear from UI and won't appear in the interstitial controller.
        if isAbleToShowCurrentCreative() && !adConfiguration.presentAsInterstitial {
            // IMPORTANT: we have to remove PBMVideoAdView from super view before invoking the show method.
            // Otherwise, the video won't be displayed.

            currentCreative?.view?.removeFromSuperview()

            adConfiguration.forceInterstitialPresentation = NSNumber(value: true)
            currentCreative?.eventManager.trackEvent(.expand)
            show()

            adViewManagerDelegate?.adViewWasClicked()
        }
    }

    public func creativeFullScreenDidFinish(_ creative: AbstractCreative) {
        adConfiguration.forceInterstitialPresentation = nil
        currentCreative?.creativeModel.adConfiguration?.forceInterstitialPresentation = nil
        currentCreative?.eventManager.trackEvent(.normal)

        if let creativeView = currentCreative?.view {
            adViewManagerDelegate?.displayView?.addSubview(creativeView)
        }

        if let viewController = adViewManagerDelegate?.viewControllerForModalPresentation() {
            currentCreative?.display(rootViewController: viewController)
        }

        adViewManagerDelegate?.adDidClose()
    }

    /// NOTE: Rewarded API only
    public func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {
        if isInterstitial && isRewarded {
            adViewManagerDelegate?.adDidSendRewardedEvent?()
        }
    }

    // MARK: - Utility Functions

    // Do not load an ad if the current one is "opened"
    // Is the current creative an PBMHTMLCreative? If so, is a clickthrough browser visible/MRAID in Expanded mode?
    public var isCreativeOpened: Bool {
        guard currentTransaction != nil else {
            return false
        }

        // TODO: When is there ever a transaction but no current creative?
        guard let currentCreative else {
            return false
        }

        return currentCreative.isOpened
    }

    // Changes self.creative and calls show & setupRefreshTimer if possible.
    public func setupCreative(_ creative: AbstractCreative) {
        setupCreative(creative, withThread: Thread.current)
    }

    public func setupCreative(_ creative: AbstractCreative, withThread thread: ThreadProtocol) {
        guard thread.isMainThread else {
            Log.error("setupCreative must be called on the main thread")
            return
        }

        let transaction = currentTransaction
        currentCreative?.view?.isHidden = true
        currentCreative = creative
        if let creativeAdConfiguration = creative.creativeModel.adConfiguration {
            adConfiguration = creativeAdConfiguration
        }
        autoDisplayOnLoad = !(currentCreative?.creativeModel.adConfiguration?.isInterstitialAd ?? false)
        if autoDisplayOnLoad || currentCreative !== transaction?.getFirstCreative() {
            show()
        }
    }

    // MARK: - Internal Methods

    private func creativeAfterCurrent(in transaction: Transaction?) -> AbstractCreative? {
        guard let currentCreative else {
            return transaction?.getFirstCreative()
        }

        return transaction?.getCreative(after: currentCreative)
    }

    private func displayCreativeView(_ creativeView: UIView, rootViewController: UIViewController) {
        adViewManagerDelegate?.displayView?.addSubview(creativeView)
        currentCreative?.display(rootViewController: rootViewController)
    }

    private func onTransactionIsReady(_ transaction: Transaction) {
        for creative in transaction.creatives {
            creative.modalManager = modalManager
        }

        // TODO: need __block modifier on transaction?
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            // If we're currently displaying a creative, bail.
            if currentCreative != nil {
                return
            }

            // Otherwise attempt to show the creative.
            if let firstCreative = transaction.getFirstCreative() {
                setupCreative(firstCreative)
            } else {
                // ObjC called setupCreative:nil here, which reset autoDisplayOnLoad and ended in show() logging "No creative to display".
                // The Swift creative parameter is non-optional, so replay the observable part of that path.
                autoDisplayOnLoad = true
                show()
            }

            // ObjC passed nil here when the model had no adDetails (nothing sets it today) and still fired the callback;
            // the Swift delegate parameter is non-optional, so fall back to an empty AdDetails to keep the callback firing.
            let adDetails = transaction.getAdDetails() ?? AdDetails(rawResponse: "", transactionId: "")
            adViewManagerDelegate?.adLoaded(adDetails)
        }
    }
}
