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
import WebKit
import AVFoundation
import AdSupport

@objc(PBMWebView_Protocol) @_spi(PBMInternal) public
protocol WebView_Protocol {
    var isMRAID: Bool { get }

    // PBMWebView declares the getter as isRotationEnabled
    @objc(isRotationEnabled) var rotationEnabled: Bool { get }
}

@_spi(PBMInternal) public
typealias JSEvaluatingBlock = (_ command: String?, _ jsResult: Any?, _ error: Error?) -> Void

@objc(PBMWebViewState) @_spi(PBMInternal) public
enum WebViewState: Int {
    case unloaded
    case loading
    case loaded
}

private let internalWebViewAccessibilityIdentifier = "PBMInternalWebViewAccessibilityIdentifier"
private let keyPathOutputVolume = "outputVolume"

// The WebView is a UIView that contains a WKWebView as a subview.
// The interface of the WebView is specific to showing ads within the SDK.
// It allows for us to easily tell the webview to show an ad (and handling taking the data
// and getting it in the right format etc to be shown) while also encapsulating away other functionality that a WKWebView may have.
//
// Not final: `MockPBMWebView` in the test target subclasses it.
@objc(PBMWebView) @_spi(PBMInternal) public
class WebView: UIView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIGestureRecognizerDelegate, WebView_Protocol {

    // MARK: - Public properties

    // private webview which renders the ad
    @objc public let internalWebView: WKWebView

    // This block exists for testability. It is executed as part of the completion handler on evaluateJavascript.
    @objc public var jsEvaluatingCompletion: JSEvaluatingBlock?

    @objc public weak var delegate: WebViewDelegate?
    weak var exposureDelegate: ExposureChangeDelegate?
    var tapGestureRecognizer: UITapGestureRecognizer?

    // `@objc` for key-value coding: PBMWebViewTest.testExpand waits on `mraidState.rawValue` with an NSPredicate.
    @objc public var mraidState: MRAIDState = .notEnabled
    // `@objc` for key-value coding: the tests wait on `state == <rawValue>` with an NSPredicate.
    @objc public internal(set) var state: WebViewState = .loading
    var isViewable = false
    @objc public var isMRAID = false
    @objc(isRotationEnabled) public var rotationEnabled = true

    @objc public var rewardedAdURL: String?

    // MARK: - Internal properties

    var libraryManager: PrebidJSLibraryManager? = PrebidJSLibraryManager.shared

    // MARK: - Private properties

    // redirect protection
    private var lastTapTimestamp = Date.distantPast

    private var isVolumeObserverSetup = false

    // viewability polling
    private var viewabilityTracker: CreativeViewabilityTracker?

    // the last frame sent to an ad via onSizeChange
    private var mraidLastSentFrame = CGRect.zero

    // polling
    private var isPollingForDocumentReady = false

    private let targeting: Targeting

    // MARK: - Initialization

    // `-init` (so `+new` keeps working) and `-initWithFrame:` forward to the designated initializer, as the ObjC `-initWithFrame:` did.
    @objc public override convenience init(frame: CGRect) {
        self.init(frame: frame, creativeModel: nil, targeting: Targeting.shared)
    }

    @objc public convenience init() {
        self.init(frame: .zero)
    }

    // `creativeModel` was never read by the ObjC original either; the parameter stays for the surviving ObjC caller.
    @objc(initWithFrame:creativeModel:targeting:)
    public init(frame: CGRect, creativeModel: CreativeModel?, targeting: Targeting) {
        self.targeting = targeting

        //Setup MRAID-required properties
        //see section '8.4 Video' (page 68) of MRAID 3.0 specification
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let userContentController = WKUserContentController()

        //Add a meta tag to lock zoom to 100%
        //Add a style tag to keep margin at 0px.
        let javaScript = "var headTag = document.getElementsByTagName('head')[0];"
            + "var metaTag = document.createElement('meta');"
            + "metaTag.name = 'viewport';"
            + "metaTag.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';"
            + "headTag.appendChild(metaTag);"
            + "var style = document.createElement('style');"
            + "style.innerHTML = 'body {margin:0px; padding:0px;}';"
            + "headTag.appendChild(style);"

        //Run JS
        let script = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userContentController.addUserScript(script)

        //Create the WKWebView
        configuration.userContentController = userContentController
        let internalWebView = WKWebView(frame: frame, configuration: configuration)
        internalWebView.isOpaque = false
        self.internalWebView = internalWebView

        super.init(frame: frame)

        accessibilityIdentifier = PrebidConstants.ACCESSIBILITY_WEB_VIEW_LABEL

        //Add a Script Message Handler for "log"
        // The leak avoider holds this view weakly because WKUserContentController retains its handlers.
        // The ObjC original never removed the handler either.
        userContentController.add(WKScriptMessageHandlerLeakAvoider(delegate: self), name: "log")

        internalWebView.scrollView.isScrollEnabled = false
        internalWebView.scrollView.bounces = false
        internalWebView.accessibilityIdentifier = internalWebViewAccessibilityIdentifier

        addSubview(internalWebView)

        internalWebView.addFillSuperviewConstraints()
        internalWebView.navigationDelegate = self
        internalWebView.uiDelegate = self

        setupTapRecognizer()

        //Note: this observer is here and not in initNewWebView because it observes an application-level change, not a webview-level change.
        // Never removed explicitly, like the ObjC original: selector-based observers are dropped automatically on dealloc.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observer_UIApplicationDidChangeStatusBarOrientationNotification),
                                               name: UIApplication.didChangeStatusBarFrameNotification,
                                               object: nil)
    }

    // The ObjC original returned `[super initWithCoder:]`, a view without a web view that crashed on first use.
    // Nothing instantiates this view from a nib, so it fails to initialize instead.
    public required init?(coder: NSCoder) {
        return nil
    }

    deinit {
        if isVolumeObserverSetup {
            AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: keyPathOutputVolume)
        }
    }

    // MARK: - API

    /**
     Loads an HTML string with an optional base URL.

     If the supplied HTML string or the internal `WKWebView`'s state is invalid, will fail to load.

     This function is used by PBMHTMLCreative to load html ads for both .auid and .html AdUnitIdentifierTypes

     - parameters:
     - html: "Valid" HTML string including at least opening and closing <html> tags.
     - baseURL: Optional base URL to load HTML with.
     */
    // `html` stays optional: PBMHTMLCreative.m and PBMWebViewObjCTest.m, ObjC callers, still reach it and the ObjC
    // original logged and returned on nil (playbook S3.1-H).
    @objc(loadHTML:baseURL:injectMraidJs:)
    public func loadHTML(_ html: String?, baseURL: URL?, injectMraidJs: Bool) {
        loadHTML(html, baseURL: baseURL, injectMraidJs: injectMraidJs, currentThread: Thread.current)
    }

    func loadHTML(_ html: String?, baseURL: URL?, injectMraidJs: Bool, currentThread: ThreadProtocol) {
        guard let html else {
            Log.error("Input HTML is nil")
            return
        }

        if !currentThread.isMainThread {
            Log.error("Attempting to loadHTML on background thread")
        }

        loadContent(withMRAID: injectMraidJs, forExpandContent: false, contentLoader: { [weak self] in
            guard let self else { return }

            Log.info("loadHTMLString")
            self.state = .loading

            // The ObjC original ignored `baseURL` here as well.
            self.internalWebView.loadHTMLString(html, baseURL: nil)
        }, onError: { error in
            Log.error(error.localizedDescription)
        })
    }

    /**
     Loads HTML from a URL.
     This function is used by PBMHTMLCreative to support MRAID.expand

     - parameters:
     - url: The URL to be loaded
     */
    func expand(_ url: URL) {
        expand(url, currentThread: Thread.current)
    }

    func expand(_ url: URL, currentThread: ThreadProtocol) {
        if !currentThread.isMainThread {
            // `self` is captured strongly, like the ObjC block (no `__weak`).
            DispatchQueue.main.async {
                self.expand(url)
            }

            return
        }

        loadContent(withMRAID: true, forExpandContent: true, contentLoader: { [weak self] in
            guard let self else { return }

            self.state = .loading
            self.internalWebView.load(URLRequest(url: url))
        }, onError: { [weak self] error in
            DispatchQueue.main.async {
                guard let self else { return }

                self.delegate?.webView(self, failedToLoadWithError: error)
            }
        })
    }

    static func isVisibleView(_ view: UIView?) -> Bool {
        guard let view else {
            return false
        }

        // `pbmIsVisibleInView` ignores its argument, so `view` stands in where the ObjC passed a possibly nil superview.
        return view.pbmIsVisibleInView(view.superview ?? view) && view.window != nil
    }

    // MARK: - WKUIDelegate

    public func webView(_ webView: WKWebView,
                        createWebViewWith configuration: WKWebViewConfiguration,
                        for navigationAction: WKNavigationAction,
                        windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        //If there's no URL, bail
        guard let url = navigationAction.request.url, !url.absoluteString.isEmpty else {
            Log.warn("No URL found on WKWebView navigation")
            decisionHandler(.cancel)
            return
        }

        //Identify and process MRAID links
        if MRAIDController.isMRAIDLink(url.absoluteString) {
            isMRAID = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.webView(self, receivedMRAIDLink: url)
            }
            decisionHandler(.cancel)
            return
        }

        // Identify and process rewarded events
        // `isEqualToString:` is a literal comparison; Swift's `==` would also equate canonically equivalent strings.
        if let rewardedAdURL, (url.absoluteString as NSString).isEqual(to: rewardedAdURL) {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.webView(self, receivedRewardedEventLink: url)
            }

            decisionHandler(.cancel)
            return
        }

        //If this is the first URL, allow it.
        if state == .loading {
            decisionHandler(.allow)
            return
        }

        //Bail if the state is uninitialized, unloaded, or still loading.
        if state != .loaded {
            Log.warn("Unexpected state [\(WebView.webViewStateDescription(state))] found on navigation to url: \(url)")
            decisionHandler(.cancel)
            return
        }

        //Prevent malicious auto-clicking
        if wasRecentlyTapped() {
            //Open clickthrough
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.webView(self, receivedClickthroughLink: url)
            }
        } else {
            Log.warn("User has not recently tapped. Auto-click suppression is preventing navigation to: \(url)")
        }

        decisionHandler(.cancel)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Log.whereAmI()
        pollForDocumentReadyState()
    }

    private func pollForDocumentReadyState() {
        if isPollingForDocumentReady || state == .loaded {
            return
        }
        isPollingForDocumentReady = true
        checkDocumentReadyState()
    }

    private func checkDocumentReadyState() {
        let script = WKUserScript(source: "document.readyState", injectionTime: .atDocumentStart, forMainFrameOnly: false)
        internalWebView.configuration.userContentController.addUserScript(script)
        internalWebView.evaluateJavaScript("document.readyState") { [weak self] readyState, _ in
            // This callback always runs on main thread
            guard let self else { return }

            if (readyState as? String) == "complete" {
                self.state = .loaded
                self.isPollingForDocumentReady = false
                self.delegate?.webViewReadyToDisplay(self)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                    guard let self else { return }

                    self.checkDocumentReadyState()
                }
            }
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Log.whereAmI()
        state = .unloaded

        // `%li` of the code and `%@` of the user info dictionary, as the ObjC original formatted them.
        let nsError = error as NSError
        let errorMessage = String(format: "WebView failed to load. Error description: %@, domain: %@, code: %li, userInfo: %@",
                                  nsError.localizedDescription, nsError.domain, nsError.code, nsError.userInfo as NSDictionary)
        let prebidError = PBMError.error(message: errorMessage, type: PBMErrorType.internalError)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.delegate?.webView(self, failedToLoadWithError: prebidError)
        }
    }

    #if DEBUG
    public func webView(_ webView: WKWebView,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        Functions.checkCertificateChallenge(challenge, completionHandler: completionHandler)
    }
    #endif

    // MARK: - WKScriptMessageHandler

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Log.info("JS: \(message.body)")
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    // MARK: - OutputVolume listener

    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {

        guard keyPath == keyPathOutputVolume else {
            return
        }

        // The ObjC original sent `-floatValue` to whatever `change` held, so an NSNumber and an NSString (the test passes "0.5")
        // both work, and a missing value reports the volume as unknown.
        switch change?[.newKey] {
        case let number as NSNumber:
            MRAID_onAudioVolumeChange(number)
        case let string as NSString:
            MRAID_onAudioVolumeChange(NSNumber(value: string.floatValue))
        default:
            MRAID_onAudioVolumeChange(nil)
        }
    }

    @objc private func audioSessionWasInterrupted(_ notification: Notification) {
        guard notification.name == AVAudioSession.interruptionNotification else {
            return
        }

        let interruptionType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber
        if interruptionType?.isEqual(to: NSNumber(value: AVAudioSession.InterruptionType.began.rawValue)) == true {
            MRAID_onAudioVolumeChange(nil)
        } else {
            let volume = NSNumber(value: AVAudioSession.sharedInstance().outputVolume)
            MRAID_onAudioVolumeChange(volume)
        }
    }

    // MARK: - Rotation

    //If the publisher app changes orientations, reset the content offset back to 0,0.
    //This fixes an issue where upon rotation the ad content may shift slightly.
    @objc private func observer_UIApplicationDidChangeStatusBarOrientationNotification() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.onStatusBarOrientationChanged()
        }
    }

    // update the mraid layout information whenever the frame changes (including on rotation) so the ad can resize itself
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMRAIDLayoutInfo(false)
    }

    // MARK: - MRAID Injection

    func injectMRAIDForExpandContent(_ isForExpandContent: Bool) throws {
        guard let mraidScript = libraryManager?.getMRAIDLibrary() else {
            // `+[PBMError createError:message:type:]` logged the error it created.
            let error = PBMError.error(message: "Could not load mraid.js from library manager", type: PBMErrorType.internalError)
            Log.error("\(error)")
            throw error
        }

        //Execute mraid.js
        let script = WKUserScript(source: mraidScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        internalWebView.configuration.userContentController.addUserScript(script)
        internalWebView.evaluateJavaScript(mraidScript) { [weak self] _, error in
            guard let self else { return }

            if let error {
                Log.error("Error injecting MRAID script: \(error)")
                return
            }

            self.MRAID_updateSizes()

            //When mraid.js finishes loading, change MRAID state to either Ready or Expanded.
            let command = isForExpandContent
                ? MRAIDJavascriptCommands.onReadyExpanded()
                : MRAIDJavascriptCommands.onReady()

            let script = WKUserScript(source: command, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            self.internalWebView.configuration.userContentController.addUserScript(script)
            // `self` is captured strongly here, like the ObjC block, which used the local strong reference from `@strongify`.
            self.internalWebView.evaluateJavaScript(command) { _, error in
                //When the state has finished changing, update our own MRAID state
                if let error {
                    Log.error("Error calling \(command): \(error.localizedDescription)")
                    return
                }

                self.mraidState = isForExpandContent ? .expanded : .defaultState
            }
        }
    }

    private func injectMRAIDEnvAndExecute(_ completion: @escaping VoidBlock, onError: @escaping (Error) -> Void) {
        let script = WKUserScript(source: buildMraidEnvObject(), injectionTime: .atDocumentStart, forMainFrameOnly: false)
        internalWebView.configuration.userContentController.addUserScript(script)
        internalWebView.evaluateJavaScript(buildMraidEnvObject()) { _, error in
            if let error {
                onError(error)
            } else {
                completion()
            }
        }
    }

    func buildMraidEnvObject() -> String {
        // `%@` printed "(null)" for a nil bundle identifier.
        let entries = [
            "version: '3.0'",
            "sdk: 'prebid-mobile-sdk'",
            "sdkVersion: '\(Functions.sdkVersion)'",
            "appId: '\(Bundle.main.bundleIdentifier ?? "(null)")'",
            "ifa: '\(ASIdentifierManager.shared().advertisingIdentifier.uuidString)'",
            "limitAdTracking: \(!ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? "true" : "false")",
            "coppa: \(targeting.coppa?.isEqual(to: NSNumber(value: 1)) == true ? "true" : "false")"
        ]

        return "window.MRAID_ENV = {\n  " + entries.joined(separator: ",\n  ") + "}"
    }

    private func loadContent(withMRAID injectMRAID: Bool,
                             forExpandContent: Bool,
                             contentLoader: @escaping VoidBlock,
                             onError: @escaping (Error) -> Void) {
        if injectMRAID {
            let injectMraidLib: VoidBlock = { [weak self] in
                guard let self else { return }

                do {
                    try self.injectMRAIDForExpandContent(forExpandContent)
                } catch {
                    onError(error)
                    return
                }

                contentLoader()
            }
            // > In the case of a 2-part ad, the host only makes the MRAID_ENV object available to the initial ad.
            // > The second part of the 2-part ad must use details the ad received in the first part if the second part needs those details.
            //
            // see '3.1.2 Declaring MRAID Environment Details', p.17-19 of MRAID 3.0 specification
            if !forExpandContent {
                injectMRAIDEnvAndExecute({
                    injectMraidLib()
                }, onError: { error in
                    onError(error)
                })
            } else {
                injectMraidLib()
            }
        } else {
            contentLoader()
        }
    }

    // MARK: - MRAID

    // `viewController` stays optional: MRAIDController passes a weak reference that can be nil by then
    // and the ObjC original treated a nil controller as "not locked".
    @objc(prepareForMRAIDWithRootViewController:)
    public func prepareForMRAID(withRootViewController viewController: UIViewController?) {
        setSupportedMRAIDFeatures()

        MRAID_updateSizes()

        MRAID_updateLocation()
        let isLocked = isOrientationLocked(viewController: viewController)
        MRAID_updateCurrentAppOrientation(isLocked: isLocked)

        pollForViewability()
        setupVolumeObserver()
    }

    private func MRAID_updateSizes() {
        MRAID_updateMaxSize()
        MRAID_updateScreenSize()
        MRAID_updateDefaultPosition(frame)
        MRAID_updateCurrentPosition(frame, forceNotification: false)
    }

    func isOrientationLocked(viewController: UIViewController?) -> Bool {
        guard let viewController else {
            return false
        }

        // The ObjC original tested `mask & X` for being non-zero, which is `intersects`, not `contains`.
        let mask = viewController.supportedInterfaceOrientations
        let isPortraitSupported = !mask.isDisjoint(with: .portrait) || !mask.isDisjoint(with: .portraitUpsideDown)
        let isLandscapeSupported = !mask.isDisjoint(with: .landscape) || !mask.isDisjoint(with: .landscapeLeft)

        return !isPortraitSupported || !isLandscapeSupported
    }

    private func setupVolumeObserver() {
        if !isVolumeObserverSetup {
            isVolumeObserverSetup = true
            // Note: intentionally not calling `setActive:YES` here. Activating the shared audio session
            // is a synchronous call that can block the main thread and interrupts audio already playing
            // in other apps, even though this is only needed to observe `outputVolume` via KVO, which
            // works without activating the session.
            AVAudioSession.sharedInstance().addObserver(self,
                                                        forKeyPath: keyPathOutputVolume,
                                                        options: .new,
                                                        context: nil)
            let volume = NSNumber(value: AVAudioSession.sharedInstance().outputVolume)
            MRAID_onAudioVolumeChange(volume)

            // Not removed explicitly, like the ObjC original: dropped automatically on dealloc.
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(audioSessionWasInterrupted),
                                                   name: AVAudioSession.interruptionNotification,
                                                   object: nil)
        }
    }

    @objc(updateMRAIDLayoutInfoWithForceNotification:)
    public func updateMRAIDLayoutInfo(_ forceNotification: Bool) {
        MRAID_updateCurrentPosition(frame, forceNotification: forceNotification)
    }

    @objc(changeToMRAIDState:)
    public func changeToMRAIDState(_ state: MRAIDState) {
        mraidState = state
        MRAID_onStateChange(state)
    }

    // MARK: - Calling handlers in mraid.js

    func MRAID_nativeCallComplete() {
        let command = MRAIDJavascriptCommands.nativeCallComplete()
        if Thread.isMainThread {
            let script = WKUserScript(source: command, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            internalWebView.configuration.userContentController.addUserScript(script)
            internalWebView.evaluateJavaScript(command) { _, error in
                if error != nil {
                    Log.error("Error of executing command \(command)")
                }
            }
        } else {
            evaluateJavaScript(command)
        }
    }

    // updates the webview's size in mraid.js
    private func MRAID_onSizeChange() {
        if frame == mraidLastSentFrame {
            return
        }

        mraidLastSentFrame = frame
        evaluateJavaScript(MRAIDJavascriptCommands.onSizeChange(frame.size))

        //these changes were fired by a transition default => expened, default => resize ....
        if let viewabilityTracker, let exposureDelegate, exposureDelegate.shouldCheckExposure() {
            viewabilityTracker.checkExposure(force: true)
        }
    }

    // updates the state of the webview in mraid.js
    private func MRAID_onStateChange(_ state: MRAIDState) {
        evaluateJavaScript(MRAIDJavascriptCommands.onStateChange(state))
    }

    // updates the viewable flag in mraid.js
    func MRAID_onExposureChange(_ viewExposure: ViewExposure) {
        let newViewable = viewExposure.exposureFactor > 0
        if isViewable != newViewable {
            isViewable = newViewable
            evaluateJavaScript(MRAIDJavascriptCommands.onViewableChange(newViewable))
        }

        evaluateJavaScript(MRAIDJavascriptCommands.onExposureChange(viewExposure))
    }

    // fires the audioVolumeChange event in mraid.js
    private func MRAID_onAudioVolumeChange(_ volumeValue: NSNumber?) {
        // `[volumeValue floatValue] * 100.0` multiplies a float promoted to double.
        let volumePercentage = volumeValue.map { NSNumber(value: Double($0.floatValue) * 100.0) }
        evaluateJavaScript(MRAIDJavascriptCommands.onAudioVolumeChange(volumePercentage))
    }

    // MARK: - Functions for updating data in mraid.js

    // look up what features are avaliable and set them
    private func setSupportedMRAIDFeatures() {
        evaluateJavaScript(MRAIDJavascriptCommands.updateSupportedFeatures())
    }

    // TODO: call this?
    //updates the placement type in mraid.js - can be 'inline' (displayed inline with content) or 'interstitial' as an interstitial overlaid content
    // `type` is one of the `PBMMRAIDPlacementType` string constants (`NS_TYPED_ENUM`, not visible to this target).
    func MRAID_updatePlacementType(_ type: String) {
        evaluateJavaScript(MRAIDJavascriptCommands.updatePlacementType(type))
    }

    // update the current screen size in mraid.js that can be expanded to, which is the device size minus the status bar
    private func MRAID_updateScreenSize() {
        evaluateJavaScript(MRAIDJavascriptCommands.updateScreenSize(Functions.deviceScreenSize))
    }

    // update the maximum size of the device screen in mraid.js
    private func MRAID_updateMaxSize() {
        evaluateJavaScript(MRAIDJavascriptCommands.updateMaxSize(Functions.deviceMaxSize))
    }

    // This method sets default (starting) position for the webview in mraid.js
    private func MRAID_updateDefaultPosition(_ position: CGRect) {
        evaluateJavaScript(MRAIDJavascriptCommands.updateDefaultPosition(position))
    }

    // sets current position for the webview in mraid.js
    private func MRAID_updateCurrentPosition(_ position: CGRect, forceNotification: Bool) {
        evaluateJavaScript(MRAIDJavascriptCommands.updateCurrentPosition(position))
        MRAID_onSizeChange()
    }

    private func MRAID_updateLocation() {
        if Prebid.shared.locationUpdatesEnabled && LocationManager.shared.coordinatesAreValid {
            let locationManager = LocationManager.shared
            evaluateJavaScript(MRAIDJavascriptCommands.updateLocation(locationManager.coordinates,
                                                                      accuracy: locationManager.horizontalAccuracy,
                                                                      timeStamp: locationManager.timestamp?.timeIntervalSince1970 ?? 0))
        }
    }

    private func MRAID_updateCurrentAppOrientation(isLocked locked: Bool) {
        // `UIApplication.shared` traps host-less (playbook S2.5-E); the ObjC original read a nil application as "not portrait".
        let isPortrait = Functions.resolvedApplication?.statusBarOrientation.isPortrait ?? false
        evaluateJavaScript(MRAIDJavascriptCommands.updateCurrentAppOrientation(isPortrait ? "portrait" : "landscape", locked: locked))
    }

    // MARK: - Functions for getting data out of mraid.js

    // The values come straight from the creative's JSON. `-integerValue` and `-boolValue` are lenient on NSNumber and NSString;
    // any other type (NSNull, array, dictionary) made the ObjC original raise "unrecognized selector". Such a value is rejected here.
    private static func integerValue(of value: Any) -> Int? {
        switch value {
        case let number as NSNumber:
            return number.intValue
        case let string as NSString:
            return string.integerValue
        default:
            return nil
        }
    }

    private static func boolValue(of value: Any) -> Bool? {
        switch value {
        case let number as NSNumber:
            return number.boolValue
        case let string as NSString:
            return string.boolValue
        default:
            return nil
        }
    }

    func MRAID_getExpandProperties(completionHandler: @escaping (MRAIDExpandProperties?) -> Void) {

        let command = MRAIDJavascriptCommands.getExpandProperties()
        let script = WKUserScript(source: command, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        internalWebView.configuration.userContentController.addUserScript(script)
        internalWebView.evaluateJavaScript(command) { jsResult, error in
            if let error {
                Log.error("Error getting expand properties: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }

            guard let dict = WebView.anyToJSONDict(jsResult) else {
                completionHandler(nil)
                return
            }

            guard let rawWidth = dict[MRAIDParseKeys.WIDTH], let rawHeight = dict[MRAIDParseKeys.HEIGHT] else {
                completionHandler(nil)
                return
            }

            guard let width = WebView.integerValue(of: rawWidth), let height = WebView.integerValue(of: rawHeight) else {
                Log.error("Unsupported value type in expand properties: \(dict)")
                completionHandler(nil)
                return
            }

            completionHandler(MRAIDExpandProperties(width: width, height: height))
        }
    }

    func MRAID_getResizeProperties(completionHandler: @escaping (MRAIDResizeProperties?) -> Void) {

        let command = MRAIDJavascriptCommands.getResizeProperties()
        let script = WKUserScript(source: command, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        internalWebView.configuration.userContentController.addUserScript(script)
        internalWebView.evaluateJavaScript(command) { jsResult, error in
            if let error {
                Log.error("Error getting Resize Properties: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }

            guard let dict = WebView.anyToJSONDict(jsResult) else {
                completionHandler(nil)
                return
            }

            guard let rawWidth = dict[MRAIDParseKeys.WIDTH],
                  let rawHeight = dict[MRAIDParseKeys.HEIGHT],
                  let rawOffsetX = dict[MRAIDParseKeys.X_OFFSET],
                  let rawOffsetY = dict[MRAIDParseKeys.Y_OFFSET],
                  let rawAllowOffscreen = dict[MRAIDParseKeys.ALLOW_OFFSCREEN] else {
                completionHandler(nil)
                return
            }

            guard let width = WebView.integerValue(of: rawWidth),
                  let height = WebView.integerValue(of: rawHeight),
                  let offsetX = WebView.integerValue(of: rawOffsetX),
                  let offsetY = WebView.integerValue(of: rawOffsetY),
                  let allowOffscreen = WebView.boolValue(of: rawAllowOffscreen) else {
                Log.error("Unsupported value type in resize properties: \(dict)")
                completionHandler(nil)
                return
            }

            completionHandler(MRAIDResizeProperties(width: width,
                                                    height: height,
                                                    offsetX: offsetX,
                                                    offsetY: offsetY,
                                                    allowOffscreen: allowOffscreen))
        }
    }

    // This execute method fire the MRAID 'error' event.
    // @param message - description of the type of error
    // @param action - name of action that caused error (one of the `PBMMRAIDAction` string constants)
    func MRAID_error(_ message: String, action: String) {
        Log.error("Action: [\(action)] generated error with message [\(message)]")
        evaluateJavaScript(MRAIDJavascriptCommands.onError(message, action: action))
    }

    //Poll every 200 ms for viewability changes.
    //TODO: There is almost certainly a way to do this that is more industry-standard and less processor-intensive.
    private func pollForViewability() {
        // The ObjC literal was `0.2f`, a float widened to double (0.20000000298...); the difference is below a microsecond.
        viewabilityTracker = Factory.createCreativeViewabilityTracker(view: self, pollingTimeInterval: 0.2) { [weak self] _, viewExposure in
            guard let self else { return }

            self.MRAID_onExposureChange(viewExposure)
            self.exposureDelegate?.webView(self, exposureChange: viewExposure)
        }
        viewabilityTracker?.start()
    }

    // MARK: - Helper Methods

    func evaluateJavaScript(_ jsCommand: String) {
        // `self` is captured strongly by the outer block, like the ObjC original; only the completion handler was weak.
        DispatchQueue.main.async {
            // ATTENTION: the invoking of "evaluateJavaScript" not from main thread leads to the crash.
            let script = WKUserScript(source: jsCommand, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            self.internalWebView.configuration.userContentController.addUserScript(script)
            self.internalWebView.evaluateJavaScript(jsCommand) { [weak self] jsResult, error in
                guard let self else { return }

                self.jsEvaluatingCompletion?(jsCommand, jsResult, error)
            }
        }
    }

    private func setupTapRecognizer() {
        if let tapGestureRecognizer {
            internalWebView.removeGestureRecognizer(tapGestureRecognizer)
        }

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recordTapEvent))
        tapGestureRecognizer.cancelsTouchesInView = false
        internalWebView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        self.tapGestureRecognizer = tapGestureRecognizer
    }

    @objc func recordTapEvent(_ tap: UITapGestureRecognizer?) {
        guard let tap, tapGestureRecognizer === tap else {
            return
        }

        lastTapTimestamp = Date()
    }

    func wasRecentlyTapped() -> Bool {
        abs(lastTapTimestamp.timeIntervalSinceNow) < PrebidConstants.AD_CLICKED_ALLOWED_INTERVAL
    }

    // MARK: - Orientation changing support

    func onStatusBarOrientationChanged() {
        let isPortrait = Functions.resolvedApplication?.statusBarOrientation == .portrait ? "true" : "false"
        Log.info("Orientation is portrait: \(isPortrait)")

        internalWebView.scrollView.contentOffset = CGPoint(x: 0.0, y: 0.0)
        MRAID_updateMaxSize()
        updateMRAIDLayoutInfo(false)

        let isLocked = isOrientationLocked(viewController: delegate?.viewControllerForPresentingModals())

        MRAID_updateCurrentAppOrientation(isLocked: isLocked)
    }

    // MARK: - Open Measurement

    @objc(addFriendlyObstructionsToMeasurementSession:)
    public func addFriendlyObstructions(to session: OMSession?) {
    }

    // MARK: - Utilities

    // returns a human-readable description of the view's state
    static func webViewStateDescription(_ state: WebViewState) -> String {
        switch state {
        case .unloaded: return "unloaded"
        case .loading: return "loading"
        case .loaded: return "loaded"
        }
    }

    // The input is `Any?`, like the ObjC `id`: only a string is parsed. NSString keeps
    // `dataUsingEncoding:allowLossyConversion:NO` failing on unpaired surrogates instead of replacing them.
    static func anyToJSONDict(_ value: Any?) -> [String: Any]? {
        guard let jsonString = value as? NSString else {
            return nil
        }

        // convert string to data so it can be serialized to json object
        guard let data = jsonString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) else {
            return nil
        }

        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
    }
}
