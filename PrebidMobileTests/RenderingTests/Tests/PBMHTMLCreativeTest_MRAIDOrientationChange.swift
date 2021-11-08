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

class PBMHTMLCreativeTest_MRAIDOrientationChange: PBMHTMLCreativeTest_Base {
    
    func testInvalidCommand() {
        let forceOrientationExpectation = self.expectation(description: "Should not force orientation change")
        forceOrientationExpectation.isInverted = true
        self.mockModalManager.mock_forceOrientation = { _ in
            forceOrientationExpectation.fulfill()
        }
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("onOrientationPropertiesChanged"))
        }, checkLogFor: ["onOrientationPropertiesChanged - No JSON string"])
        
        
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testInvalidJSON() {
        let forceOrientationExpectation = self.expectation(description: "Should not force orientation change")
        forceOrientationExpectation.isInverted = true
        self.mockModalManager.mock_forceOrientation = { _ in
            forceOrientationExpectation.fulfill()
        }
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("onOrientationPropertiesChanged/%7Bfoo"))
        }, checkLogFor:["onOrientationPropertiesChanged - Unable to parse JSON string:"])
        
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testForcePortrait() {
        let forceOrientationExpectation = self.expectation(description: "Should force orientation change")
        self.mockModalManager.mock_forceOrientation = { (orientation) in
            PBMAssertEq(orientation, UIInterfaceOrientation.portrait)
            forceOrientationExpectation.fulfill()
        }
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("onOrientationPropertiesChanged/%7B%22forceOrientation%22%3A%22portrait%22%7D"))
        
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testForceLandscape() {
        let forceOrientationExpectation = self.expectation(description: "Should force orientation change")
        self.mockModalManager.mock_forceOrientation = { (orientation) in
            PBMAssertEq(orientation, UIInterfaceOrientation.landscapeLeft)
            forceOrientationExpectation.fulfill()
        }
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("onOrientationPropertiesChanged/%7B%22forceOrientation%22%3A%22landscape%22%7D"))
        
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
    
    func testNoForceOrientation() {
        let forceOrientationExpectation = self.expectation(description: "Should not force orientation change")
        forceOrientationExpectation.isInverted = true
        self.mockModalManager.mock_forceOrientation = { _ in
            forceOrientationExpectation.fulfill()
        }
        
        let log = UtilitiesForTesting.executeTestClosure({
            let url = UtilitiesForTesting.getMRAIDURL("onOrientationPropertiesChanged/%7B%22key%22%3A%22value%22%7D")
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:url)
        })
        XCTAssert(!log.contains("onOrientationPropertiesChanged - No JSON string"))
        XCTAssert(!log.contains("onOrientationPropertiesChanged - Unable to parse JSON string:"))
        
        self.waitForExpectations(timeout: self.timeout, handler: nil)
    }
}
