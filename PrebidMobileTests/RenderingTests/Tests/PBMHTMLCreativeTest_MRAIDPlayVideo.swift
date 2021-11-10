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

class PBMHTMLCreativeTest_MRAIDPlayVideo: PBMHTMLCreativeTest_Base {
    
    func testInvalidCommand() {
        
        //Expect that no modal will be pushed
        let expectationModalPushed = self.expectation(description: "No modal should be pushed")
        expectationModalPushed.isInverted = true
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectationModalPushed.fulfill()
        }
        
        let viewController = UIViewController()
        viewController.view = self.mockWebView
        
        self.htmlCreative.setupView()
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("playVideo"))
        }, checkLogFor:["Insufficient arguments for MRAIDAction.playVideo"])
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidURL() {
        //Expect that no modal will be pushed
        let expectationModalPushed = self.expectation(description: "No modal should be pushed")
        expectationModalPushed.isInverted = true
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectationModalPushed.fulfill()
        }
        
        let viewController = UIViewController()
        viewController.view = self.mockWebView
        
        self.htmlCreative.setupView()
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("playVideo/%F0%9F%92%A9"))
        }, checkLogFor:["MRAID attempted to load an invalid URL: 💩"])
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    //TODO: Evaluate whether this test still has merit
    func testMissingViewController() {
        //Expect that no modal will be pushed
        let expectationModalPushed = self.expectation(description: "No modal should be pushed")
        expectationModalPushed.isInverted = true
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectationModalPushed.fulfill()
        }
        
        self.htmlCreative.mraidController?.viewControllerForPresentingModals = nil
        self.htmlCreative.viewControllerForPresentingModals = nil
        self.htmlCreative.setupView()
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("playVideo/amazingVideo"))
        }, checkLogFor:["self.viewControllerForPresentingModals is nil"])
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSuccess() {
        
        let strVideoURL = "http://get_video/small.mp4"
        
        MockServer.shared.reset()
        let rule = MockServerRule(urlNeedle: strVideoURL, mimeType:  MockServerMimeType.MP4.rawValue, connectionID: UUID(), fileName: "small.mp4")
        MockServer.shared.resetRules([rule])
        
        let expectationModalPushed = self.expectation(description: "Modal should be pushed")
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectationModalPushed.fulfill()
        }
        
        let viewController = UIViewController()
        viewController.view = self.mockWebView
        
        self.htmlCreative.setupView()
        
        guard let escapedStrVideoURL = strVideoURL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            XCTFail("Could not encode strVideoURL")
            return
        }
        let url = UtilitiesForTesting.getMRAIDURL("playVideo/\(escapedStrVideoURL)")
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:url)
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
}
