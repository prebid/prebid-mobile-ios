//
//  OXMHTMLCreativeTest_Base.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

typealias OXMCreativeViewDelegateHandler = ((OXMAbstractCreative) -> Void)

class OXMHTMLCreativeTest_Base: XCTestCase, OXMCreativeViewDelegate {

    let timeout: TimeInterval = 1
    var htmlCreative: MockOXMHTMLCreative!
    var transaction: OXMTransaction!

    var mockCreativeModel: MockOXMCreativeModel!
    var mockEventTracker: MockOXMAdModelEventTracker!
    var mockModalManager: MockModalManager!
    var mockWebView: MockOXMWebView!
    var mockViewController: MockViewController!

    override func setUp() {
        
        super.setUp()
        mockViewController = MockViewController()
        
        //Set up MockServer
        let serverConnection = OXMServerConnection(userAgentService: MockUserAgentService())
        serverConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        //Set up creative model
        mockCreativeModel = MockOXMCreativeModel(adConfiguration: OXMAdConfiguration())
        mockCreativeModel.width = 320
        mockCreativeModel.height = 50
        mockCreativeModel.html = "test"
        
        mockEventTracker = MockOXMAdModelEventTracker(creativeModel: mockCreativeModel, serverConnection: serverConnection)
        mockCreativeModel.eventTracker = mockEventTracker
        
        //Set up HTML Creative
        mockModalManager = MockModalManager()
        mockWebView = MockOXMWebView()
        htmlCreative = MockOXMHTMLCreative(
            creativeModel: mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
               sdkConfiguration: OXASDKConfiguration()
        )
        
        htmlCreative.downloadBlock = createLoader(connection: serverConnection)
        htmlCreative.creativeViewDelegate = self
        htmlCreative.modalManager = mockModalManager
        //Simulate creativeFactory
        htmlCreative.setupView()
        
        //Simulate OXMBannerView.creativeReadyForImmediateDisplay:
        //Add the view to the "OXMBannerView" (in this case, the viewController's view)
        //Then call creative.display
        guard let creativeView = htmlCreative.view else {
            XCTFail("No View")
            return
        }
        mockViewController.view.addSubview(creativeView)
        htmlCreative.display(withRootViewController: mockViewController)
    }

    override func tearDown() {
        htmlCreative = nil
        mockCreativeModel = nil
        mockModalManager = nil
        mockWebView = nil
        mockViewController = nil
        MockOXMDeviceAccessManager.reset()
        super.tearDown()
    }

    // MARK: - CreativeViewDelegate
    var creativeInterstitialDidLeaveAppHandler: OXMCreativeViewDelegateHandler?
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {
        creativeInterstitialDidLeaveAppHandler?(creative)
    }

    var creativeInterstitialDidCloseHandler: OXMCreativeViewDelegateHandler?
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {
        creativeInterstitialDidCloseHandler?(creative)
    }

    var creativeClickthroughDidCloseHandler: OXMCreativeViewDelegateHandler?
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {
        creativeClickthroughDidCloseHandler?(creative)
    }

    var creativeReadyToReimplantHandler: OXMCreativeViewDelegateHandler?
    func creativeReady(toReimplant creative: OXMAbstractCreative) {
        creativeReadyToReimplantHandler?(creative)
    }

    var creativeMraidDidCollapseHandler: OXMCreativeViewDelegateHandler?
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {
        creativeMraidDidCollapseHandler?(creative)
    }

    var creativeMraidDidExpandHandler: OXMCreativeViewDelegateHandler?
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {
        creativeMraidDidExpandHandler?(creative)
    }

    var creativeDidCompleteHandler: OXMCreativeViewDelegateHandler?
    func creativeDidComplete(_ creative: OXMAbstractCreative) {
        creativeDidCompleteHandler?(creative)
    }

    var creativeWasClickedHandler: ((OXMAbstractCreative) -> Void)?
    func creativeWasClicked(_ creative: OXMAbstractCreative) {
        creativeWasClickedHandler?(creative)
    }
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}

    // MARK: - Utilities
    /**
     Setup an expectation and associated, mocked `OXMWebView` to fulfill that expectation.

     - parameters:
         - shouldFulfill: Whether or not the expecation is expected to fulfill
         - message: If `shouldFulfill`, the error message to check against
         - action: If `shouldFulfill`, the action to check against
     */
    func mraidErrorExpectation(shouldFulfill: Bool, message expectedMessage: String? = nil, action expectedAction: OXMMRAIDAction? = nil, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Should \(shouldFulfill ? "" : "not ")call webview with an MRAID error")
        exp.isInverted = !shouldFulfill
        mockWebView.mock_MRAID_error = { (actualMessage, actualAction) in
            if shouldFulfill {
                OXMAssertEq(actualMessage, expectedMessage, file: file, line: line)
                OXMAssertEq(actualAction, expectedAction, file: file, line: line)
            }
            exp.fulfill()
        }
    }
    
    func createLoader(connection: OXMServerConnectionProtocol) -> OXMCreativeFactoryDownloadDataCompletionClosure {
        let result: OXMCreativeFactoryDownloadDataCompletionClosure =  {url, completionBlock in
            let downloader = OXMDownloadDataHelper(oxmServerConnection:connection)
            downloader.downloadData(for: url, completionClosure: { (data:Data?, error:Error?) in
                completionBlock(data,error)
            })
        }
        
        return result
    }
}
