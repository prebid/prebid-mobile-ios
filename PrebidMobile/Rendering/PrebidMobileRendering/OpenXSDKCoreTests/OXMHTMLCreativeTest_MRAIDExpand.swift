//
//  OXMHTMLCreativeTest_MRAIDExpand.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXMHTMLCreativeTest_MRAIDExpand: OXMHTMLCreativeTest_Base {

    override func setUp() {
        super.setUp()
        htmlCreative.setupView()
        mockWebView.mraidState = .default
    }
    
    override func tearDown() {
        mockEventTracker.mock_trackEvent = nil
        super.tearDown()
    }

    func testMissingViewController() {
        expandPropertiesExpectation()

        htmlCreative.viewControllerForPresentingModals = nil

        UtilitiesForTesting.executeTestClosure({
            htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("expand"))
        }, checkLogFor: ["viewControllerForPresentingModals is nil"])

        waitForExpectations(timeout: 1)
    }

    func testInvalidView() {
        expandPropertiesExpectation()

        // Set to a non-webview view
        htmlCreative.view = UIView()

        UtilitiesForTesting.executeTestClosure({
            htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("expand"))
        }, checkLogFor:["Could not cast creative view to OXMWebView"])

        waitForExpectations(timeout: 1)
    }

    func testInvalidResizeState() {
        expandPropertiesExpectation()

        // Set to a state that we shouldn't be able to expand from.
        mockWebView.mraidState = .hidden

        UtilitiesForTesting.executeTestClosure({
            let url = UtilitiesForTesting.getMRAIDURL("expand")
            htmlCreative.webView(mockWebView, receivedMRAIDLink:url)
        }, checkLogFor:["MRAID cannot expand from state"])


        waitForExpectations(timeout: 1)
    }

    func testNoExpandProperties() {

        // Negative tests
        creativeExpandExpectation(shouldFulfill: false)
        clickTrackingExpectation(shouldFulfill: false)
        displayWebViewExpectation()

        mockWebView.mock_MRAID_getExpandProperties = { $0(nil) }
        mraidErrorExpectation(shouldFulfill: true, message: "Unable to get Expand Properties", action: .expand)

        htmlCreative.webView(mockWebView, receivedMRAIDLink: UtilitiesForTesting.getMRAIDURL("expand"))

        waitForExpectations(timeout: 1)
    }

    func testExpandURLInvalidURL() {

        mockWebView.mock_MRAID_getExpandProperties = { $0(MRAIDExpandProperties()) }

        // Negative tests
        creativeExpandExpectation(shouldFulfill: false)
        clickTrackingExpectation(shouldFulfill: false)
        displayWebViewExpectation()

        UtilitiesForTesting.executeTestClosure({
            htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("expand/%F0%9F%92%A9"))
        }, checkLogFor:["Could not create expand url to: 💩"])

        waitForExpectations(timeout: 1)
    }

    func testExpandURLSuccess() {

        mockWebView.mock_MRAID_getExpandProperties = { $0(MRAIDExpandProperties()) }

        creativeExpandExpectation(shouldFulfill: true, expectedCreative: htmlCreative)
        clickTrackingExpectation(shouldFulfill: true, expectedEvent: .click)
        mraidStateChangeExpectation(shouldFulfill: true, exptectedState: .expanded)

        let modalManagerExpectation = expectation(description: "Should display in new webview")
        mockModalManager.mock_pushModalClosure = { [weak self] (state, fromRootViewController, animated, shouldReplace, completionHandler) in
            XCTAssertNotEqual(state.view, self?.mockWebView)
            XCTAssert(shouldReplace == false)
            XCTAssert(completionHandler != nil)
            modalManagerExpectation.fulfill()
            completionHandler?()
        }

        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("expand/notreallyaurl"))
        
        //A new state must be set *ONLY* after the exposureChange event
        let exposure = OXMViewExposure(exposureFactor: 1,
                                       visibleRectangle: CGRect(),
                                    occlusionRectangles: nil)
        mockWebView.exposureDelegate?.webView(mockWebView, exposureChange:exposure)


        waitForExpectations(timeout: 1)
    }
    
    func testExpandWithoutExposureChange() {

        mockWebView.mock_MRAID_getExpandProperties = { $0(MRAIDExpandProperties()) }

        creativeExpandExpectation(shouldFulfill: true, expectedCreative: htmlCreative)
        clickTrackingExpectation(shouldFulfill: true, expectedEvent: .click)
        
        //A new state Expanded must be set *ONLY* after the exposureChange event
        //The current state must not be changed
        mraidStateChangeExpectation(shouldFulfill: false, exptectedState: .expanded)

        let modalManagerExpectation = expectation(description: "Should display in new webview")
        mockModalManager.mock_pushModalClosure = { [weak self] (state, fromRootViewController, animated, shouldReplace, completionHandler) in
            XCTAssertNotEqual(state.view, self?.mockWebView)
            XCTAssert(shouldReplace == false)
            XCTAssert(completionHandler != nil)
            modalManagerExpectation.fulfill()
            completionHandler?()
        }

        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("expand/notreallyaurl"))

        waitForExpectations(timeout: 1)
    }


    func testNoExpandSuccess() {

        mockWebView.mock_MRAID_getExpandProperties = { $0(MRAIDExpandProperties()) }

        creativeExpandExpectation(shouldFulfill: true, expectedCreative: htmlCreative)
        clickTrackingExpectation(shouldFulfill: true, expectedEvent: .click)
        mraidStateChangeExpectation(shouldFulfill: true, exptectedState: .expanded)

        let modalManagerExpectation = expectation(description: "Should display in existing webview")
        mockModalManager.mock_pushModalClosure = { [weak self] (state, fromRootViewController, animated, shouldReplace, completionHandler) in
            OXMAssertEq(state.view, self?.mockWebView)
            XCTAssertFalse(shouldReplace)
            XCTAssertNotNil(completionHandler)
            modalManagerExpectation.fulfill()
            completionHandler?()
        }

        XCTAssertFalse(htmlCreative.isOpened)
        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("expand"))
        
        let exposure = OXMViewExposure(exposureFactor: 1,
                                       visibleRectangle: CGRect(),
                                    occlusionRectangles: nil)
        mockWebView.exposureDelegate?.webView(mockWebView, exposureChange:exposure)

        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(htmlCreative.isOpened)
    }

    // MARK: - Utilities
    func expandPropertiesExpectation() {
        let exp = expectation(description: "Should not get expand properties")
        exp.isInverted = true
        mockWebView.mock_MRAID_getExpandProperties = { _ in
            exp.fulfill()
        }
    }

    /**
     Setup an expectation and associated, mocked `CreativeViewDelegate` to fulfill that expectation.

     - parameters:
         - shouldFulfill: Whether or not the expecation is expected to fulfill
         - expectedCreative: If `shouldFulfill`, the creative to compare
     */
    func creativeExpandExpectation(shouldFulfill: Bool, expectedCreative: OXMAbstractCreative? = nil) {
        let exp = expectation(description: "Should \(shouldFulfill ? "" : "not ")call expand handler")
        exp.isInverted = !shouldFulfill
        creativeMraidDidExpandHandler = { [weak expectedCreative] (actualCreative) in
            if shouldFulfill {
                OXMAssertEq(actualCreative, expectedCreative)
            }
            exp.fulfill()
        }
    }

    /**
     Setup an expectation and associated, mocked `OXMCreativeModel` to fulfill that expectation.

     - parameters:
         - shouldFulfill: Whether or not the expecation is expected to fulfill
         - expectedEvent: If `shouldFulfill`, the tracking event to compare
     */
    func clickTrackingExpectation(shouldFulfill: Bool, expectedEvent: OXMTrackingEvent? = nil) {
        let exp = expectation(description: "Should \(shouldFulfill ? "" : "not ")trigger a click event")
        exp.isInverted = !shouldFulfill
        mockEventTracker.mock_trackEvent = { (actualEvent) in
            if shouldFulfill {
                OXMAssertEq(actualEvent, expectedEvent)
            }
            exp.fulfill()
        }
    }

    /**
     Setup an expectation and associated, mocked `ModalManager` to fulfill that expectation.

     The expectation is expected not to fulfill
     */
    func displayWebViewExpectation() {
        let modalManagerExpectation = expectation(description: "Should not display webview")
        modalManagerExpectation.isInverted = true
        mockModalManager.mock_pushModalClosure = { _, _, _, _, _ in
            modalManagerExpectation.fulfill()
        }
    }

    /**
     Setup an expectation and associated, mocked `OXMWebView` to fulfill that expectation.

     - parameters:
        - shouldFulfill: Whether or not the expecation is expected to fulfill
        - expectedState: The MRAID state to compare
     */
    func mraidStateChangeExpectation(shouldFulfill: Bool, exptectedState: OXMMRAIDState) {
        let exp = expectation(description: "Should change MRAID state to '\(exptectedState.rawValue)'")
        exp.isInverted = !shouldFulfill
        mockWebView.mock_changeToMRAIDState = { (actualState) in
            OXMAssertEq(actualState, exptectedState)
            exp.fulfill()
        }
    }

}
