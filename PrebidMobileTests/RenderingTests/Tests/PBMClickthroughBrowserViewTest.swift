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

import XCTest

class PBMClickthroughBrowserViewTest: XCTestCase, ClickthroughBrowserViewDelegate {
    
    // MARK: - Properties
    
    var clickThroughBrowserView : ClickthroughBrowserView!
    let testURL = URL(string: "openx.com")!
    
    var expectationBrowserClosePressed: XCTestExpectation?
    var expectationBrowserDidLeaveApp: XCTestExpectation?
    var expectationLoad1: XCTestExpectation?
    var expectationLoad2: XCTestExpectation?
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        self.clickThroughBrowserView = PBMFunctions.bundleForSDK().loadNibNamed("ClickthroughBrowserView", owner: nil, options: nil)!.first as? ClickthroughBrowserView
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.clickThroughBrowserView = nil
    }
    
    // MARK: - Test Buttons
    
    func testExternalBrowserButtonPressed() {
        self.clickThroughBrowserView.clickThroughBrowserViewDelegate = self
        
        expectationBrowserDidLeaveApp = expectation(description:"expectationBrowserDidLeaveApp")
        
        self.clickThroughBrowserView.openURL(testURL)
        self.clickThroughBrowserView.externalBrowserButtonPressed()
        
        waitForExpectations(timeout: 1)
    }
    
    func testExternalBrowserButtonPressedWithoutURL() {
        self.clickThroughBrowserView.clickThroughBrowserViewDelegate = self
        
        expectationBrowserDidLeaveApp = expectation(description:"expectationBrowserDidLeaveApp")
        expectationBrowserDidLeaveApp?.isInverted = true
        
        self.clickThroughBrowserView.externalBrowserButtonPressed()
        
        waitForExpectations(timeout: 1)
    }
    
    func testCloseButtonPressed() {
        
        self.clickThroughBrowserView.clickThroughBrowserViewDelegate = self
        
        expectationBrowserClosePressed = expectation(description:"expectationBrowserClosePressed");
        
        self.clickThroughBrowserView.closeButtonPressed()
        
        waitForExpectations(timeout: 1)
    }
    
    func testDecidePolicyForNavigationActionWithNoURL() {
        
        self.clickThroughBrowserView.navigationHandler.webView(self.clickThroughBrowserView.webView!, decidePolicyFor: WKNavigationAction(), decisionHandler: { policy in
            XCTAssertEqual(policy, .cancel)
        })
    }
    
    func testDecidePolicyForNavigationAction() {
        
        let navigationAction = MockWKNavigationAction()
        navigationAction.mockedRequest = URLRequest(url: testURL)
        self.clickThroughBrowserView.navigationHandler.webView(self.clickThroughBrowserView.webView!, decidePolicyFor: navigationAction, decisionHandler: { policy in
            XCTAssertEqual(policy, .allow)
        })
    }
    
    func testDecidePolicyForNavigationActionWithDifferentSchema() {
        self.clickThroughBrowserView.clickThroughBrowserViewDelegate = self
        
        
        for strScheme in PBMConstants.urlSchemesForAppStoreAndITunes {
            expectationBrowserDidLeaveApp = expectation(description:"expectationBrowserDidLeaveApp")
            expectationBrowserClosePressed = expectation(description:"expectationBrowserClosePressed");
            
            let navigationAction = MockWKNavigationAction()
            
            navigationAction.mockedRequest = URLRequest(url: URL(string: "\(strScheme)://test")!)
            self.clickThroughBrowserView.navigationHandler.webView(self.clickThroughBrowserView.webView!, decidePolicyFor: navigationAction, decisionHandler: { policy in
                XCTAssertEqual(policy, .cancel)
            })
            
            waitForExpectations(timeout: 3)
        }
    }
    
    // MARK: - PBMClickthroughBrowserViewDelegate
    
    func clickThroughBrowserViewCloseButtonTapped() {
        expectationBrowserClosePressed?.fulfill()
    }
    
    func clickThroughBrowserViewWillLeaveApp() {
        expectationBrowserDidLeaveApp?.fulfill()
    }
    
}
