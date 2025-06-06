/*   Copyright 2018-2024 Prebid.org, Inc.

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

extension UIApplication {
    
    func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .last { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    static func topViewController() -> UIViewController? {
        var topController = UIApplication.shared
            .windows
            .filter({ $0.isKeyWindow }).first?
            .rootViewController
        
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
    
    func openExternalURL(_ url: URL) -> Bool {
        guard canOpenURL(url) else { return false }
        
        open(url, options: [:], completionHandler: nil)
        return true
    }
}
