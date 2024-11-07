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
import WebKit

/// When GAM banner view auto reloads => its webview changes.
/// This class is dedicated to track this event using polling method.
class BannerViewReloadTracker {
    
    private weak var targetView: UIView?
    private var currentWebView: WKWebView?
    private var timer: Timer?
    private let onAdReload: () -> Void
    
    init(in targetView: UIView, onAdReload: @escaping () -> Void) {
        self.targetView = targetView
        self.onAdReload = onAdReload
    }
    
    func start() {
        let timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(checkForWebViewChanges),
            userInfo: nil,
            repeats: true
        )
        
        self.timer = timer
        
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc private func checkForWebViewChanges() {
        guard let targetView = targetView else {
            stop()
            return
        }
        
        if let foundWebView = findWebView(in: targetView) {
            if currentWebView !== foundWebView {
                currentWebView = foundWebView
                onAdReload()
            }
        } else {
            currentWebView = nil
        }
    }
    
    private func findWebView(in view: UIView) -> WKWebView? {
        if let webView = view as? WKWebView {
            return webView
        }
        
        for subview in view.subviews {
            if let webView = findWebView(in: subview) {
                return webView
            }
        }
        
        return nil
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
}
