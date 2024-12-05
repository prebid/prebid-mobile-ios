/*   Copyright 2018-2021 Prebid.org, Inc.
 
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

import Foundation
import XCTest

import UIKit
import AdSupport
@testable import PrebidMobile

// MARK: - Mocks

class MockWKNavigationAction : WKNavigationAction {
    override var request: URLRequest {
        return mockedRequest ?? URLRequest(url: URL(string: "openx.com")!)
    }
    
    var mockedRequest: URLRequest?
    
    init(mockedRequest: URLRequest? = nil) {
        self.mockedRequest = mockedRequest
    }
}

// MARK: - TestCase

class PBMWebViewTest : XCTestCase, PBMWebViewDelegate {
    
    // MARK: - Test Properties
    
    let openxURL = URL(string: "openx.com")!
    
    let testEmptyString = ""
    let testHTML = "<HTML><body style='margin: 0; padding: 0;'><div id=\"ad\">\n<a href=\"http://openx.com/product/ad-server/\">\n<img src=\"http://i-cdn.openx.com/5a7/5a731840-5ae7-4dca-ba66-6e959bb763e2/93e/93e8623e977d43df87d8c6087142e838.png\" alt=\"Banner Advertisement\" height=\"50\" width=\"320\"></a>\n</div></body></HTML>"
    let testHTMLMissingOpeningTag = "<body style='margin: 0; padding: 0;'><div id=\"ad\">\n<a href=\"http://openx.com/product/ad-server/\">\n<img src=\"http://i-cdn.openx.com/5a7/5a731840-5ae7-4dca-ba66-6e959bb763e2/93e/93e8623e977d43df87d8c6087142e838.png\" alt=\"Banner Advertisement\" height=\"50\" width=\"320\"></a>\n</div></body></HTML>"
    let testHTMLMissingClosingTag = "<HTML><body style='margin: 0; padding: 0;'><div id=\"ad\">\n<a href=\"http://openx.com/product/ad-server/\">\n<img src=\"http://i-cdn.openx.com/5a7/5a731840-5ae7-4dca-ba66-6e959bb763e2/93e/93e8623e977d43df87d8c6087142e838.png\" alt=\"Banner Advertisement\" height=\"50\" width=\"320\"></a>\n</div></body>"
    
    var expectationWebViewFailed: XCTestExpectation?
    var expectationWebViewReadyToDisplay: XCTestExpectation?
    var expectationWebViewReceivedMRAIDLink: XCTestExpectation?
    var expectationWebViewShouldOpenExternalLink: XCTestExpectation?
    
    var expectationCommandExecuted: XCTestExpectation?
    
    var readyToDisplayBlock: (() -> Void)?
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        PrebidJSLibraryManager.shared.downloadLibraries()
    }
    
    override func tearDown() {
        expectationCommandExecuted = nil
        logToFile = nil
        
        PrebidJSLibraryManager.shared.downloadLibraries()
        super.tearDown()
    }
    
    // MARK: - Test Initial Settings
    
    func testRequiredProperties() {
        let webView = PBMWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let webViewConfig = webView.internalWebView.configuration
        
        //MRAID-required properties
        //see section '8.4 Video' (page 68) of MRAID 3.0 specification
        XCTAssertTrue(webViewConfig.allowsInlineMediaPlayback)
        if #available(iOS 10.0, *) {
            XCTAssertEqual(webViewConfig.mediaTypesRequiringUserActionForPlayback, [])
        } else {
            XCTAssertFalse(webViewConfig.mediaPlaybackRequiresUserAction)
        }
    }
    
    // MARK: - Test Utilites
    
    func testIsVisible() {
        
        // Test objects
        
        let parentView = UIView()
        let parentWindow = UIWindow()
        let testView = UIView()
        
        parentWindow.isHidden = false
        
        // TEST: invalid param
        
        XCTAssertFalse(PBMWebView.isVisibleView(nil))
        XCTAssertFalse(PBMWebView.isVisibleView(testView))
        XCTAssertFalse(PBMWebView.isVisibleView(parentWindow))
        
        // TEST: with parent UIView
        
        parentView.addSubview(testView)
        XCTAssertFalse(PBMWebView.isVisibleView(testView))
        
        testView.removeFromSuperview()
        
        // Tests: with parent UIWindow
        
        parentWindow.addSubview(testView)
        XCTAssertFalse(PBMWebView.isVisibleView(testView))
        
        let unitFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
        parentWindow.frame = unitFrame
        parentView.frame = unitFrame
        testView.frame = unitFrame
        XCTAssertTrue(PBMWebView.isVisibleView(testView))
        
        // TEST: move out of range
        
        parentWindow.frame  = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        testView.frame      = CGRect(x: 101.0, y: 101.0, width: 100, height: 100)
        XCTAssertFalse(PBMWebView.isVisibleView(testView))
        
        testView.removeFromSuperview()
        testView.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        
        // TEST: with parent complex hierarchy
        
        parentView.addSubview(testView)
        parentWindow.addSubview(parentView)
        
        XCTAssertTrue(PBMWebView.isVisibleView(testView))
    }
    
    func testIsVisible2() {
        // +--------+
        // |root    |
        // |   +-------------------+
        // |   |grandparent        |
        // |   |        +------+   |
        // |   |        |parent|   |
        // |   +--------|      |---+
        // |        |   |      |
        // |        |   |      |
        // |      +--------+   |
        // |      |view    |   |
        // |      |        |   |
        // |      +--------+   |
        // |        |   |      |
        // |        |   +------+
        // |        |
        // +--------+
        //
        // +-------------+-------+-----+-------+
        // |    view     | p-glob|p-loc|  size |
        // +-------------+-------+-----+-------+
        // | root        |  0, 0 | 0, 0|  9x16 |
        // | grandparent |  4, 2 | 4, 2| 20x 4 |
        // | parent      | 12, 4 | 8, 2|  7x10 |
        // | view        |  6, 9 |-6, 5|  9x 3 |
        // +-------------+-------+-----+-------+
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 160))
        let grandparent = UIView(frame: CGRect(x: 40, y: 20, width: 200, height: 40))
        let parent = UIView(frame: CGRect(x: 80, y: 20, width: 70, height: 100))
        let view = UIView(frame: CGRect(x: -60, y: 50, width: 90, height: 30))
        
        window.addSubview(root)
        root.addSubview(grandparent)
        grandparent.addSubview(parent)
        parent.addSubview(view)
        
        window.isHidden = false
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertTrue(PBMWebView.isVisibleView(grandparent))
        XCTAssertTrue(PBMWebView.isVisibleView(parent))
        XCTAssertTrue(PBMWebView.isVisibleView(view))
        
        grandparent.clipsToBounds = true
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertTrue(PBMWebView.isVisibleView(grandparent))
        XCTAssertTrue(PBMWebView.isVisibleView(parent))
        XCTAssertFalse(PBMWebView.isVisibleView(view))
        
        XCTAssertEqual(parent.viewExposure, PBMViewExposure(exposureFactor: 0.2, visibleRectangle: CGRect(x: 0, y: 0, width: 70, height: 20)));
        XCTAssertEqual(view.viewExposure, .zero);
        
        grandparent.clipsToBounds = false
        root.clipsToBounds = true
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertTrue(PBMWebView.isVisibleView(grandparent))
        XCTAssertFalse(PBMWebView.isVisibleView(parent))
        XCTAssertTrue(PBMWebView.isVisibleView(view))
        
        XCTAssertEqual(grandparent.viewExposure, PBMViewExposure(exposureFactor: 0.25, visibleRectangle: CGRect(x: 0, y: 0, width: 50, height: 40)));
        XCTAssertEqual(parent.viewExposure, .zero);
        XCTAssertEqual(view.viewExposure, PBMViewExposure(exposureFactor: 1.0/3, visibleRectangle: CGRect(x: 0, y: 0, width: 30, height: 30)));
        
        parent.clipsToBounds = true
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertTrue(PBMWebView.isVisibleView(grandparent))
        XCTAssertFalse(PBMWebView.isVisibleView(parent))
        XCTAssertFalse(PBMWebView.isVisibleView(view))
        
        XCTAssertEqual(view.viewExposure, .zero);
    }
    
    func testIsVisible3() {
        // +------+
        // |root  |
        // |      |   +------+
        // |      |   |parent|
        // |      |   |      |
        // |   +---------+   |
        // |   |view     |   |
        // |   |         |   |
        // |   +---------+   |
        // |      |   |      |
        // |      |   +------+
        // |      |
        // +------+
        //
        // +-------------+-------+-----+-------+
        // |    view     | p-glob|p-loc|  size |
        // +-------------+-------+-----+-------+
        // | root        |  0, 0 | 0, 0|  9x12 |
        // | parent      | 10, 2 |10, 2|  7x 8 |
        // | view        |  3, 5 |-7, 3| 10x 3 |
        // +-------------+-------+-----+-------+
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        let root = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 120))
        let parent = UIView(frame: CGRect(x: 100, y: 20, width: 70, height: 80))
        let view = UIView(frame: CGRect(x: -70, y: 30, width: 100, height: 30))
        
        window.addSubview(root)
        root.addSubview(parent)
        parent.addSubview(view)
        
        window.isHidden = false
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertTrue(PBMWebView.isVisibleView(parent))
        XCTAssertTrue(PBMWebView.isVisibleView(view))
        
        root.clipsToBounds = true
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertFalse(PBMWebView.isVisibleView(parent))
        XCTAssertTrue(PBMWebView.isVisibleView(view))
        
        parent.clipsToBounds = true
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertFalse(PBMWebView.isVisibleView(parent))
        XCTAssertFalse(PBMWebView.isVisibleView(view))
        
        root.clipsToBounds = false
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertTrue(PBMWebView.isVisibleView(parent))
        XCTAssertTrue(PBMWebView.isVisibleView(view))
        
        parent.clipsToBounds = false
        
        parent.isHidden = true;
        
        XCTAssertTrue(PBMWebView.isVisibleView(root))
        XCTAssertFalse(PBMWebView.isVisibleView(parent))
        XCTAssertFalse(PBMWebView.isVisibleView(view))
    }
    
    func testAnyToJSONDict() {
        
        //Test valid input
        XCTAssertNotNil(PBMWebView.any(toJSONDict: "{}"))
        XCTAssertNotNil(PBMWebView.any(toJSONDict: "{\"test\" : {\"key\" : \"value\", \"vlue\" : \"key\"}}"))
        
        //Confirm that invalid input will result in a nil
        XCTAssertNil(PBMWebView.any(toJSONDict: nil))
        XCTAssertNil(PBMWebView.any(toJSONDict: UIView()))
        XCTAssertNil(PBMWebView.any(toJSONDict: [""]))
        XCTAssertNil(PBMWebView.any(toJSONDict: ["":""]))
        XCTAssertNil(PBMWebView.any(toJSONDict: ""))
        XCTAssertNil(PBMWebView.any(toJSONDict: "test"))
        XCTAssertNil(PBMWebView.any(toJSONDict: "test{}"))
        XCTAssertNil(PBMWebView.any(toJSONDict: "⛵"))
        XCTAssertNil(PBMWebView.any(toJSONDict: "Ũ"))
        XCTAssertNil(PBMWebView.any(toJSONDict: "[]"))
    }
    
    func testWebViewStateDescription() {
        let cases: [PBMWebViewState] = [.unloaded, .loading,  .loaded]
        
        cases.forEach {
            let description = PBMWebView.webViewStateDescription($0)
            
            // use switch to be sure that all cases are listed
            switch $0 {
            case .unloaded      : XCTAssertEqual(description, "unloaded")
            case .loading       : XCTAssertEqual(description, "loading")
            case .loaded        : XCTAssertEqual(description, "loaded")
            @unknown default:
                return
            }
        }
    }
    
    func testChangeToMRAIDState() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        webView.changeToMRAIDState(PBMMRAIDState.default)
        XCTAssertEqual(webView.mraidState, PBMMRAIDState.default)
    }
    
    // MARK: - Test UIGestureRecognizerDelegate
    func testsGestureRecognizerDelegate() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        XCTAssertTrue(webView.gestureRecognizer(UIGestureRecognizer(), shouldRecognizeSimultaneouslyWith:UIGestureRecognizer()))
    }
    
    // MARK: - Test WKUIDelegate
    func testWindowOpenTargets() {
        Log.logToFile = true
        for sendTap in [true, false] {
            
            //This is the "target" field for window.open(url, target)
            for target in ["_self", "_blank", "_top"] {
                
                //WKWebView suppresses window.open when the target is _blank
                let webViewWillSuppressWindowOpen = ["_blank", ""].contains(target)
                
                //When window.open is not suppressed and we send a tap, we expect a clickthrough
                let expectClickThrough = !webViewWillSuppressWindowOpen && sendTap
                
                //When window.open is not suppressed and we do NOT send a tap, we expect a message saying that an autoclick was suppressed.
                let expectAutoClickSuppressionMessage = !webViewWillSuppressWindowOpen && !sendTap
                
                windowOpen(sendTap:sendTap, target:target, expectClickThrough:expectClickThrough, expectAutoClickSuppressionMessage: expectAutoClickSuppressionMessage)
            }
        }
    }
    
    func windowOpen(sendTap:Bool, target:String, expectClickThrough:Bool, expectAutoClickSuppressionMessage:Bool) {
        logToFile = nil
        logToFile = .init()
        
        let webView = PBMWebView()
        webView.delegate = self
        
        //Fake a tap on the webview
        if (sendTap) {
            webView.recordTapEvent(webView.tapdownGestureRecognizer)
        }
        
        self.expectationWebViewShouldOpenExternalLink = expectation(description: "expectationWebViewShouldOpenExternalLink")
        if (!expectClickThrough) {
            self.expectationWebViewShouldOpenExternalLink?.isInverted = true
        }
        
        let html =
        """
        <html><body><script>
        console.log('Before window.open');
        window.open('http://foo.com', '\(target)');
        console.log('After window.open');
        </script></body></html>
        """
        
        webView.loadHTML(html, baseURL:nil, injectMraidJs:true)
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        XCTAssertEqual(webView.state, .loading)
        
        self.waitForExpectations(timeout: 5) { (error) in
            if error != nil {
                Log.info("sendTap:\(sendTap), target:\"\(target)\", expectClickThrough: \(expectClickThrough), expectAutoClickSuppressionMessage:\(expectAutoClickSuppressionMessage)")
            }
        }
        
        //Make sure the log contains a "before" and "after" message to verify that the window.open command ran without error.
        let log = Log.getLogFileAsString() ?? ""
        print("Log: \(log)")
        XCTAssertTrue(log.contains("Before window.open"))
        XCTAssertTrue(log.contains("After window.open"))
        
        let expected = expectAutoClickSuppressionMessage
        //Note: under iOS14 the opened URL maybe http://www.foo.com/ or http://foo.com/
        let actual = log.contains("Auto-click suppression is preventing navigation to: ")
        XCTAssert(expected == actual, "Auto-click suppression message: Expected \(expected), got \(actual) for sendTap:\(sendTap), target:[\(target)]")
    }
    
    
    // MARK: - Test WKNavigationDelegate
    
    func testDecidePolicyForNavigationActionUnprocessingCases(){
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        logToFile = .init()
        
        // Test: no url
        webView.webView(webView.internalWebView, decidePolicyFor: WKNavigationAction(), decisionHandler: { policy in
            let log = Log.getLogFileAsString() ?? ""
            XCTAssertTrue(log.contains("No URL found on WKWebView navigation"))
            XCTAssertEqual(policy, .cancel)
        })
        
        // Test: first url
        XCTAssertEqual(webView.state, .loading)
        let navigationAction = MockWKNavigationAction()
        navigationAction.mockedRequest = URLRequest(url: openxURL)
        webView.webView(webView.internalWebView, decidePolicyFor: navigationAction, decisionHandler: { policy in
            XCTAssertEqual(policy, .allow)
        })
        
        // Test: view in some intermediate state
        webView.state = .unloaded
        webView.webView(webView.internalWebView, decidePolicyFor: navigationAction, decisionHandler: { policy in
            let log = Log.getLogFileAsString() ?? ""
            XCTAssertTrue(log.contains("Unexpected state "))
            XCTAssertEqual(policy, .cancel)
        })
        
        // Test: Prevent malicious auto-clicking
        webView.state = .loaded
        webView.webView(webView.internalWebView, decidePolicyFor: navigationAction, decisionHandler: { policy in
            let log = Log.getLogFileAsString() ?? ""
            XCTAssertTrue(log.contains("User has not recently tapped."))
            XCTAssertEqual(policy, .cancel)
        })
    }
    
    func testDecidePolicyForNavigationActionMRAIDLink(){
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        expectationWebViewReceivedMRAIDLink = expectation(description: "expectationWebViewShouldOpenMRAID")
        expectationWebViewShouldOpenExternalLink = expectation(description: "expectationWebViewShouldOpenExternal")
        expectationWebViewShouldOpenExternalLink?.isInverted = true
        
        let navigationAction = MockWKNavigationAction()
        navigationAction.mockedRequest = URLRequest(url: URL(string: "mraid://test")!)
        
        webView.state = .loaded
        webView.recordTapEvent(webView.tapdownGestureRecognizer)
        
        webView.webView(webView.internalWebView, decidePolicyFor: navigationAction, decisionHandler: { policy in
            XCTAssertEqual(policy, .cancel)
        })
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testDecidePolicyForNavigationActionExternalLink(){
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        expectationWebViewShouldOpenExternalLink = expectation(description: "expectationWebViewShouldOpenExternal")
        expectationWebViewReceivedMRAIDLink = expectation(description: "expectationWebViewShouldOpenMRAID")
        expectationWebViewReceivedMRAIDLink?.isInverted = true
        
        let navigationAction = MockWKNavigationAction()
        navigationAction.mockedRequest = URLRequest(url: openxURL)
        
        webView.state = .loaded
        webView.recordTapEvent(webView.tapdownGestureRecognizer)
        
        webView.webView(webView.internalWebView, decidePolicyFor: navigationAction, decisionHandler: { policy in
            XCTAssertEqual(policy, .cancel)
        })
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testDidFinishNavigationReadyToDisplay() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        XCTAssertNotEqual(webView.state, .loaded)
        
        expectationWebViewReadyToDisplay = expectation(description: "expectationWebViewReadyToDisplay")
        
        webView.webView(webView.internalWebView, didFinish:nil)
        
        waitForExpectations(timeout: 3, handler: { _ in
            webView.state = .loaded;
        })
    }
    
    func testDidFinishNavigation() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        webView.state = .loaded;
        
        expectationWebViewReadyToDisplay = expectation(description: "expectationWebViewReadyToDisplay")
        expectationWebViewReadyToDisplay?.isInverted = true
        
        webView.webView(webView.internalWebView, didFinish:nil)
        
        waitForExpectations(timeout: 3, handler: { _ in
            webView.state = .loaded;
        })
    }
    
    func testDidFailNavigation() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        expectationWebViewFailed = expectation(description: "expectationWebViewFailed")
        
        let error = NSError(domain:"Test", code: 0) as Error
        webView.webView(webView.internalWebView, didFail:nil, withError: error)
        
        waitForExpectations(timeout: 3, handler: { _ in
            webView.state = .loaded;
        })
    }
    
    // MARK: - GestureRecognizer
    
    func testInvokeRecordTapEvent() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        // Test: should react only on internal tap recognizer
        XCTAssertFalse(webView.wasRecentlyTapped())
        webView.recordTapEvent(nil)
        webView.recordTapEvent(UITapGestureRecognizer())
        XCTAssertFalse(webView.wasRecentlyTapped())
        
        // Test: change internal state
        webView.recordTapEvent(webView.tapdownGestureRecognizer)
        XCTAssertTrue(webView.wasRecentlyTapped())
    }
    
    // MARK: - Test methods
    
    func testExpand() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        XCTAssertEqual(webView.mraidState, .notEnabled)
        
        // TESTS: state must change
        let expandedPredicate = NSPredicate(format: "mraidState == \"expanded\"" )
        expectation(for: expandedPredicate, evaluatedWith: webView, handler: nil)
        
        // FIXME: Investigate cause of different webview states per OS version
        // Older OSes fire [PBMWebView webView:didFinishNavigation:] earlier
        // than we are expecting.
        let osVersion = Int(UIDevice.current.systemVersion.split(separator: ".")[0])!
        let expectedState = (osVersion >= 10) ? PBMWebViewState.loading.rawValue : PBMWebViewState.loaded.rawValue
        let loadingPredicate = NSPredicate(format: "state == \(expectedState)" )
        expectation(for: loadingPredicate, evaluatedWith: webView, handler: nil)
        
        webView.expand(openxURL)
        
        waitForExpectations(timeout: 10)
    }
    
    func testExpandGlobalQueue() {
        
        class MockWebView: PBMWebView {
            
            var thread: PBMThread?
            
            override func expand(_ url: URL) {
                expand(url, currentThread: thread ?? Thread.current)
            }
        }
        
        let webView = MockWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        XCTAssertEqual(webView.mraidState, .notEnabled)
        
        let expectationCheckThread = self.expectation(description: "Check thread expectation")
        expectationCheckThread.expectedFulfillmentCount = 2
        
        let mockedThread = PBMThread { isCalledFromMainThread in
            expectationCheckThread.fulfill()
        }
        
        webView.thread = mockedThread
         
        DispatchQueue.global().async {
            webView.expand(self.openxURL, currentThread: mockedThread)
        }
        
        waitForExpectations(timeout: 3)
    }
    
    func testExpandInvalidMRAID() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        
        webView.libraryManager = nil
        
        expectationWebViewFailed = expectation(description: "expectationWebViewFailed")
        
        webView.expand(URL(string: "openx.com")!)
        
        waitForExpectations(timeout: 3)
    }
    
    // MARK: -  Methods
    
    func testInjectMRAIDForExpandContentEmptyFile() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        
        webView.libraryManager = nil
        
        var testError: Error? = nil
        do {
            try webView.injectMRAIDForExpandContent(true)
        }
        catch {
            testError = error
        }
        
        XCTAssertNotNil(testError)
        XCTAssertTrue(testError?.localizedDescription.contains("Could not load mraid.js from library manager") ?? false)
    }
    
    func testLoadHTMLEmpty() {
        let webView = PBMWebView()
        webView.loadHTML("", baseURL:nil, injectMraidJs: false)
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        XCTAssertEqual(webView.state, .loading)
    }
    
    func testLoadHTMLValid() {
        let webView = PBMWebView()
        webView.delegate = self
        
        self.expectationWebViewReadyToDisplay = expectation(description:"expectationWebViewReadyToDisplay")
        
        webView.loadHTML(self.testHTML, baseURL:nil, injectMraidJs: false)
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        XCTAssertEqual(webView.state, .loading)
        
        waitForExpectations(timeout: 5, handler:nil)
        XCTAssertEqual(webView.state, .loaded)
    }
    
    func testLoadHTMLGlobalQueue() {
        let webView = PBMWebView()
        webView.delegate = self
        
        expectationWebViewReadyToDisplay = expectation(description:"expectationWebViewReadyToDisplay")
        
        logToFile = .init()
        webView.loadHTML(self.testHTML, baseURL:nil, injectMraidJs: false, currentThread: MockNSThread(mockIsMainThread: false))
        UtilitiesForTesting.checkLogContains("Attempting to loadHTML on background thread")
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        XCTAssertEqual(webView.state, .loading)
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(webView.state, .loaded)
        })
    }
    
    func testLoadHTMLValidWithMRAID() {
        let webView = PBMWebView()
        webView.delegate = self
        
        expectationWebViewReadyToDisplay = expectation(description:"expectationWebViewReadyToDisplay")
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        XCTAssertEqual(webView.state, .loading)
        
        waitForExpectations(timeout: 5, handler: { _ in
            XCTAssertEqual(webView.state, .loaded)
            XCTAssertEqual(webView.mraidState, PBMMRAIDState.default)
        })
    }
    
    func testLoadHTMLValidWithInvalidMRAID() {
        let webView = PBMWebView()
        webView.delegate = self
        
        expectationWebViewFailed = expectation(description: "expectationWebViewFailed")
        expectationWebViewFailed?.isInverted = true;
        
        expectationWebViewReadyToDisplay = expectation(description:"expectationWebViewReadyToDisplay")
        expectationWebViewReadyToDisplay?.isInverted = true;
        
        webView.libraryManager = nil
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        XCTAssertEqual(webView.mraidState, .notEnabled)
        XCTAssertEqual(webView.state, .loading)
        
        waitForExpectations(timeout: 3)
    }
    
    // MARK: - MRAID
    
    func testMRAID_error() {
        let webView = PBMWebView()
        webView.delegate = self
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        // Note (YV): Looks like we can only check the log.
        // I've not figure out the Response to the error from web view
        logToFile = .init()
        
        webView.MRAID_error("test error", action: PBMMRAIDAction.log)
        
        let log = Log.getLogFileAsString() ?? ""
        
        XCTAssertTrue(log.contains("Action: [\(PBMMRAIDAction.log.rawValue)] generated error with message [test error]"))
    }
    
    func testMRAID_getResizeProperties() {
        let webView = PBMWebView()
        webView.delegate = self
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        // MRAID.js not yet loaded -- expect nil
        
        let exp_nil = expectation(description:"expectationResizeProperties_nil")
        
        webView.MRAID_getResizeProperties(completionHandler: { properties in
            XCTAssertNil(properties)
            exp_nil.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
        // MRAID.js loaded while waiting for the previous expectation -- expect proper result now
        
        let exp = expectation(description:"expectationResizeProperties")
        
        webView.MRAID_getResizeProperties(completionHandler: { properties in
            XCTAssertNotNil(properties)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testMRAID_getResizePropertiesError() {
        let webView = PBMWebView()
        webView.delegate = self
        
        // Do not initialize MRAID
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: false)
        
        let exp = expectation(description:"expectationResizeProperties")
        
        webView.MRAID_getResizeProperties(completionHandler: { properties in
            XCTAssertNil(properties)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testMRAID_getExpandProperties() {
        let webView = PBMWebView()
        webView.delegate = self
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        // MRAID.js not yet loaded -- expect nil
        
        let exp_nil = expectation(description:"expectationResizeProperties")
        
        webView.MRAID_getExpandProperties(completionHandler: { properties in
            XCTAssertNil(properties)
            exp_nil.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
        // MRAID.js loaded while waiting for the previous expectation -- expect proper result now
        
        let exp = expectation(description:"expectationResizeProperties")
        
        webView.MRAID_getExpandProperties(completionHandler: { properties in
            XCTAssertNotNil(properties)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testMRAID_getExpandPropertiesError() {
        let webView = PBMWebView()
        webView.delegate = self
        
        // Do not initialize MRAID
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: false)
        
        let exp = expectation(description:"expectationResizeProperties")
        
        webView.MRAID_getExpandProperties(completionHandler: { properties in
            XCTAssertNil(properties)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testPrepareForMRAIDWithWindow() {
        runTestPrepareForMRAIDWithWindow(coppaValue: 0, coppaFlag: false)
        
        runTestPrepareForMRAIDWithWindow(coppaValue: 1, coppaFlag: true)
    }
    
    
    private func runTestPrepareForMRAIDWithWindow(coppaValue:Int, coppaFlag:Bool) {
        let frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        
        let targeting = Targeting.shared
        let webView = PBMWebView(frame: frame, creativeModel: nil, targeting: targeting)
        webView.delegate = self
        
        let window: UIWindow = {
            if #available(iOS 13.0, *) {
                return UIWindow()
            } else {
                return UIWindow(frame: frame) // prevent CGRectZero
            }
        }()
        window.addSubview(webView)
        window.isHidden = false
        
        targeting.coppa = NSNumber(value: coppaValue)
        
        readyToDisplayBlock = {
            webView.prepareForMRAID(withRootViewController: UIViewController())
        }
        
        expectationCommandExecuted = expectation(description: "expectationCommandExecuted")
        
        webView.jsEvaluatingCompletion = { jsCommand, jsRes, error in
            if jsCommand == PBMMRAIDJavascriptCommands.onExposureChange(PBMViewExposure(exposureFactor: 1, visibleRectangle: webView.bounds)) {
                self.expectationCommandExecuted?.fulfill()
            }
        }
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        waitForExpectations(timeout: 5)
        
        let expectedMraidEnv = [
            "version": "3.0",
            "sdk": "prebid-mobile-sdk",
            "sdkVersion": PBMFunctions.sdkVersion(),
            "appId": "com.apple.dt.xctest.tool",
            "ifa": ASIdentifierManager.shared().advertisingIdentifier.uuidString,
            "limitAdTracking": !ASIdentifierManager.shared().isAdvertisingTrackingEnabled,
            "coppa": coppaFlag,
        ] as? [String: NSObject]
        
        let mraidEnvExp = expectation(description: "MRAID_ENV received")
        
        webView.jsEvaluatingCompletion = nil
        webView.internalWebView.evaluateJavaScript("window.MRAID_ENV") { (response, error) in
            XCTAssertNil(error)
            XCTAssertEqual(response as? [String: NSObject], expectedMraidEnv)
            mraidEnvExp.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testMRAID_onViewableChangeTrue() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        let commandBlock = {
            webView.MRAID_onExposureChange(PBMViewExposure(exposureFactor: 1, visibleRectangle: webView.bounds)) // < --- Test target
        }
        
        let jsEvaluationBlock: ((String?, Any?, Error?) -> Bool) = { jsCommand, jsRes, error in
            return jsCommand == PBMMRAIDJavascriptCommands.onViewableChange(true)
        }
        
        checkJSEvaluating(webView: webView, commandBlock: commandBlock, evaluatingBlock: jsEvaluationBlock)
        waitForExpectations(timeout: 5)
    }
    
    func testMRAID_onExposureChangeTrue() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        let commandBlock = {
            webView.MRAID_onExposureChange(PBMViewExposure(exposureFactor: 1, visibleRectangle: webView.bounds)) // < --- Test target
        }
        
        let jsEvaluationBlock: ((String?, Any?, Error?) -> Bool) = { jsCommand, jsRes, error in
            return jsCommand == PBMMRAIDJavascriptCommands.onExposureChange(PBMViewExposure(exposureFactor: 1, visibleRectangle: webView.bounds))
        }
        
        checkJSEvaluating(webView: webView, commandBlock: commandBlock, evaluatingBlock: jsEvaluationBlock)
        waitForExpectations(timeout: 5)
    }
    
    func testMRAID_updatePlacementType() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        let commandBlock = {
            webView.MRAID_updatePlacementType(.inline) // < --- Test target
        }
        
        let jsEvaluationBlock: ((String?, Any?, Error?) -> Bool) = { jsCommand, jsRes, error in
            return jsCommand == PBMMRAIDJavascriptCommands.updatePlacementType(.inline)
        }
        
        checkJSEvaluating(webView: webView, commandBlock: commandBlock, evaluatingBlock: jsEvaluationBlock)
        waitForExpectations(timeout: 5)
    }
    
    func testAudioVolumeChange() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        let volumeKeyPath = "outputVolume"
        let volumeChange:[NSKeyValueChangeKey : Any] = [.kindKey: 1, .newKey: "0.5"]
        
        let commandBlock = {
            webView.observeValue(forKeyPath: volumeKeyPath, of: nil, change: volumeChange, context: nil) // < --- Test target
        }
        
        let jsEvaluationBlock: ((String?, Any?, Error?) -> Bool) = { jsCommand, jsRes, error in
            return jsCommand == PBMMRAIDJavascriptCommands.onAudioVolumeChange(50.0)
        }
        
        checkJSEvaluating(webView: webView, commandBlock: commandBlock, evaluatingBlock: jsEvaluationBlock)
        waitForExpectations(timeout: 7)
    }
    
    func testGetCurrentAppOrientation() {
        let frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        
        let webView = PBMWebView(frame: frame)
        webView.delegate = self
        
        let window: UIWindow = {
            if #available(iOS 13.0, *) {
                return UIWindow()
            } else {
                return UIWindow(frame: frame) // prevent CGRectZero
            }
        }()
        window.addSubview(webView)
        window.isHidden = false
        
        readyToDisplayBlock = {
            webView.prepareForMRAID(withRootViewController: UIViewController())
        }
        
        let orient = UIApplication.shared.statusBarOrientation;
        let orientationStr = orient.isPortrait ? "portrait" : "landscape"
        
        expectationCommandExecuted = expectation(description: "expectationCommandExecuted")
        
        webView.jsEvaluatingCompletion = { jsCommand, jsRes, error in
            if jsCommand ==  PBMMRAIDJavascriptCommands.updateCurrentAppOrientation(orientationStr,
                                                                                    locked: false){
                self.expectationCommandExecuted?.fulfill()
            }
        }
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: true)
        
        waitForExpectations(timeout: 7)
    }
    
    // MARK: - Other
    
    func testUIApplicationDidChangeStatusBarOrientationNotification() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        // Prepare
        
        expectationCommandExecuted = expectation(description: "expectationCommandExecuted")
        
        webView.jsEvaluatingCompletion = { jsCommand, jsRes, error in
            if jsCommand == PBMMRAIDJavascriptCommands.updateMaxSize(PBMFunctions.deviceMaxSize()) {
                self.expectationCommandExecuted?.fulfill();
            }
        }
        
        // Run
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: false)
        readyToDisplayBlock = {
            webView.onStatusBarOrientationChanged()
        }
        
        waitForExpectations(timeout: 7)
    }
    
    func testLayoutSubviews() {
        let webView = PBMWebView(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0))
        webView.delegate = self
        
        let commandBlock = {
            webView.layoutSubviews() // < --- Test target
        }
        
        let jsEvaluationBlock: ((String?, Any?, Error?) -> Bool) = { jsCommand, jsRes, error in
            let res = PBMMRAIDJavascriptCommands.updateCurrentPosition(webView.frame)
            return jsCommand == res
        }
        
        checkJSEvaluating(webView: webView, commandBlock: commandBlock, evaluatingBlock: jsEvaluationBlock)
        waitForExpectations(timeout: 5)
    }
    
    // MARK: - PBMWebViewDelegate
    
    func viewControllerForPresentingModals() -> UIViewController? {
        return UIViewController()
    }
    
    func webViewReady(toDisplay webView: PBMWebView) {
        expectationWebViewReadyToDisplay?.fulfill()
        readyToDisplayBlock?()
    }
    
    func webView(_ webView: PBMWebView, failedToLoadWithError error: Error) {
        expectationWebViewFailed?.fulfill()
    }
    
    func webView(_ webView: PBMWebView, receivedClickthroughLink url: URL) {
        expectationWebViewShouldOpenExternalLink?.fulfill()
    }
    
    func webView(_ webView: PBMWebView, receivedMRAIDLink url: URL) {
        expectationWebViewReceivedMRAIDLink?.fulfill()
    }
    
    func webView(_ webView: PBMWebView, receivedRewardedEventLink url: URL) {}
    
    // MARK: - Check methods
    
    private func checkJSEvaluating( webView: PBMWebView,
                                    commandBlock:@escaping (() -> Void),
                                    evaluatingBlock:@escaping ((String?, Any?, Error?) -> Bool),
                                    withMRAID: Bool = true) {
        // Prepare
        
        expectationCommandExecuted = expectation(description: "expectationCommandExecuted")
        
        webView.jsEvaluatingCompletion = { jsCommand, jsRes, error in
            if evaluatingBlock(jsCommand, jsRes, error) {
                self.expectationCommandExecuted?.fulfill()
            }
        }
        
        // Run
        
        webView.loadHTML(testHTML, baseURL:nil, injectMraidJs: withMRAID)
        readyToDisplayBlock = commandBlock
    }
}
