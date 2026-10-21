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
import StoreKit
import UIKit

// `AbstractCreative` is the name of the protocol, so the class keeps its ObjC name as the Swift name with an `Impl` suffix,
// like `ModalStateImpl` / `AdViewManagerImpl`.
@objc(PBMAbstractCreative_Objc)
class AbstractCreativeImpl: NSObject, AbstractCreative, SKStoreProductViewControllerDelegate {

    // MARK: - AbstractCreative

    public private(set) weak var transaction: Transaction?
    public let creativeModel: CreativeModel
    public let eventManager: EventManager

    public var skOverlayManager: SKOverlayManager?
    public var view: UIView?
    public var clickthroughVisible = false
    public var modalManager: ModalManager?
    public var dispatchQueue: DispatchQueue
    public var viewabilityTracker: CreativeViewabilityTracker?
    public private(set) var dismissInterstitialModalState: VoidBlock?
    public var isDownloaded = false

    public weak var creativeResolutionDelegate: CreativeResolutionDelegate?
    public weak var creativeViewDelegate: CreativeViewDelegate?
    public weak var viewControllerForPresentingModals: UIViewController?

    // MARK: - Internal state

    var skStoreProductViewControllerExitBlock: VoidBlock?
    var pendingModalStatePop: ModalState?
    var safariOpener: SafariVCOpener?

    private var adWasShown = false

    var adConfiguration: AdConfiguration? {
        creativeModel.adConfiguration
    }

    // MARK: - Init

    public required init(creativeModel: CreativeModel, transaction: Transaction) {
        self.creativeModel = creativeModel
        self.transaction = transaction
        dispatchQueue = DispatchQueue(label: "PBMAbstractCreative")
        eventManager = EventManager()

        super.init()

        if let eventTracker = creativeModel.eventTracker {
            eventManager.registerTracker(eventTracker)
        } else {
            Log.error("Creative model must be provided with event tracker")
        }

        // The deployment target is iOS 15, so the `#available(iOS 14.5, *)` check of the ObjC original always passed.
        if let skadn = transaction.bid?.skadn {
            if let impression = SkadnParametersManager.getSkadnImpression(for: skadn) {
                let skadnTracker = SkadnEventTracker(with: impression)
                eventManager.registerTracker(skadnTracker)
            }
        }

        let internalEventTracker = PrebidServerEventTracker(serverEvents: [])

        if let impURL = transaction.bid?.events?.imp {
            let impEvent = ServerEvent(url: impURL, expectedEventType: .impression)
            internalEventTracker.addServerEvents([impEvent])
        }

        if let winURL = transaction.bid?.events?.win {
            let winEvent = ServerEvent(url: winURL, expectedEventType: .prebidWin)
            internalEventTracker.addServerEvents([winEvent])
        }

        if let burl = transaction.bid?.burl {
            let billingEvent = ServerEvent(url: burl, expectedEventType: .impression)
            internalEventTracker.addServerEvents([billingEvent])
        }

        if !internalEventTracker.serverEvents.isEmpty {
            eventManager.registerTracker(internalEventTracker)
        }

        // Track win event immediately
        eventManager.trackEvent(.prebidWin)
    }

    deinit {
        viewabilityTracker?.stop()

        if let skOverlayManager {
            skOverlayManager.dismissSKOverlay()
            self.skOverlayManager = nil
        }

        viewabilityTracker = nil
        Log.whereAmI()
    }

    // MARK: - Properties

    public var isOpened: Bool {
        false
    }

    public var displayInterval: NSNumber? {
        nil
    }

    // MARK: - Public

    public func setupView() {
        setupView(withThread: Thread.current)
    }

    func setupView(withThread thread: ThreadProtocol) {
        if !thread.isMainThread {
            Log.error("Attempting to set up view on background thread")
        }
    }

    public func display(rootViewController: UIViewController) {
        viewControllerForPresentingModals = rootViewController
        if adConfiguration?.isInterstitialAd ?? false { // raw value access intended
            adWasShown = false
        }

        if !adWasShown {
            viewabilityTracker = Factory.createCreativeViewabilityTracker(creative: self)
        }

        let skadnInfo = transaction?.bid?.skadn

        let showSKOverlay = !creativeModel.hasCompanionAd
            && (adConfiguration?.isInterstitialAd ?? false)
            && ((creativeModel.isCompanionAd && skadnInfo?.skoverlay?.endcarddelay != nil)
                || (!creativeModel.isCompanionAd && skadnInfo?.skoverlay?.delay != nil))

        if showSKOverlay, let skadnInfo {
            skOverlayManager = SKOverlayManager(viewControllerForPresentation: rootViewController)
            skOverlayManager?.presentSKOverlay(with: skadnInfo, isCompanionAd: creativeModel.isCompanionAd)
        }
    }

    public func showAsInterstitial(fromRootViewController uiViewController: UIViewController,
                                   displayProperties: InterstitialDisplayProperties) {
        //This containerView will be stretched to fit the available screen.
        let containerView = UIView(frame: .zero)
        if let view {
            containerView.addSubview(view)
        }

        displayProperties.closeDelayLeft = displayProperties.closeDelay

        //Create ModalState and push

        let state = Factory.createModalState(
            view: containerView,
            adConfiguration: creativeModel.adConfiguration,
            displayProperties: displayProperties,
            onStatePopFinished: { [weak self] poppedState in
                guard let self else { return }

                if self.skStoreProductViewControllerExitBlock != nil {
                    self.pendingModalStatePop = poppedState
                }

                self.modalManagerDidFinishPop(poppedState)
            },
            onStateHasLeftApp: { [weak self] leavingState in
                guard let self else { return }

                self.modalManagerDidLeaveApp(leavingState)
            },
            nextOnStatePopFinished: nil,
            nextOnStateHasLeftApp: nil,
            onModalPushedBlock: nil
        )

        // An interstitial end card replaces the finished video's state, so its close is
        // reported only after the modal has dismissed.
        let shouldReplace = creativeModel.isCompanionAd && (creativeModel.adConfiguration?.isInterstitialAd ?? false)

        // `self` is captured strongly, like the ObjC block (no `__weak`).
        dismissInterstitialModalState = modalManager?.pushModal(state,
                                                                fromRootViewController: uiViewController,
                                                                animated: true,
                                                                shouldReplace: shouldReplace,
                                                                completionHandler: {
            self.display(rootViewController: uiViewController)
            self.modalManager?.modalViewController?.addFriendlyObstructions(toMeasurementSession: self.transaction?.measurementSession)
        })
    }

    // MARK: - Clickthrough handling

    public func handleClickthrough(_ url: URL) {
        // Call overridden method with empty non-null closures
        handleClickthrough(url,
                           sdkConfiguration: Prebid.shared,
                           completionHandler: { _ in },
                           onExit: {})
    }

    // The `url` parameters of the internal overloads stay optional: `PBMVideoCreative` passed `[NSURL URLWithString:clickThroughURL]`, which can be `nil`.

    func handleClickthrough(_ url: URL?, sdkConfiguration: Prebid) {
        handleClickthrough(url,
                           sdkConfiguration: sdkConfiguration,
                           completionHandler: { _ in },
                           onExit: {})
    }

    func handleClickthrough(_ url: URL?,
                            completionHandler: @escaping (Bool) -> Void,
                            onExit onClickthroughExitBlock: @escaping VoidBlock) {
        handleClickthrough(url,
                           sdkConfiguration: Prebid.shared,
                           completionHandler: completionHandler,
                           onExit: onClickthroughExitBlock)
    }

    func handleClickthrough(_ url: URL?,
                            sdkConfiguration: Prebid,
                            completionHandler: @escaping (Bool) -> Void,
                            onExit onClickthroughExitBlock: @escaping VoidBlock) {

        if let clickHandlerOverride = adConfiguration?.clickHandlerOverride {
            completionHandler(true)
            clickHandlerOverride(onClickthroughExitBlock)
            return
        }

        var clickthroughOpened = false
        var skadnetProductParameters: [String: Any]?

        if let skadn = transaction?.bid?.skadn {
            skadnetProductParameters = SkadnParametersManager.getSkadnProductParameters(for: skadn)
        }

        if let skadnetProductParameters {
            clickthroughOpened = handleProductClickthrough(url,
                                                           productParams: skadnetProductParameters,
                                                           onExit: onClickthroughExitBlock)
        } else {

            if handleDeepLinkIfNeeded(url,
                                      sdkConfiguration: sdkConfiguration,
                                      completionHandler: completionHandler,
                                      onExit: onClickthroughExitBlock) {
                return
            }

            clickthroughOpened = handleNormalClickthrough(url,
                                                          sdkConfiguration: sdkConfiguration,
                                                          onExit: onClickthroughExitBlock)
        }

        completionHandler(clickthroughOpened)

        if !clickthroughOpened {
            onClickthroughExitBlock()
        }
    }

    //checks the given URL and process it if it's a deep link
    //return true if the given URL is deeplink
    func handleDeepLinkIfNeeded(_ url: URL?,
                                sdkConfiguration: Prebid,
                                completionHandler: @escaping (Bool) -> Void,
                                onExit onClickthroughExitBlock: @escaping VoidBlock) -> Bool {
        var effectiveURL = url
        // `NSURL(string:)`, not `URL(string:)`: the ObjC original accepted what `NSURL` accepts (an empty string is a valid, empty `NSURL`).
        if let targetURL = creativeModel.targetURL, let overrideURL = NSURL(string: targetURL) as URL? {
            effectiveURL = overrideURL
        }

        guard let effectiveURL, DeepLinkPlusHelper.isDeepLinkPlusURL(effectiveURL) else {
            return false
        }

        DeepLinkPlusHelper.tryHandleDeepLinkPlus(effectiveURL) { [weak self] visited, fallbackURL, trackingURLs in
            guard let self else { return }

            if visited {
                completionHandler(true)
                onClickthroughExitBlock()
            } else if let fallbackURL {
                let clickthroughOpened = self.handleNormalClickthrough(fallbackURL,
                                                                       sdkConfiguration: sdkConfiguration,
                                                                       onExit: onClickthroughExitBlock)

                completionHandler(clickthroughOpened)

                if clickthroughOpened {
                    if let trackingURLs {
                        DeepLinkPlusHelper.visitTrackingURLs(trackingURLs)
                    }
                } else {
                    onClickthroughExitBlock()
                }
            } else {
                completionHandler(false)
                onClickthroughExitBlock()
            }
        }

        return true
    }

    //Returns true if the clickthrough is presented
    @discardableResult
    func handleNormalClickthrough(_ url: URL?,
                                  sdkConfiguration: Prebid,
                                  onExit onClickthroughExitBlock: @escaping VoidBlock) -> Bool {

        safariOpener = SafariVCOpener(
            sdkConfiguration: sdkConfiguration,
            modalManager: modalManager,
            viewControllerProvider: { [weak self] in
                self?.viewControllerForPresentingModals
            },
            measurementSessionProvider: { [weak self] in
                self?.transaction?.measurementSession
            },
            onWillLoadURLInClickthrough: { [weak self] in
                self?.clickthroughVisible = true
            },
            onWillLeaveAppBlock: { [weak self] in
                guard let self else { return }

                self.creativeViewDelegate?.creativeInterstitialDidLeaveApp(self)
            },
            onClickthroughPoppedBlock: { [weak self] poppedState in
                guard let self else { return }

                self.modalManagerDidFinishPop(poppedState)
            },
            onDidLeaveAppBlock: { [weak self] leavingState in
                guard let self else { return }

                self.modalManagerDidLeaveApp(leavingState)
            }
        )

        // ObjC passed a `nil` URL on to the opener, which logged this and returned NO.
        guard let url else {
            Log.error("Could not determine URL scheme from url: (null)")
            return false
        }

        return safariOpener?.openURL(url, onClickthroughExitBlock: onClickthroughExitBlock) ?? false
    }

    func handleProductClickthrough(_ url: URL?,
                                   productParams: [String: Any],
                                   onExit onClickthroughExitBlock: @escaping VoidBlock) -> Bool {
        if let url {
            let webViewManager = HiddenWebViewManager(frame: view?.frame ?? .zero, landingPageString: url)
            webViewManager.openHiddenWebView()
        } else {
            // ObjC handed the nil URL to the manager, which logs this when asked to open it.
            Log.error("landingPageURL is not valid.")
        }

        if viewControllerForPresentingModals == nil {
            Log.error("self.viewControllerForPresentingModals is nil")
            return false
        }

        // The deployment target is iOS 15, so the `@available(iOS 14, *)` check of the ObjC original always passed.
        skStoreProductViewControllerExitBlock = onClickthroughExitBlock

        // `self` is captured strongly, like the ObjC block (no `__weak`).
        DispatchQueue.main.async {
            var presentingController = self.viewControllerForPresentingModals
            while let presentedController = presentingController?.presentedViewController {
                presentingController = presentedController
            }

            let skadnController = SKStoreProductViewController()
            skadnController.delegate = self
            self.clickthroughVisible = true
            presentingController?.present(skadnController, animated: true, completion: nil)
            skadnController.loadProduct(withParameters: productParams) { _, error in
                if let error {
                    Log.error("Error presenting a product: \(error.localizedDescription)")
                }
            }
        }

        return true
    }

    // MARK: - Resolution

    public func onResolutionCompleted() {
        dispatchQueue.async { [weak self] in
            guard let self else { return }

            if self.isDownloaded {
                return
            }

            self.isDownloaded = true

            self.creativeResolutionDelegate?.creativeReady(self)
        }
    }

    public func onResolutionFailed(_ error: Error) {
        dispatchQueue.async { [weak self] in
            guard let self else { return }

            if self.isDownloaded {
                return
            }

            self.isDownloaded = true
            self.creativeResolutionDelegate?.creativeFailed(error)
        }
    }

    public func onViewabilityChanged(_ viewable: Bool, viewExposure: ViewExposure) {
        if viewable && !adWasShown {
            onAdDisplayed()
            adWasShown = true
        }
    }

    public var isMuted: Bool {
        false
    }

    public func pause() {
        // Implement in particular creatives
    }

    public func resume() {
        // Implement in particular creatives
    }

    public func mute() {
        // Implement in particular creatives
    }

    public func unmute() {
        // Implement in particular creatives
    }

    func onWillTrackImpression() {
        // Implement in particular creatives
    }

    // MARK: - ModalManager events

    // The state stays optional: `SafariVCOpener` reports a finished clickthrough with `nil`, and the creatives rely on the call, not on the state.

    public func modalManagerDidFinishPop(_ state: ModalState?) {
        Log.error("Abstract function called")
    }

    public func modalManagerDidLeaveApp(_ state: ModalState?) {
        Log.error("Abstract function called")
    }

    // MARK: - SKStoreProductViewControllerDelegate

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        let pendingStatePop = pendingModalStatePop
        pendingModalStatePop = nil

        if clickthroughVisible {
            clickthroughVisible = false
            creativeViewDelegate?.creativeClickthroughDidClose(self)
        } else if let pendingStatePop {
            modalManagerDidFinishPop(pendingStatePop)
        }

        if let exitBlock = skStoreProductViewControllerExitBlock {
            exitBlock()
            skStoreProductViewControllerExitBlock = nil
        }
    }

    // MARK: - Open Measurement

    public func createOpenMeasurementSession() {
        Log.error("Abstract function called")
    }

    func onAdDisplayed() {
        // Non-nil gate, as in HTMLCreative/VideoCreative: the ObjC `isKindOfClass:` check would exclude the test mocks.
        if let measurementSession = transaction?.measurementSession {
            eventManager.registerTracker(measurementSession.eventTracker)
        }
        creativeViewDelegate?.creativeDidDisplay(self)
        onWillTrackImpression()
        eventManager.trackEvent(.impression)
    }
}
