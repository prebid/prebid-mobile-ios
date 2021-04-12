//
//  OXMClickthroughBrowserViewTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

class OXMClickthroughBrowserViewTest: XCTestCase, ClickthroughBrowserViewDelegate {

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
        
        self.clickThroughBrowserView = OXMFunctions.bundleForSDK().loadNibNamed("ClickthroughBrowserView", owner: nil, options: nil)!.first as? ClickthroughBrowserView
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

        
        for strScheme in OXMConstants.urlSchemesForAppStoreAndITunes {
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
    
    // MARK: - OXMClickthroughBrowserViewDelegate
    
    func clickThroughBrowserViewCloseButtonTapped() {
        expectationBrowserClosePressed?.fulfill()
    }
    
    func clickThroughBrowserViewWillLeaveApp() {
        expectationBrowserDidLeaveApp?.fulfill()
    }
    
}
