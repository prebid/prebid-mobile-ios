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

/// Monitors changes to the `WKWebView` instance when the GAM banner view auto-reloads,
/// which replaces its underlying web view. This class uses a polling mechanism to detect
/// and respond to these changes.
class BannerViewReloadTracker {
    
    private weak var monitoredView: UIView?
    private weak var activeWebView: WKWebView?
    
    private var timer: Timer?
    private var reloadCheckInterval: TimeInterval
    
    private let onReloadDetected: () -> Void
    
    init(reloadCheckInterval: TimeInterval = 1.0, onReloadDetected: @escaping () -> Void) {
        self.reloadCheckInterval = reloadCheckInterval
        self.onReloadDetected = onReloadDetected
    }
    
    func start(in monitoredView: UIView?) {
        self.monitoredView = monitoredView
        
        let timer = Timer.scheduledTimer(
            timeInterval: reloadCheckInterval,
            target: self,
            selector: #selector(detectWebViewReload),
            userInfo: nil,
            repeats: true
        )
        
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc private func detectWebViewReload() {
        guard let monitoredView = monitoredView else {
            stop()
            return
        }
        
        let allWebViews = monitoredView.allSubViewsOf(type: WKWebView.self)
        
        if allWebViews.count == 1 {
            Log.error("SDK met unexpected number of web views in third-party ad view.")
        }
        
        let foundWebView = allWebViews.first
        
        if activeWebView !== foundWebView {
            onReloadDetected()
        }
        
        activeWebView = foundWebView
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        monitoredView = nil
        activeWebView = nil
    }
    
    deinit {
        stop()
    }
}
