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

class PBMHTMLCreativeTest_MRAIDStorePicture: PBMHTMLCreativeTest_Base {
    
    override func setUp() {
        super.setUp()
        self.htmlCreative.setupView()
    }
    
    func testWithInvalidView() {
        self.storePhotoFailExpectation()
        self.htmlCreative.view = UIView()
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("storepicture/picture"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWithInvalidCommand() {
        self.mraidErrorExpectation(shouldFulfill: true, message: "Ad wanted to store a picture with an invalid URL", action: .storePicture)
        self.storePhotoFailExpectation()
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("storepicture"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testWhenSavePhotoFails() {
        let expectedErrorMessage = "an error message"
        self.mraidErrorExpectation(shouldFulfill: true, message: expectedErrorMessage, action: .storePicture)
        MockPBMDeviceAccessManager.mock_savePhotoWithUrlToAsset_completion = { (_, completion) in
            completion(false, expectedErrorMessage)
        }
        
        let serverConnection = PBMServerConnection(userAgentService: MockUserAgentService())
        serverConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        let mockMRAIDController = PBMMRAIDController(creative:self.htmlCreative,
                                                     viewControllerForPresenting:self.mockViewController,
                                                     webView:self.mockWebView,
                                                     creativeViewDelegate:self,
                                                     downloadBlock:createLoader(connection: serverConnection),
                                                     deviceAccessManagerClass: MockPBMDeviceAccessManager.self,
                                                     sdkConfiguration: PrebidRenderingConfig.mock)
        
        self.htmlCreative.mraidController = mockMRAIDController
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("storepicture/picture"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSavePhotoSucceeds() {
        let mraidErrorExpectation = self.expectation(description: "Should not call webview with an MRAID error")
        mraidErrorExpectation.isInverted = true
        self.mockWebView.mock_MRAID_error = { _, _ in
            mraidErrorExpectation.fulfill()
        }
        
        MockPBMDeviceAccessManager.mock_savePhotoWithUrlToAsset_completion = { (url, completion) in
            completion(true, "an error message")
        }
        
        let serverConnection = PBMServerConnection(userAgentService: MockUserAgentService())
        serverConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        let mockMRAIDController = PBMMRAIDController(creative:self.htmlCreative,
                                                     viewControllerForPresenting:self.mockViewController,
                                                     webView:self.mockWebView,
                                                     creativeViewDelegate:self,
                                                     downloadBlock:createLoader(connection: serverConnection),
                                                     deviceAccessManagerClass: MockPBMDeviceAccessManager.self,
                                                     sdkConfiguration: PrebidRenderingConfig.mock)
        
        self.htmlCreative.mraidController = mockMRAIDController
        
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("storepicture/picture"))
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Utilities
    func storePhotoFailExpectation() {
        let storePhotoExpectation = self.expectation(description: "Should not attempt to store picture")
        storePhotoExpectation.isInverted = true
        MockPBMDeviceAccessManager.mock_savePhotoWithUrlToAsset_completion = { _, _ in
            storePhotoExpectation.fulfill()
        }
    }
    
}
