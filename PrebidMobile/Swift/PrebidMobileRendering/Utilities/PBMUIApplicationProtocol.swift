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

@objc public protocol PBMUIApplicationProtocol: NSObjectProtocol {
    var isStatusBarHidden: Bool { get }
    var statusBarOrientation: UIInterfaceOrientation { get }
    var statusBarFrame: CGRect { get }

    /// The window the SDK measures safe-area insets against.
    ///
    /// Part of the protocol so that `Functions.safeAreaInsets` can resolve it through the
    /// `Functions.application` test-injection seam like every other application read.
    /// Deliberately not named `keyWindow`: that would bind the `UIApplication` conformance
    /// to the property deprecated since iOS 13, whose result is undefined for multi-scene
    /// apps — the case that matters for an SDK rendering inside a host app's window.
    var pbmKeyWindow: UIWindow? { get }

    @objc(openURL:options:completionHandler:)
    func open(_ url: URL,
              options: [UIApplication.OpenExternalURLOptionsKey: Any],
              completionHandler: ((Bool) -> Void)?)
}

extension UIApplication: PBMUIApplicationProtocol {

    public var pbmKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKeyWindow }
    }
}
