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

//MRAID spec URLs:
//https://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf
//https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf

import Foundation
import UIKit
import WebKit

@objc(PBMHTMLCreative) @_spi(PBMInternal) public
class HTMLCreative: AbstractCreativeImpl, WebViewDelegate {

    public var downloadBlock: ((URL, @escaping PBMDownloadDataCompletionClosure) -> Void)?

    var prebidWebView: WebView?
    var mraidController: MRAIDController?

    private let baseURL: URL?
    private var sdkConfiguration = Prebid.shared
    private var rewardedConfig: RewardedConfig?
    private var backgroundAwareTimer: BackgroundAwareTimer?

    // MARK: - Initialization

    @objc(initWithCreativeModel:transaction:)
    public required init(creativeModel: CreativeModel, transaction: Transaction) {
        // TODO: set proper base URL for prebid
        //Set the baseURL. This will cause relative URLs in the creative to inherit the URL scheme used.
        baseURL = nil

        super.init(creativeModel: creativeModel, transaction: transaction)

        rewardedConfig = adConfiguration?.rewardedConfig
    }

    convenience init(creativeModel: CreativeModel,
                     transaction: Transaction,
                     webView: WebView?,
                     sdkConfiguration: Prebid) {
        self.init(creativeModel: creativeModel, transaction: transaction)

        self.sdkConfiguration = sdkConfiguration

        if let webView {
            prebidWebView = webView
        }
    }

    // MARK: - AbstractCreative

    public override var isOpened: Bool {
        // Identity comparison: the ObjC original compared the state pointers.
        clickthroughVisible || (mraidController != nil && mraidController?.mraidState !== MRAIDState.defaultState)
    }

    public override var displayInterval: NSNumber? {
        creativeModel.displayDurationInSeconds
    }

    public override func setupView() {
        super.setupView()

        guard let html = creativeModel.html else {
            onResolutionFailed(PBMError.error(description: "No HTML in creative data"))
            return
        }

        //check if we receive vast data instead of banner
        if hasVastTag(html) {
            onResolutionFailed(PBMError.error(description: "Wrong data format (VAST) detected for display ad request"))
            return
        }

        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(creativeModel.width), height: CGFloat(creativeModel.height))
        let webView: WebView
        if let existingWebView = prebidWebView {
            existingWebView.frame = rect
            webView = existingWebView
        } else {
            webView = WebView(frame: rect, creativeModel: creativeModel, targeting: Targeting.shared)
            prebidWebView = webView
        }

        if creativeModel.isCompanionAd {
            webView.rewardedAdURL = rewardedConfig?.endcardEvent
        } else {
            webView.rewardedAdURL = rewardedConfig?.bannerEvent
        }

        webView.delegate = self
        view = webView

        loadHTMLToWebView()
    }

    func hasVastTag(_ html: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: "<(\\s*)VAST(\\s{1,})version(\\s*)=", options: [])
        let range = NSRange(location: 0, length: (html as NSString).length)
        let numberOfMatches = regex?.numberOfMatches(in: html, options: [], range: range) ?? 0

        return numberOfMatches > 0
    }

    public override func display(rootViewController viewController: UIViewController) {
        //Either these constraints are redundant or the initWithFrame is.
        if let prebidWebView {
            prebidWebView.PBMAddCropAndCenterConstraints(initialWidth: prebidWebView.frame.size.width,
                                                         initialHeight: prebidWebView.frame.size.height)
        }
        prebidWebView?.prepareForMRAID(withRootViewController: viewController)

        super.display(rootViewController: viewController)

        if creativeModel.isCompanionAd {
            eventManager.trackEvent(.creativeView)

            // For rewarded we have different logic for display completion.
            // See `setupRewardTimerIfNeeded` for more details
            if !(adConfiguration?.isRewarded ?? false) {
                modalManager?.creativeDisplayCompleted(self)
            }
        }

        viewabilityTracker?.start()
    }

    override func onAdDisplayed() {
        super.onAdDisplayed()
        setupDisplayTimer()
        setupRewardTimerIfNeeded()
    }

    private func setupDisplayTimer() {
        //Banners display for a set amount of time and then signal creativeDidComplete.
        //Interstitials display for as long as the user is enjoying their presence.
        if adConfiguration?.presentAsInterstitial ?? false {
            return
        }

        let displayInterval = displayInterval?.doubleValue ?? 0

        if displayInterval <= 0 {
            //Treat as "display forever"
            return
        }

        // `Functions.dispatchTimeAfterTimeInterval` turned a `NaN` interval into "now"; `DispatchTime + NaN` would mean "never".
        DispatchQueue.main.asyncAfter(deadline: .now() + (displayInterval.isNaN ? 0 : displayInterval)) { [weak self] in
            guard let self else { return }

            //If its open, don't count this as a creativeDidComplete. Re-start the display timer.
            if self.isOpened {
                self.setupDisplayTimer()
            } else {
                self.creativeViewDelegate?.creativeDidComplete(self)
            }
        }
    }

    private func setupRewardTimerIfNeeded() {
        // NOTE: Rewarded API only
        // Signal to the application that the user has earned the reward after
        // the certain period of time that the ad is on the screen.
        if !(adConfiguration?.isRewarded ?? false) {
            return
        }

        guard let rewardedConfig else {
            return
        }

        // `-intValue` is a 32-bit `int` in ObjC; `int32Value` keeps the wrapping of out-of-range numbers (`intValue` in Swift is 64-bit).
        let rewardNotificationInterval: TimeInterval
        if creativeModel.isCompanionAd {
            let videoEndcardTime = rewardedConfig.endcardTime
            let defaultEndcardTime = rewardedConfig.defaultCompletionTime
            rewardNotificationInterval = TimeInterval((videoEndcardTime ?? defaultEndcardTime).int32Value)
        } else {
            let bannerEndcardTime = rewardedConfig.bannerTime
            let defaultBannerTime = rewardedConfig.defaultCompletionTime
            rewardNotificationInterval = TimeInterval((bannerEndcardTime ?? defaultBannerTime).int32Value)
        }

        backgroundAwareTimer = BackgroundAwareTimer()

        // Track user did earn reward
        backgroundAwareTimer?.startTimer(with: rewardNotificationInterval) { [weak self] in
            guard let self else { return }

            if !self.creativeModel.userHasEarnedReward {
                self.creativeModel.userHasEarnedReward = true
                self.creativeViewDelegate?.creativeDidSendRewardedEvent(self)
            }

            // Track post reward event
            self.setupPostRewardTimer()
        }
    }

    private func setupPostRewardTimer() {
        // NOTE: Rewarded API only
        // Signal to the SDK about the post reward event in order to execute close ad logic.
        if !(adConfiguration?.isRewarded ?? false) {
            return
        }

        guard let rewardedConfig else {
            return
        }

        let postRewardTime = rewardedConfig.postRewardTime?.doubleValue ?? 0

        if postRewardTime < 0.0 || !creativeModel.userHasEarnedReward || creativeModel.userPostRewardEventSent {
            return
        }

        backgroundAwareTimer = BackgroundAwareTimer()

        // Track user did earn reward
        backgroundAwareTimer?.startTimer(with: postRewardTime) { [weak self] in
            guard let self else { return }

            if !self.creativeModel.userPostRewardEventSent {
                self.creativeModel.userPostRewardEventSent = true
                self.modalManager?.creativeDisplayCompleted(self)
            }
        }
    }

    // The session must be created only after WebView finishes loading
    public override func createOpenMeasurementSession() {

        if !Thread.current.isMainThread {
            Log.error("Open Measurement session can only be created on the main thread")
            return
        }

        // ObjC messaged a nil transaction (no-op, nothing created).
        guard let transaction else {
            return
        }

        // ObjC passed a nil web view on to the wrapper, whose session context then fails and returns nil.
        transaction.measurementSession = prebidWebView.flatMap {
            transaction.measurementWrapper.initializeWebViewSession($0.internalWebView, contentUrl: "")
        }

        // The ObjC `isKindOfClass:PBMOpenMeasurementSession` gate cannot be written from Swift; see docs/migration/notes/agent-3.md.
        if let session = transaction.measurementSession {
            session.start()
        }
    }

    override func onWillTrackImpression() {
        super.onWillTrackImpression()
        eventManager.trackEvent(.loaded)
    }

    private func loadHTMLToWebView() {

        guard let html = creativeModel.html else {
            return
        }

        let htmlWithBodyAndHTMLTags = HTMLFormatter.ensureHTMLHasBodyAndHTMLTags(html)

        var error: NSError?
        let htmlWithMeasurementJS = transaction?.measurementWrapper.injectJSLib(htmlWithBodyAndHTMLTags, error: &error)
        if let error {
            Log.error("PBMWebView can't inject Open Measurement JS lib with error: \(error.localizedDescription)")
        }

        prebidWebView?.loadHTML(htmlWithMeasurementJS ?? htmlWithBodyAndHTMLTags,
                                baseURL: baseURL,
                                injectMraidJs: true)
    }

    // MARK: - WebViewDelegate

    public func webViewReadyToDisplay(_ webView: WebView) {
        Log.info("PBMWebView is ready to display")

        onResolutionCompleted()
    }

    public func webView(_ webView: WebView, failedToLoadWithError error: Error) {
        Log.error(error.localizedDescription)
    }

    public func webView(_ webView: WebView, receivedClickthroughLink url: URL) {
        handleClickthrough(url, sdkConfiguration: sdkConfiguration)
    }

    // The ObjC `@try/@catch (NSException)` around this is not ported: `MRAIDController` reports its failures itself and nothing here can raise.
    public func webView(_ webView: WebView, receivedMRAIDLink url: URL) {
        guard view is WebView else {
            Log.warn("Could not cast creative view to PBMWebView")
            return
        }

        if mraidController == nil {
            mraidController = MRAIDController(creative: self,
                                              viewControllerForPresenting: viewControllerForPresentingModals,
                                              webView: prebidWebView,
                                              creativeViewDelegate: creativeViewDelegate,
                                              downloadBlock: downloadBlock)
        }
        mraidController?.webView(webView, handleMRAIDURL: url)
    }

    public func webView(_ webView: WebView, receivedRewardedEventLink url: URL) {
        if !creativeModel.userHasEarnedReward {
            creativeViewDelegate?.creativeDidSendRewardedEvent(self)
            creativeModel.userHasEarnedReward = true

            setupPostRewardTimer()
        }
    }

    // MARK: - ModalManager events

    public override func modalManagerDidFinishPop(_ state: ModalState?) {

        // TODO: Refactor
        // This method illustrates very precisely that we should have different creatives
        // for Banner/Interstitial/MRAID ads.
        // We should use OOP approach for logic encapsulation instead of 'if' logic.

        // Clickthrough
        if clickthroughVisible {
            creativeViewDelegate?.creativeClickthroughDidClose(self)
            clickthroughVisible = false

            return
        }

        // EndCard
        if creativeModel.isCompanionAd {
            // Dismiss parent VideoCreative
            if let dismissParent = transaction?.getFirstCreative()?.dismissInterstitialModalState {
                dismissParent()
            }
        }

        let presentAsInterstitial = adConfiguration?.presentAsInterstitial ?? false

        if let mraidController {
            creativeViewDelegate?.creativeReadyToReimplant(self)
            mraidController.updateForClose(presentAsInterstitial)
        }

        //Creative presented as Interstitial
        if presentAsInterstitial {
            creativeViewDelegate?.creativeDidComplete(self)
        }

        creativeViewDelegate?.creativeInterstitialDidClose(self)
    }

    public override func modalManagerDidLeaveApp(_ state: ModalState?) {
        creativeViewDelegate?.creativeInterstitialDidLeaveApp(self)
    }

    // MARK: - Helper Methods

    // Like the ObjC override, the `sdkConfiguration` argument is ignored in favour of the creative's own.
    override func handleClickthrough(_ url: URL?,
                                     sdkConfiguration: Prebid,
                                     completionHandler: @escaping (Bool) -> Void,
                                     onExit onClickthroughExitBlock: @escaping VoidBlock) {
        super.handleClickthrough(url,
                                 sdkConfiguration: self.sdkConfiguration,
                                 completionHandler: { [weak self] success in
            guard let self else { return }

            if success {
                self.creativeViewDelegate?.creativeWasClicked(self)
                if self.creativeModel.isCompanionAd {
                    self.eventManager.trackEvent(.companionClick)
                } else {
                    self.eventManager.trackEvent(.click)
                }
            }

            completionHandler(success)
        }, onExit: onClickthroughExitBlock)
    }
}
