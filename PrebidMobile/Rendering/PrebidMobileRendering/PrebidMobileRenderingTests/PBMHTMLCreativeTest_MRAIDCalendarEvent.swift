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

@testable import PrebidMobileRendering

class PBMHTMLCreativeTest_MRAIDCalendarEvent: PBMHTMLCreativeTest_Base {

    func testWithInvalidView() {
        self.createCalendarEventExpectation(shouldFulfill: false)
        
        //Use an invalid view
        self.htmlCreative.view = UIView()
        
        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("createCalendarevent/event"))
        }, checkLogFor:["Could not cast creative view to PBMWebView"])

        self.waitForExpectations(timeout: self.timeout)
    }

    func testWithInvalidCommand() {
        self.mraidErrorExpectation(shouldFulfill: true, message: "No event string provided", action: .createCalendarEvent)
        self.createCalendarEventExpectation(shouldFulfill: false)

        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("createCalendarevent"))

        self.waitForExpectations(timeout: self.timeout)
    }

    func testWhenCreateCalendarFails() {
        let expectedErrorMessage = "an error message"
        self.mraidErrorExpectation(shouldFulfill: true, message: expectedErrorMessage, action: .createCalendarEvent)
        self.createCalendarEventExpectation(shouldFulfill: true, shouldSucceed: false, errorMessage: expectedErrorMessage)
        
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

        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("createCalendarevent/event"))

        self.waitForExpectations(timeout: self.timeout)
    }

    func testWhenCreateCalendarSucceeds() {
        self.mraidErrorExpectation(shouldFulfill: false)
        self.createCalendarEventExpectation(shouldFulfill: true, shouldSucceed: true)
        
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

        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("createCalendarevent/event"))

        self.waitForExpectations(timeout: self.timeout)
    }

    /**
     Setup an expectation and associated, mocked `PBMDeviceManager` to fulfill that expectation.

     - parameters:
         - shouldFulfill: Whether or not the expecation is expected to fulfill
         - shouldSucceed: If `shouldFulfill`, whether or not calendar creation should succed
         - errorMessage: If `shouldFulfill`, the error message for calendar creation
     */
    func createCalendarEventExpectation(shouldFulfill: Bool, shouldSucceed: Bool? = nil, errorMessage: String = "") {
        let exp = self.expectation(description: "Should \(shouldFulfill ? "" : "not ")attempt to add calendar event")
        exp.isInverted = !shouldFulfill
        MockPBMDeviceAccessManager.mock_createCalendarEventFromString_completion = { (_, completion) in
            if shouldFulfill, let success = shouldSucceed {
                completion(success, errorMessage)
            }
            exp.fulfill()
        }
    }

}
