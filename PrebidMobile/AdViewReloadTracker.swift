//
//  ViewReloadTracker.swift
//  PrebidMobile
//
//  Created by Olena Stepaniuk on 05.11.2024.
//  Copyright © 2024 AppNexus. All rights reserved.
//

import UIKit
import WebKit

/// In GAM banner view auto reloads and its webview changes.
/// This class is dedicated to track this event using polling method.
class AdViewReloadTracker {
    
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
            stopMonitoring()
            return
        }
        
        // Look for a WKWebView in the view hierarchy
        if let foundWebView = findWebView(in: targetView) {
            // Check if the found WebView is different from the current one
            if currentWebView !== foundWebView {
                currentWebView = foundWebView
                onAdReload() // Fire the callback if the WebView instance has changed
            }
        } else {
            // If no WebView is found, reset the currentWebView reference
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
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopMonitoring()
    }
}
