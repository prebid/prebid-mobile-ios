/*   Copyright 2018-2021 Prebid.org, Inc.

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
import SafariServices

@objc(PBMSafariVCOpener) @_spi(PBMInternal) public
class SafariVCOpener: NSObject, SFSafariViewControllerDelegate {

    private let sdkConfiguration: Prebid
    private let modalManager: ModalManager?

    private let viewControllerProvider: () -> UIViewController?
    private let measurementSessionProvider: () -> OMSession?

    private let onWillLoadURLInClickthrough: VoidBlock?
    private let onWillLeaveAppBlock: VoidBlock?
    private let onClickthroughPoppedBlock: ModalStatePopHandler?
    private let onDidLeaveAppBlock: ModalStateAppLeavingHandler?

    private var onClickthroughExitBlock: VoidBlock?

    var safariViewController: SFSafariViewController?
    private var windowLockers = [Int: WindowLocker]()
    private var currentWindowLockerKey: Int?

    @available(*, unavailable)
    override init() {
        fatalError("init() is unavailable")
    }

    @objc(initWithSDKConfiguration:modalManager:viewControllerProvider:measurementSessionProvider:onWillLoadURLInClickthrough:onWillLeaveAppBlock:onClickthroughPoppedBlock:onDidLeaveAppBlock:)
    public init(
        sdkConfiguration: Prebid,
        modalManager: ModalManager?,
        viewControllerProvider: @escaping () -> UIViewController?,
        measurementSessionProvider: @escaping () -> OMSession?,
        onWillLoadURLInClickthrough: VoidBlock?,
        onWillLeaveAppBlock: VoidBlock?,
        onClickthroughPoppedBlock: ModalStatePopHandler?,
        onDidLeaveAppBlock: ModalStateAppLeavingHandler?
    ) {
        self.sdkConfiguration = sdkConfiguration
        self.modalManager = modalManager
        self.viewControllerProvider = viewControllerProvider
        self.measurementSessionProvider = measurementSessionProvider
        self.onWillLoadURLInClickthrough = onWillLoadURLInClickthrough
        self.onWillLeaveAppBlock = onWillLeaveAppBlock
        self.onClickthroughPoppedBlock = onClickthroughPoppedBlock
        self.onDidLeaveAppBlock = onDidLeaveAppBlock
        super.init()
    }

    @objc(openURL:onClickthroughExitBlock:)
    public func openURL(_ url: URL, onClickthroughExitBlock: VoidBlock?) -> Bool {
        self.onClickthroughExitBlock = onClickthroughExitBlock

        guard let urlScheme = getURLScheme(url) else {
            Log.error("Could not determine URL scheme from url: \(url)")
            return false
        }

        if !shouldTryOpenURLScheme(urlScheme) {
            Log.error("Attempting to open url [\(url)] in iOS simulator, but simulator does not support url scheme of \(urlScheme)")
            return false
        }

        guard let viewControllerForPresentingModals = viewControllerProvider() else {
            Log.error("self.viewControllerForPresentingModals is nil")
            return false
        }

        if !(urlScheme == "http" || urlScheme == "https") {
            Log.error("Attempting to open url [\(url)] in SFSafariViewController. SFSafariViewController only supports initial URLs with http:// or https:// schemes.")
            return false
        }

        // Show clickthrough browser

        return openClickthrough(with: url, viewController: viewControllerForPresentingModals)
    }

    // MARK: - Private

    private func getURLScheme(_ url: URL) -> String? {
        url.scheme?.lowercased()
    }

    private func shouldTryOpenURLScheme(_ urlScheme: String) -> Bool {
        if Functions.isSimulator && PrebidConstants.URL_SCHEMES_NOT_SUPPORTED_ON_SIMULATOR.contains(urlScheme) {
            return false
        }

        return true
    }

    private func openClickthrough(with url: URL, viewController viewControllerForPresentingModals: UIViewController) -> Bool {
        if let safariViewController, safariViewController.presentingViewController != nil {
            Log.info("⚠️ Safari already being presented, ignoring")
            return false
        }

        let newSafariViewController = SFSafariViewController(url: url)
        safariViewController = newSafariViewController
        newSafariViewController.delegate = self

        var presentingViewController = viewControllerForPresentingModals

        if let modalViewController = modalManager?.modalViewController {
            presentingViewController = modalViewController
        }

        if presentingViewController.presentedViewController != nil {
            Log.info("⚠️ Presenting view controller is already presenting something")
            return false
        }

        let window = viewControllerForPresentingModals.view.window
        let key = window?.hash ?? 0
        let measurementSession = measurementSessionProvider()
        let windowLocker = windowLocker(for: window, measurementSession: measurementSession)
        windowLocker.lock()

        currentWindowLockerKey = key

        onWillLoadURLInClickthrough?()

        presentingViewController.present(newSafariViewController, animated: true) {
            windowLocker.unlock()
        }

        return true
    }

    private func windowLocker(for window: UIWindow?, measurementSession: OMSession?) -> WindowLocker {
        let key = window?.hash ?? 0

        if let locker = windowLockers[key] {
            return locker
        }

        let locker = WindowLocker(window: window, measurementSession: measurementSession)
        windowLockers[key] = locker
        return locker
    }

    // MARK: - SFSafariViewControllerDelegate

    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let currentWindowLockerKey {
            windowLockers.removeValue(forKey: currentWindowLockerKey)
            self.currentWindowLockerKey = nil
        }

        onClickthroughPoppedBlock?(nil)
        onClickthroughExitBlock?()
    }

    public func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
        onDidLeaveAppBlock?(nil)
    }
}
