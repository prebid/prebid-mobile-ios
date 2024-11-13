/*   Copyright 2018-2024 Prebid.org, Inc.
 
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

import XCTest
import TestUtils
@testable import PrebidMobile

class BannerViewReloadTrackerTests: XCTestCase {
    
    func testInitWithDefaultInterval() {
        let expectation = self.expectation(description: "onReloadDetected should not be called")
        expectation.isInverted = true
        
        _ = BannerViewReloadTracker(onReloadDetected: {
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testStartSchedulesTimer() {
        let expectation = self.expectation(description: "onReloadDetected should not be called")
        expectation.isInverted = true
        
        let tracker = BannerViewReloadTracker(onReloadDetected: {
            expectation.fulfill()
        })
        
        let monitoredView = UIView()
        tracker.start(in: monitoredView)
        
        wait(for: [expectation], timeout: 5.0)
        
        tracker.stop()
    }
    
    func testDetectWebViewReloadCallsOnReloadDetected() {
        let expectation = self.expectation(description: "onReloadDetected should be called")
        
        let tracker = BannerViewReloadTracker(onReloadDetected: {
            expectation.fulfill()
        })
        
        let monitoredView = UIView()
        tracker.start(in: monitoredView)
        
        let webView = WKWebView()
        monitoredView.addSubview(webView)
        
        wait(for: [expectation], timeout: 5.0)
        tracker.stop()
    }
    
    func testDetectWebViewReloadMultipleReloads() {
        let expectation = self.expectation(description: "onReloadDetected should be called")
        expectation.expectedFulfillmentCount = 2
        
        let tracker = BannerViewReloadTracker(onReloadDetected: {
            expectation.fulfill()
        })
        
        let monitoredView = UIView()
        tracker.start(in: monitoredView)
        
        let webView1 = WKWebView()
        monitoredView.addSubview(webView1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            webView1.removeFromSuperview()
            let webView2 = WKWebView()
            monitoredView.addSubview(webView2)
        }
        
        wait(for: [expectation], timeout: 5.0)
        tracker.stop()
    }
}
