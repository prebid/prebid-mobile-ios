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

class PBMHTMLCreativeTest_MRAIDOpen: PBMHTMLCreativeTest_Base {
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testNonClickThroughBrowser() {
        
        let clickHandlerExpectation = self.expectation(description: "Should have triggered click")
        self.creativeWasClickedHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            clickHandlerExpectation.fulfill()
        }
        
        let clickTrackingExpectation = self.expectation(description: "Should have triggered click tracking url")
        self.mockEventTracker.mock_trackEvent = { (event) in
            PBMAssertEq(event, PBMTrackingEvent.click)
            clickTrackingExpectation.fulfill()
        }
        
        //Why is it being set up twice?
        self.htmlCreative.setupView()
        
        // NOTE: can't test other links on simulator: @"tel", @"itms", @"itms-apps"
        // They will be processed with @nonSimulatorSchemes
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open/sms%3A%2F%2F12123804700"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }
    
    func testSimulator() {
        
        self.continueAfterFailure = true
        
        let clickHandlerExpectation = self.expectation(description: "Should not have triggered click")
        clickHandlerExpectation.isInverted = true
        self.creativeWasClickedHandler = { (creative) in
            XCTFail()
        }
        
        let clickTrackingExpectation = self.expectation(description: "Should not have triggered click tracking url")
        clickTrackingExpectation.isInverted = true
        self.mockEventTracker.mock_trackEvent = { (event) in
            XCTFail()
        }
        
        self.htmlCreative.setupView()
        
        logToFile = .init()
        
        let unescapedTestURLs = ["tel:0000", "itms:test", "itms-apps:test"]
        
        let testURLs:[String] = unescapedTestURLs.map({
            guard let escapedTestURL:String = $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                XCTFail("Could not encode testURL")
                return ""
            }
            
            return escapedTestURL
        })
        
        for testURL in testURLs {
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open/\(testURL)"))
        }
        
        let log = Log.getLogFileAsString() ?? ""
        
        unescapedTestURLs.forEach {
            XCTAssert(log.contains("Attempting to MRAID.open() url \($0)"), "Expected log to contain \($0)")
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }
    
    func testInvalidView() {
        let clickHandlerExpectation = self.expectation(description: "Should not have triggered click")
        clickHandlerExpectation.isInverted = true
        self.creativeWasClickedHandler = { _ in
            clickHandlerExpectation.fulfill()
        }
        
        self.htmlCreative.setupView()
        self.htmlCreative.view = UIView()
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open/http%3A%2F%2Fexample.com"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }
    
    func testInvalidCommand() {
        let clickHandlerExpectation = self.expectation(description: "Should not have triggered click")
        clickHandlerExpectation.isInverted = true
        self.creativeWasClickedHandler = { _ in
            clickHandlerExpectation.fulfill()
        }
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.setupView()
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open"))
        }, checkLogFor:["No arguments to MRAID.open()"])
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }
    
    func testInvalidURL() {
        let clickHandlerExpectation = self.expectation(description: "Should not have triggered click")
        clickHandlerExpectation.isInverted = true
        self.creativeWasClickedHandler = { _ in
            clickHandlerExpectation.fulfill()
        }
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.setupView()
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open/%F0%9F%92%A9"))
        }, checkLogFor:["Could not create URL from string: 💩"])
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }
    
    func testInvalidScheme() {
        let clickHandlerExpectation = self.expectation(description: "Should not have triggered click")
        clickHandlerExpectation.isInverted = true
        self.creativeWasClickedHandler = { _ in
            clickHandlerExpectation.fulfill()
        }
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.setupView()
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open/invalidscheme"))
        }, checkLogFor:["Could not determine URL scheme from url: invalidscheme"])
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.htmlCreative.clickthroughVisible)
    }
    
    func testOpenSucceeds() {
        let clickHandlerExpectation = self.expectation(description: "Should have triggered click")
        self.creativeWasClickedHandler = { (creative) in
            PBMAssertEq(creative, self.htmlCreative)
            clickHandlerExpectation.fulfill()
        }
        
        let clickTrackingExpectation = self.expectation(description: "Should have triggered click tracking url")
        self.mockEventTracker.mock_trackEvent = { (event) in
            PBMAssertEq(event, PBMTrackingEvent.click)
            clickTrackingExpectation.fulfill()
        }
        
        self.htmlCreative.setupView()
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("open/http%3A%2F%2Fexample.com"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssert(self.htmlCreative.clickthroughVisible)
    }
}
