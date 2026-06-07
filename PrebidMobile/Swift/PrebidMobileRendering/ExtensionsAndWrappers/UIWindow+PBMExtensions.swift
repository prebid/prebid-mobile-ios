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

extension UIWindow {

    @objc public static func appVisibleViewController() -> UIViewController? {
        UIApplication.shared.keyWindow?.visibleViewController()
    }

    @objc public func visibleViewController() -> UIViewController? {
        guard let root = rootViewController else { return nil }
        return UIWindow.getVisibleViewControllerFrom(root)
    }

    @objc(getVisibleViewControllerFrom:)
    public static func getVisibleViewControllerFrom(_ vc: UIViewController) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return nav.visibleViewController.flatMap { getVisibleViewControllerFrom($0) }
        }
        if let tab = vc as? UITabBarController {
            return tab.selectedViewController.flatMap { getVisibleViewControllerFrom($0) }
        }
        if let presented = vc.presentedViewController {
            return getVisibleViewControllerFrom(presented)
        }
        return vc
    }
}
