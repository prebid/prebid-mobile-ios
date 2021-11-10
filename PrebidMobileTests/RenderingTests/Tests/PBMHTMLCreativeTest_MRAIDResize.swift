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
@testable import PrebidMobile

class PBMHTMLCreativeTest_MRAIDResize: PBMHTMLCreativeTest_Base {

    let validResizeProperties: MRAIDResizeProperties = {
        let rsp = MRAIDResizeProperties()
        rsp.width = 320
        rsp.height = 50
        return rsp
    }()


    //TODO: Evaluate whether this test still has merit
    func testMissingViewController() {
        self.mockWebView.mraidState = .default
        self.mockWebViewResize(MRAIDResizeProperties())
        
        self.htmlCreative.viewControllerForPresentingModals = nil
        self.htmlCreative.mraidController?.viewControllerForPresentingModals = nil
        
        let expectation = self.expectation(description: "Should not push Modal")
        expectation.isInverted = true
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectation.fulfill()
        }

        self.htmlCreative.setupView()

        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        }, checkLogFor:["self.viewControllerForPresentingModals is nil for mraid command"])

        self.waitForExpectations(timeout: 1)
    }

    func testInvalidView() {
        self.mockWebView.mraidState = .default
        self.mockWebViewResize(MRAIDResizeProperties())

        let expectation = self.expectation(description: "Should not push Modal")
        expectation.isInverted = true
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectation.fulfill()
        }

        self.htmlCreative.setupView()
        let viewController = UIViewController()
        viewController.view = UIView()
        self.htmlCreative.view = viewController.view

        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        }, checkLogFor:["Could not cast creative view to PBMWebView"])

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testInValidResizeState() {

        self.mockWebView.mraidState = .hidden
        self.mockWebViewResize(MRAIDResizeProperties())

        let expectation = self.expectation(description: "Should not push Modal")
        expectation.isInverted = true
        self.mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            expectation.fulfill()
        }

        self.htmlCreative.setupView()

        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        }, checkLogFor:["MRAID cannot resize from state: hidden"])

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testNoResizeProperties() {

        self.mockWebView.mraidState = .default
        self.mockWebViewResize(nil)

        self.mraidErrorExpectation(shouldFulfill: true, message: "Was unable to get resizeProperties", action: .resize)
        self.mraidStateChangeExpecation(shouldFulfill: false)

        self.htmlCreative.setupView()
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        
        let exposure = PBMViewExposure(exposureFactor: 1,
                                       visibleRectangle: CGRect(),
                                    occlusionRectangles: nil)
        self.mockWebView.exposureDelegate?.webView(self.mockWebView, exposureChange:exposure)

        self.waitForExpectations(timeout: 1)
    }

    func testInvalidFrameSize() {

        self.mockWebView.mraidState = .default
        self.mockWebViewResize(MRAIDResizeProperties())

        self.mraidErrorExpectation(shouldFulfill: true, message: "MRAID ad attempted to resize to an invalid size", action: .resize)
        self.mraidStateChangeExpecation(shouldFulfill: false)

        self.htmlCreative.setupView()

        UtilitiesForTesting.executeTestClosure({
            self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        }, checkLogFor:["MRAID ad attempted to resize to an invalid size"])
        
        let exposure = PBMViewExposure(exposureFactor: 1,
                                       visibleRectangle: CGRect(),
                                    occlusionRectangles: nil)
        self.mockWebView.exposureDelegate?.webView(self.mockWebView, exposureChange:exposure)

        self.waitForExpectations(timeout: 1)
    }

    func testSuccess() {

        self.mockWebView.mraidState = .default
        self.mockWebViewResize(self.validResizeProperties)

        self.mraidStateChangeExpecation(shouldFulfill: true, expectedState: .resized)

        let expectation = self.expectation(description: "Should push Modal")
        self.mockModalManager.mock_pushModalClosure = { (_, _, _, _, completionHandler) in
            expectation.fulfill()
            completionHandler?()
        }

        self.htmlCreative.setupView()

        let url = UtilitiesForTesting.getMRAIDURL("resize")
        
        XCTAssertFalse(self.htmlCreative.isOpened)
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:url)
        
        //A new state must be set *ONLY* after the exposureChange event
        let exposure = PBMViewExposure(exposureFactor: 1,
                                       visibleRectangle: CGRect(),
                                    occlusionRectangles: nil)
        self.mockWebView.exposureDelegate?.webView(self.mockWebView, exposureChange:exposure)

        self.waitForExpectations(timeout: 1)
        
        XCTAssertTrue(self.htmlCreative.isOpened)
    }
    
    func testResizeWithoutExposure() {

        self.mockWebView.mraidState = .default
        self.mockWebViewResize(self.validResizeProperties)

        //A new state Resized must be set *ONLY* after the exposureChange event
        //The current state must not be changed
        self.mraidStateChangeExpecation(shouldFulfill: false, expectedState: .resized)

        let expectation = self.expectation(description: "Should push Modal")
        self.mockModalManager.mock_pushModalClosure = { (_, _, _, _, completionHandler) in
            expectation.fulfill()
            completionHandler?()
        }

        self.htmlCreative.setupView()

        let url = UtilitiesForTesting.getMRAIDURL("resize")
        
        XCTAssertFalse(self.htmlCreative.isOpened)
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:url)

        self.waitForExpectations(timeout: 1)
        
        XCTAssertTrue(self.htmlCreative.isOpened)
    }


    func testSuccessReplace() {

        self.mockWebView.mraidState = .resized
        self.mockWebViewResize(self.validResizeProperties)

        self.mraidStateChangeExpecation(shouldFulfill: true, expectedState: .resized)

        let expectation = self.expectation(description: "Should push Modal")
        self.mockModalManager.mock_pushModalClosure = { (_, _, _, _, completionHandler) in
            expectation.fulfill()
            completionHandler?()
        }

        self.htmlCreative.setupView()
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        
        //A new state must be set *ONLY* after the exposureChange event
        let exposure = PBMViewExposure(exposureFactor: 1,
                                       visibleRectangle: CGRect(),
                                    occlusionRectangles: nil)
        self.mockWebView.exposureDelegate?.webView(self.mockWebView, exposureChange:exposure)

        self.waitForExpectations(timeout: 1)
    }

    // MARK: - Utilities
    func mockWebViewResize(_ resizeProperties: MRAIDResizeProperties?) {
        self.mockWebView.mock_MRAID_getResizeProperties = { $0(resizeProperties) }
    }


    /**
     Setup an expectation and associated, mocked `PBMWebView` to fulfill that expectation.

     - parameters:
        - shouldFulfill: Whether or not the expecation is expected to fulfill
        - expectedState: If `shouldFulfill`, the `PBMMRAIDState` expected to change to
    */
    func mraidStateChangeExpecation(shouldFulfill: Bool, expectedState: PBMMRAIDState = .default) {
        let exp = self.expectation(description: "Should \(shouldFulfill ? "" : "not ")cause an MRAID state change")
        exp.isInverted = !shouldFulfill
        self.mockWebView.mock_changeToMRAIDState = { (actualState) in
            if shouldFulfill {
                PBMAssertEq(actualState, expectedState)
            }
            exp.fulfill()
        }
    }

}
