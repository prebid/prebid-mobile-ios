//
//  OXMHTMLCreativeTest_MRAID.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK


// DESCRIPTION
// We can't test all flow for MRAID.close() because of iOS viewController on pop.
// Using it from unit tests does not allow to call modalManagerDidFinishPop from the completion of dismissViewControllerAnimated. So this test case is divided into two parts:
// - tests the MRAID.close() leads to popModal (withMocked modal manager)
// - tests that modalManagerDidFinishPop leads to creativeReadyToReimplant and default MRAID state (with non mocked modal manager)
class OXMHTMLCreativeTest_MRAIDClose: XCTestCase, OXMCreativeViewDelegate {
  
    var creativeReadyToReimplantExpectation: XCTestExpectation!

    func testCloseReadyToReimplant() {
        
        // SETUP ENVIRONMENT
        
        let mockWebView = MockOXMWebView();
        mockWebView.isViewable = true

        let adConfiguration = OXMAdConfiguration()
        adConfiguration.isInterstitialAd = true
        
        let model = OXMCreativeModel(adConfiguration: adConfiguration)
        model.html = "<html>test html</html>"
        
        let transaction = UtilitiesForTesting.createEmptyTransaction()
        transaction.adConfiguration.isInterstitialAd = true
        
        let htmlCreative =  OXMHTMLCreative(
            creativeModel: model,
            transaction: transaction,
            webView: mockWebView,
               sdkConfiguration: OXASDKConfiguration()
        )
        
        let popModalExpectation = self.expectation(description: "Should pop modal")
        let modalManager = MockModalManager()
        modalManager.mock_popModalClosure = {
            popModalExpectation.fulfill()
        }
        
        htmlCreative.modalManager = modalManager
        htmlCreative.creativeViewDelegate = self
        
        let mockVC = MockViewController()
        
        htmlCreative.setupView()
        htmlCreative.showAsInterstitial(fromRootViewController: mockVC, displayProperties: OXMInterstitialDisplayProperties())

        // RUN TEST
        
        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("close"))

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testCloseChangeState() {
        
        // SETUP ENVIRONMENT
        
        let mockWebView = MockOXMWebView();
        mockWebView.isViewable = true
        
        let model = OXMCreativeModel(adConfiguration:OXMAdConfiguration())
        model.html = "<html>test html</html>"

        let htmlCreative =  OXMHTMLCreative(
            creativeModel: model,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
               sdkConfiguration: OXASDKConfiguration()
        )
        
        htmlCreative.modalManager = OXMModalManager()
        htmlCreative.creativeViewDelegate = self
        
        let mockVC = MockViewController()
        let state = OXMModalState(view: mockWebView, adConfiguration:OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        htmlCreative.modalManager!.pushModal(state, fromRootViewController:mockVC, animated:true, shouldReplace:false, completionHandler:nil)
        
        htmlCreative.setupView()
        
        // SETUP EXPECTATIONS
        
        creativeReadyToReimplantExpectation = self.expectation(description: "Should set creative ready to reimplant")
        
        let changeToMRAIDExpectation = self.expectation(description: "Should change to default MRAID state")
        mockWebView.mock_changeToMRAIDState = { (state) in
            changeToMRAIDExpectation.fulfill()
            OXMAssertEq(state, .default)
        }
        
        // RUN TEST
        
        htmlCreative.webView(mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("close"))
        htmlCreative.modalManagerDidFinishPop(state)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: = OXMCreativeViewDelegate
    
    func creativeDidComplete(_ creative: OXMAbstractCreative) {}
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {}
    func creativeWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {}
    
    func creativeReady(toReimplant creative: OXMAbstractCreative) {
        creativeReadyToReimplantExpectation.fulfill()
    }
    
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
}
