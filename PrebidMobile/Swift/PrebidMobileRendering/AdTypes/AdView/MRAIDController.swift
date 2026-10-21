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

import UIKit

// Stands in for the `NSException` the ObjC controller raised for an unusable command; only its message was ever observed.
private struct MRAIDCommandError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

@objc(PBMMRAIDController)
class MRAIDController: NSObject, ExposureChangeDelegate {

    // MARK: - Properties

    @objc public var mraidState: MRAIDState = .defaultState

    private weak var creative: AbstractCreative?
    weak var viewControllerForPresentingModals: UIViewController?
    private weak var creativeViewDelegate: CreativeViewDelegate?
    private var downloadBlock: ((URL, @escaping PBMDownloadDataCompletionClosure) -> Void)?

    weak var prebidWebView: WebView?

    private var playingMRAIDVideo = false

    private var dismissExpandedModalState: VoidBlock?
    private var dismissResizedModalState: VoidBlock?

    //See the par. 3.1.4 https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf
    //A new state (via sending changeState) must be set
    //only *AFTER* the exposureChange event
    //we save the new state and will send it after the exposureChange event
    private var delayedMraidState: MRAIDState = .notEnabled

    // MARK: - Initialization

    // Every parameter stays optional: PBMHTMLCreative.m, a surviving ObjC caller, can pass nil for the weak ones, and the ObjC
    // original accepted nil for all of them (playbook S3.1-H). `downloadBlock` is the structural twin of the ObjC
    // `PBMCreativeFactoryDownloadDataCompletionClosure` typedef.
    @objc(initWithCreative:viewControllerForPresenting:webView:creativeViewDelegate:downloadBlock:)
    public init(creative: AbstractCreative?,
                viewControllerForPresenting viewControllerForPresentingModals: UIViewController?,
                webView: WebView?,
                creativeViewDelegate: CreativeViewDelegate?,
                downloadBlock: ((URL, @escaping PBMDownloadDataCompletionClosure) -> Void)?) {
        self.creative = creative
        self.viewControllerForPresentingModals = viewControllerForPresentingModals
        self.prebidWebView = webView
        self.creativeViewDelegate = creativeViewDelegate
        self.downloadBlock = downloadBlock

        super.init()

        prebidWebView?.exposureDelegate = self
    }

    // MARK: - Commands

    // `-[NSString hasPrefix:]` is a literal anchored search (`kCFCompareAnchored`). Swift resolves `hasPrefix` on an `NSString` to the
    // grapheme-aware `String.hasPrefix`, which rejects "mraid:\u{301}x" that the ObjC original accepted (probed), so the literal
    // anchored NSString search is spelled out.
    static func isMRAIDLink(_ urlString: String) -> Bool {
        (urlString as NSString).range(of: MRAIDConstants.mraidURLScheme, options: [.anchored, .literal]).location != NSNotFound
    }

    @objc(webView:handleMRAIDURL:)
    public func webView(_ webView: WebView, handleMRAIDURL url: URL) {
        prebidWebView?.MRAID_nativeCallComplete()
        do {
            try handleMRAIDCommand(from: url, webView: webView)
        } catch {
            Log.warn(error.localizedDescription)
        }
    }

    private func handleMRAIDCommand(from url: URL, webView: WebView) throws {

        let mraidCommand = try command(from: url)
        let command = mraidCommand.command

        // 'unload' is the only command allowed to happen when webView is not viewable
        if command == MRAIDAction.unload.rawValue {
            handleMRAIDCommandUnload()
            return
        }

        if !webView.isViewable {
            throw MRAIDCommandError(message: "MRAID COMMAND: \(command) not usable, PBMWebView is not viewable)")
        }

        switch command {
        case MRAIDAction.open.rawValue:
            try handleMRAIDCommandOpen(mraidCommand)
        case MRAIDAction.expand.rawValue:
            try handleMRAIDCommandExpand(mraidCommand, originURL: url)
        case MRAIDAction.resize.rawValue:
            try handleMRAIDCommandResize(mraidCommand)
        case MRAIDAction.close.rawValue:
            handleMRAIDCommandClose()
        case MRAIDAction.storePicture.rawValue:
            throw MRAIDCommandError(message: "MRAID COMMAND: \(mraidCommand.command) is not supported")
        case MRAIDAction.createCalendarEvent.rawValue:
            throw MRAIDCommandError(message: "MRAID COMMAND: \(mraidCommand.command) is not supported")
        case MRAIDAction.playVideo.rawValue:
            try handleMRAIDCommandPlayVideo(mraidCommand)
        case MRAIDAction.onOrientationPropertiesChanged.rawValue:
            try handleMRAIDCommandOnOrientationPropertiesChanged(mraidCommand)
        default:
            throw MRAIDCommandError(message: "MRAID COMMAND: \(mraidCommand.command) is not supported")
        }
    }

    private func modalManagerDidFinishPop(_ state: ModalState?) {

        //MRAID Video
        if playingMRAIDVideo {
            // When closing a MRAID video interstitial, only need to set the MRAID state to hidden.
            playingMRAIDVideo = false
            if mraidState === MRAIDState.expanded {
                prebidWebView?.changeToMRAIDState(.expanded)
            } else {
                prebidWebView?.changeToMRAIDState(.hidden)
            }
            return
        }

        // Just call the host creative
        // `ModalManager` always passes the popped state; the non-optional creative method cannot take the nil the ObjC could forward.
        if let state {
            creative?.modalManagerDidFinishPop(state)
        }
    }

    @objc(updateForClose:)
    public func updateForClose(_ isInterstitial: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let prevState = self.prebidWebView?.mraidState
            self.prebidWebView?.updateMRAIDLayoutInfo(false)
            if prevState?.isEqual(MRAIDState.expanded) == true || prevState?.isEqual(MRAIDState.resized) == true {
                self.delayedMraidState = .defaultState
            } else {
                self.prebidWebView?.changeToMRAIDState(isInterstitial ? .hidden : .defaultState)
            }

            // Notify Mraid Collapsed *after* the state has changed and Only if we were Expanded.
            if prevState?.isEqual(MRAIDState.expanded) == true {
                self.mraidState = .defaultState
                // The delegate method takes a non-optional creative; the creative owns this controller, so it is
                // only nil while it is being deallocated.
                if let creative = self.creative {
                    self.creativeViewDelegate?.creativeMraidDidCollapse(creative)
                }
            }
        }
    }

    private func modalManagerDidLeaveApp(_ state: ModalState?) {
        if let state {
            creative?.modalManagerDidLeaveApp(state)
        }
    }

    // MARK: - ExposureChangeDelegate

    public func shouldCheckExposure() -> Bool {
        !delayedMraidState.isEqual(MRAIDState.notEnabled)
    }

    public func webView(_ webView: WebView, exposureChange viewExposure: ViewExposure) {
        if !delayedMraidState.isEqual(MRAIDState.notEnabled) {
            prebidWebView?.changeToMRAIDState(delayedMraidState)
            delayedMraidState = .notEnabled
        }
    }

    // MARK: - Private methods

    func command(from url: URL?) throws -> MRAIDCommand {
        guard let url else {
            throw MRAIDCommandError(message: "URL is nil")
        }

        do {
            return try MRAIDCommand(url: url.absoluteString)
        } catch {
            throw MRAIDCommandError(message: error.localizedDescription)
        }
    }

    // MARK: - MRAID commands

    private func handleMRAIDCommandOpen(_ command: MRAIDCommand) throws {
        guard let urlString = command.arguments.first else {
            throw MRAIDCommandError(message: "No arguments to MRAID.open()")
        }

        guard let url = NSURL.pbmURLWithoutEncoding(from: urlString) else {
            throw MRAIDCommandError(message: "Could not create URL from string: \(urlString)")
        }

        Log.info("Attempting to MRAID.open() url \(urlString)")
        creative?.handleClickthrough(url)
    }

    private func handleMRAIDCommandExpand(_ command: MRAIDCommand, originURL url: URL) throws {
        if creative?.creativeModel.adConfiguration?.isInterstitialAd == true {
            // 'expand' should have no effect on Interstitial ads.
            // see p.29 of MRAID_3.0_FINAL_June_2018.pdf
            return
        }

        if viewControllerForPresentingModals == nil {
            throw MRAIDCommandError(message: "self.viewControllerForPresentingModals is nil for expand: \(url)")
        }

        let allowableStatesForResize = [MRAIDState.defaultState, MRAIDState.resized]
        guard let webView = prebidWebView,
              allowableStatesForResize.contains(where: { $0.isEqual(webView.mraidState) }) else {
            throw MRAIDCommandError(message: "MRAID cannot expand from state: \(prebidWebView?.mraidState.description ?? "(null)")")
        }

        let displayProperties = InterstitialDisplayProperties()

        webView.MRAID_getExpandProperties { [weak self] expandProperties in
            guard let self else { return }

            guard expandProperties != nil else {
                webView.MRAID_error("Unable to get Expand Properties", action: MRAIDAction.expand.rawValue)
                return
            }

            let shouldReplace = self.dismissResizedModalState != nil

            //Check whether we are expanding existing content or expanding to a specific URL.
            let strExpandURL = command.arguments.first.map {
                ($0 as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if let strExpandURL, !strExpandURL.isEmpty {
                //Epanding to a URL
                guard let expandURL = NSURL.pbmURLWithoutEncoding(from: strExpandURL) else {
                    Log.error("Could not create expand url to: \(strExpandURL)")
                    return
                }

                let newWebView = WebView()
                newWebView.delegate = self.prebidWebView?.delegate
                newWebView.expand(expandURL)

                let modalState = Factory.createModalState(
                    view: newWebView,
                    adConfiguration: self.creative?.creativeModel.adConfiguration,
                    displayProperties: displayProperties,
                    onStatePopFinished: { [weak self] poppedState in
                        guard let self else { return }

                        self.modalManagerDidFinishPop(poppedState)
                    }, onStateHasLeftApp: { [weak self] leavingState in
                        guard let self else { return }

                        self.modalManagerDidLeaveApp(leavingState)
                    })

                guard let rootViewController = self.viewControllerForPresentingModals else {
                    // The ObjC original passed the nil on into the non-nullable `ModalManager` parameter.
                    Log.error("self.viewControllerForPresentingModals is nil for expand: \(url)")
                    return
                }

                self.dismissExpandedModalState = self.creative?.modalManager?.pushModal(modalState,
                                                                                         fromRootViewController: rootViewController,
                                                                                         animated: true,
                                                                                         shouldReplace: shouldReplace,
                                                                                         completionHandler: { [weak self] in
                    guard let self else { return }

                    // ALSO set the first part (banner) to Expanded per MRAID spec
                    self.delayedMraidState = .expanded

                    newWebView.prepareForMRAID(withRootViewController: self.viewControllerForPresentingModals)
                    self.creative?.modalManager?.modalViewController?
                        .addFriendlyObstructions(toMeasurementSession: self.creative?.transaction?.measurementSession)
                })
            } else {
                //Expand existing content.
                let modalState = Factory.createModalState(
                    view: webView,
                    adConfiguration: self.creative?.creativeModel.adConfiguration,
                    displayProperties: displayProperties,
                    onStatePopFinished: { [weak self] poppedState in
                        guard let self else { return }

                        self.modalManagerDidFinishPop(poppedState)
                    }, onStateHasLeftApp: { [weak self] leavingState in
                        guard let self else { return }

                        self.modalManagerDidLeaveApp(leavingState)
                    })

                guard let rootViewController = self.viewControllerForPresentingModals else {
                    Log.error("self.viewControllerForPresentingModals is nil for expand: \(url)")
                    return
                }

                self.dismissExpandedModalState = self.creative?.modalManager?.pushModal(modalState,
                                                                                         fromRootViewController: rootViewController,
                                                                                         animated: true,
                                                                                         shouldReplace: shouldReplace,
                                                                                         completionHandler: { [weak self] in
                    guard let self else { return }

                    self.delayedMraidState = .expanded
                    self.creative?.modalManager?.modalViewController?
                        .addFriendlyObstructions(toMeasurementSession: self.creative?.transaction?.measurementSession)
                })
            }

            self.dismissResizedModalState = nil

            // Notify delegates that the MRAID ad has Expanded
            // The delegate method takes a non-optional creative; the creative owns this controller, so it is
            // only nil while it is being deallocated.
            if let creative = self.creative {
                self.creativeViewDelegate?.creativeMraidDidExpand(creative)
            }
            self.mraidState = .expanded
            self.creative?.eventManager.trackEvent(.click)
        }
    }

    private func handleMRAIDCommandResize(_ command: MRAIDCommand) throws {
        if creative?.creativeModel.adConfiguration?.isInterstitialAd == true {
            // 'resize' should have no effect on Interstitial ads.
            // see p.29 of MRAID_3.0_FINAL_June_2018.pdf
            return
        }

        if viewControllerForPresentingModals == nil {
            throw MRAIDCommandError(message: "self.viewControllerForPresentingModals is nil for mraid command \(command)")
        }

        let allowableStatesForResize = [MRAIDState.defaultState, MRAIDState.resized]
        guard let webView = prebidWebView,
              allowableStatesForResize.contains(where: { $0.isEqual(webView.mraidState) }) else {
            let message = "MRAID cannot resize from state: \(prebidWebView?.mraidState.description ?? "(null)")"
            prebidWebView?.MRAID_error(message, action: MRAIDAction.resize.rawValue)
            throw MRAIDCommandError(message: message)
        }

        let mraidState = webView.mraidState

        webView.MRAID_getResizeProperties { [weak self] resizeProperties in
            guard let self else { return }

            guard let resizeProperties else {
                webView.MRAID_error("Was unable to get resizeProperties", action: MRAIDAction.resize.rawValue)
                return
            }

            let displayProperties = InterstitialDisplayProperties()
            //Make the close button invisible but still tappable.
            displayProperties.setButtonImageHidden()

            let frame = MRAIDController.cgRect(for: resizeProperties, from: webView)
            if frame.isInfinite {
                let message = "MRAID ad attempted to resize to an invalid size"
                Log.error(message)
                webView.MRAID_error(message, action: MRAIDAction.resize.rawValue)
                return
            }

            displayProperties.contentFrame = frame
            displayProperties.contentViewColor = .clear
            webView.backgroundColor = .clear

            //If we're resizing from an already resized state, the content should replace the existing content rather than
            //push on top of the existing InterstitialState stack.
            let shouldReplace = mraidState.isEqual(MRAIDState.resized)

            let modalState = Factory.createModalState(
                view: webView,
                adConfiguration: self.creative?.creativeModel.adConfiguration,
                displayProperties: displayProperties,
                onStatePopFinished: { [weak self] poppedState in
                    guard let self else { return }

                    self.modalManagerDidFinishPop(poppedState)
                }, onStateHasLeftApp: { [weak self] leavingState in
                    guard let self else { return }

                    self.modalManagerDidLeaveApp(leavingState)
                })
            modalState.mraidState = .resized

            guard let rootViewController = self.viewControllerForPresentingModals else {
                // The ObjC original passed the nil on into the non-nullable `ModalManager` parameter.
                Log.error("self.viewControllerForPresentingModals is nil for mraid command \(command)")
                return
            }

            self.dismissResizedModalState = self.creative?.modalManager?.pushModal(modalState,
                                                                                    fromRootViewController: rootViewController,
                                                                                    animated: false,
                                                                                    shouldReplace: shouldReplace,
                                                                                    completionHandler: { [weak self] in
                guard let self else { return }

                self.mraidState = .resized
                self.delayedMraidState = .resized

                self.creative?.modalManager?.modalViewController?
                    .addFriendlyObstructions(toMeasurementSession: self.creative?.transaction?.measurementSession)
            })

            self.creative?.eventManager.trackEvent(.click)
        }
    }

    private func handleMRAIDCommandClose() {
        var dismissModalStateBlock: VoidBlock?
        if creative?.transaction?.adConfiguration.presentAsInterstitial == true {
            dismissModalStateBlock = creative?.dismissInterstitialModalState
        } else if mraidState === MRAIDState.expanded {
            dismissModalStateBlock = dismissExpandedModalState
            dismissExpandedModalState = nil
        } else if mraidState === MRAIDState.resized {
            dismissModalStateBlock = dismissResizedModalState
            dismissResizedModalState = nil
        }
        dismissModalStateBlock?()
    }

    private func handleMRAIDCommandUnload() {
        Log.whereAmI()
        let creative = self.creative
        switch prebidWebView?.state {
        case .loaded:
            if creative?.transaction?.adConfiguration.presentAsInterstitial == true {
                handleMRAIDCommandClose()
                break
            }
            if mraidState === MRAIDState.expanded || mraidState === MRAIDState.resized {
                handleMRAIDCommandClose()
            }
            if let creative {
                creative.creativeViewDelegate?.creativeDidComplete(creative)
            }
        case .loading:
            creative?.creativeResolutionDelegate?.creativeFailed(PBMError.error(description: "The Ad called 'mraid.unload();'"))
        default:
            break
        }
    }

    private func handleMRAIDCommandPlayVideo(_ command: MRAIDCommand) throws {
        // TODO: This pattern seems flawed, `playVideo/` will pass this argument and URL check.
        guard let urlString = command.arguments.first else {
            throw MRAIDCommandError(message: "Insufficient arguments for MRAIDAction.playVideo")
        }

        guard let url = NSURL.pbmURLWithoutEncoding(from: urlString) else {
            throw MRAIDCommandError(message: "MRAID attempted to load an invalid URL: \(urlString)")
        }

        if viewControllerForPresentingModals == nil {
            throw MRAIDCommandError(message: "self.viewControllerForPresentingModals is nil")
        }

        playingMRAIDVideo = true

        //TODO: MRAID video should probably stream instead of pre-download.
        loadVideo(url)
    }

    private func handleMRAIDCommandOnOrientationPropertiesChanged(_ command: MRAIDCommand) throws {

        guard let jsonString = command.arguments.first else {
            throw MRAIDCommandError(message: "onOrientationPropertiesChanged - No JSON string")
        }

        guard let jsonDict = try? Functions.dictionaryFromJSONString(jsonString) else {
            throw MRAIDCommandError(message: "onOrientationPropertiesChanged - Unable to parse JSON string: \(jsonString)")
        }

        // The ObjC original sent `isEqualToString:` to whatever the dictionary held, so a non-string value raised
        // "unrecognized selector". It is treated like a missing key here.
        guard let strForceOrientation = jsonDict["forceOrientation"] as? String else {
            return
        }

        if strForceOrientation == MRAIDValues.LANDSCAPE {
            creative?.modalManager?.forceOrientation(.landscapeLeft)
        } else if strForceOrientation == MRAIDValues.PORTRAIT {
            creative?.modalManager?.forceOrientation(.portrait)
        }

        //Note: we currently ignore the allowOrientationChange property as there does not yet exist
        //an elegant way to disable rotation on the navigation controller that the publisher shows
        //the ad interstitial VC from.
    }

    private func loadVideo(_ url: URL) {
        // The ObjC original called the block unconditionally, so a nil block was a crash; it is a no-op here.
        downloadBlock?(url) { [weak self] data, error in
            guard let self else { return }

            if let error {
                Log.error("Unable to load MRAID video. Error: \(error)")
                return
            }

            // `self` is the strong reference from the guard above, captured strongly like the ObjC block
            // (which captured the local made by `@strongify`).
            DispatchQueue.main.async {

                // Create a container view. This will stretch to fit the available space.
                let containerView = UIView(frame: .zero)

                // `VideoView` cannot be built without an event manager; the ObjC original would have crashed inside it.
                guard let eventManager = self.creative?.eventManager else {
                    return
                }

                let videoView = VideoView(eventManager: eventManager)
                videoView.showMediaFileURL(url, preloadedData: data)

                containerView.addSubview(videoView)

                videoView.addFillSuperviewConstraints()

                let state = Factory.createModalState(
                    view: containerView,
                    adConfiguration: self.creative?.creativeModel.adConfiguration,
                    displayProperties: InterstitialDisplayProperties(),
                    onStatePopFinished: { [weak self] poppedState in
                        guard let self else { return }

                        self.modalManagerDidFinishPop(poppedState)
                    }, onStateHasLeftApp: { [weak self] leavingState in
                        guard let self else { return }

                        self.modalManagerDidLeaveApp(leavingState)
                    }, nextOnStatePopFinished: { [weak videoView] poppedState in
                        if let poppedState {
                            videoView?.modalManagerDidFinishPop(poppedState)
                        }
                    }, nextOnStateHasLeftApp: { [weak videoView] leavingState in
                        if let leavingState {
                            videoView?.modalManagerDidLeaveApp(leavingState)
                        }
                    }, onModalPushedBlock: {
                        // Strong capture of `videoView`, like the ObjC block.
                        videoView.pause()
                    })

                guard let rootViewController = self.viewControllerForPresentingModals else {
                    // The ObjC original passed the nil on into the non-nullable `ModalManager` parameter.
                    Log.error("self.viewControllerForPresentingModals is nil")
                    return
                }

                _ = self.creative?.modalManager?.pushModal(state,
                                                           fromRootViewController: rootViewController,
                                                           animated: true,
                                                           shouldReplace: false,
                                                           completionHandler: { [weak self] in
                    guard let self else { return }

                    videoView.startPlayback()
                    self.creative?.modalManager?.modalViewController?
                        .addFriendlyObstructions(toMeasurementSession: self.creative?.transaction?.measurementSession)
                })

                self.creative?.eventManager.trackEvent(.click)
            }
        }
    }

    // `properties` stays optional: the ObjC original answered `CGRectInfinite` for nil.
    static func cgRect(for properties: MRAIDResizeProperties?, from fromView: UIView) -> CGRect {
        guard let properties else {
            return .infinite
        }

        // check that the resize fits into the bounds of what's allowed
        if properties.width < 50 || properties.height < 50 {
            return .infinite
        }

        // get the view's absolute position
        guard let superview = fromView.superview else {
            Log.info("Could not determine a global point")
            return .infinite
        }

        let globalPoint = superview.convert(fromView.frame.origin, to: nil)

        // calc the resized rect based on global offset and resize properties
        // `(NSInteger)` casts saturate on arm64 and the sums wrap; Swift's `Int(_:)` and `+` would trap on creative-supplied extremes.
        var basicRect = CGRect(x: CGFloat(saturatingInteger(globalPoint.x) &+ properties.offsetX),
                               y: CGFloat(saturatingInteger(globalPoint.y) &+ properties.offsetY),
                               width: CGFloat(properties.width),
                               height: CGFloat(properties.height))
        Log.info("basicRect = \(NSCoder.string(for: basicRect))")

        // if offscreen is allowed, return with it
        if properties.allowOffscreen {
            if isValidCloseRegionPosition(basicRect) {
                return basicRect
            } else {
                return .infinite
            }
        }

        // else, check if it can fit on screen
        let screenSize = Functions.deviceScreenSize
        if basicRect.size.width > screenSize.width || basicRect.size.height > screenSize.height {
            return .infinite
        }

        // move it fully onscreen
        if basicRect.origin.x < 0 {
            basicRect.origin.x = 0
        }

        if basicRect.origin.y < 0 {
            basicRect.origin.y = 0
        }

        if basicRect.origin.x + basicRect.size.width > screenSize.width {
            basicRect.origin.x = screenSize.width - basicRect.size.width
        }

        if basicRect.origin.y + basicRect.size.height > screenSize.height {
            basicRect.origin.y = screenSize.height - basicRect.size.height
        }

        return basicRect
    }

    // `(NSInteger)value`: truncates toward zero, saturates out of range and maps NaN to 0, as the arm64 conversion does.
    private static func saturatingInteger(_ value: CGFloat) -> Int {
        if value.isNaN {
            return 0
        }
        if value >= CGFloat(Int.max) {
            return Int.max
        }
        if value <= CGFloat(Int.min) {
            return Int.min
        }
        return Int(value)
    }

    private static func isValidCloseRegionPosition(_ basicRect: CGRect) -> Bool {
        //Check the position of the close region
        //https://www.iab.com/wp-content/uploads/2017/07/MRAID_3.0_FINAL.pdf p.37
        //The host must always include a 50x50 density independent pixel close event
        //region. Recommended position is the top right corner of the container provided for the ad.
        let closeRegionX = basicRect.origin.x + basicRect.size.width - CGFloat(MRAIDCloseButtonSize.WIDTH)
        let closeRegion = CGRect(x: closeRegionX,
                                 y: basicRect.origin.y,
                                 width: CGFloat(MRAIDCloseButtonSize.WIDTH),
                                 height: CGFloat(MRAIDCloseButtonSize.HEIGHT))

        let deviceMaxSize = Functions.deviceMaxSize
        let saInsets = Functions.safeAreaInsets
        let safeArea = CGRect(x: saInsets.left,
                              y: saInsets.top + Functions.statusBarHeight,
                              width: deviceMaxSize.width,
                              height: deviceMaxSize.height)

        return safeArea.contains(closeRegion)
    }
}
