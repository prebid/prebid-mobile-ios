//
//  OXMMRAIDControllerTest_Base.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMMRAIDControllerTest_Base: XCTestCase, OXMCreativeViewDelegate {
    
    let timeout: TimeInterval = 1
    
    var serverConnection: OXMServerConnection!
    var transaction: OXMTransaction!
    var mockHtmlCreative: MockOXMHTMLCreative!
    var mockCreativeModel: MockOXMCreativeModel!
    var mockEventTracker: MockOXMAdModelEventTracker!
    var mockModalManager: MockModalManager!
    var mockWebView: MockOXMWebView!
    var mockViewController: MockViewController!
    
    var MRAIDController: OXMMRAIDController!
    
    override func setUp() {
        
        super.setUp()
        self.mockViewController = MockViewController()
        
        //Set up MockServer
        self.serverConnection = OXMServerConnection(userAgentService: MockUserAgentService())
        self.serverConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        //Set up creative model
        self.mockCreativeModel = MockOXMCreativeModel(adConfiguration: OXMAdConfiguration())
        self.mockCreativeModel.width = 320
        self.mockCreativeModel.height = 50
        self.mockCreativeModel.html = "test"
        
        self.mockEventTracker = MockOXMAdModelEventTracker(creativeModel: self.mockCreativeModel,
                                                           serverConnection: self.serverConnection)
        self.mockCreativeModel.eventTracker = self.mockEventTracker
        
        //Set up HTML Creative
        self.mockModalManager = MockModalManager()
        self.mockWebView = MockOXMWebView()
        self.mockHtmlCreative = MockOXMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: self.mockWebView,
               sdkConfiguration: OXASDKConfiguration()
        )
        
        self.mockHtmlCreative.creativeViewDelegate = self
        self.mockHtmlCreative.modalManager = self.mockModalManager
        //Simulate creativeFactory
        self.mockHtmlCreative.setupView()
        
        //Simulate OXMBannerView.creativeReadyForImmediateDisplay:
        //Add the view to the "OXMBannerView" (in this case, the viewController's view)
        //Then call creative.display
        guard let creativeView = self.mockHtmlCreative.view else {
            XCTFail("No View")
            return
        }
        self.mockViewController.view.addSubview(creativeView)
        self.mockHtmlCreative.display(withRootViewController: self.mockViewController)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.mockHtmlCreative = nil
        self.mockCreativeModel = nil
        self.mockModalManager = nil
        self.mockWebView = nil
        self.serverConnection = nil
        MockOXMDeviceAccessManager.reset()
        
        super.tearDown()
    }
    
    // MARK: - CreativeViewDelegate
    var creativeInterstitialDidLeaveAppHandler: OXMCreativeViewDelegateHandler?
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {
        self.creativeInterstitialDidLeaveAppHandler?(creative)
    }
    
    var creativeInterstitialDidCloseHandler: OXMCreativeViewDelegateHandler?
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {
        self.creativeInterstitialDidCloseHandler?(creative)
    }
    
    var creativeClickthroughDidCloseHandler: OXMCreativeViewDelegateHandler?
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {
        self.creativeClickthroughDidCloseHandler?(creative)
    }
    
    var creativeReadyToReimplantHandler: OXMCreativeViewDelegateHandler?
    func creativeReady(toReimplant creative: OXMAbstractCreative) {
        self.creativeReadyToReimplantHandler?(creative)
    }
    
    var creativeMraidDidCollapseHandler: OXMCreativeViewDelegateHandler?
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {
        self.creativeMraidDidCollapseHandler?(creative)
    }
    
    var creativeMraidDidExpandHandler: OXMCreativeViewDelegateHandler?
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {
        self.creativeMraidDidExpandHandler?(creative)
    }
    
    var creativeDidCompleteHandler: OXMCreativeViewDelegateHandler?
    func creativeDidComplete(_ creative: OXMAbstractCreative) {
        self.creativeDidCompleteHandler?(creative)
    }
    
    var creativeWasClickedHandler: ((OXMAbstractCreative) -> Void)?
    func creativeWasClicked(_ creative: OXMAbstractCreative) {
        self.creativeWasClickedHandler?(creative)
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
        let exp = self.expectation(description: "Should \(shouldFulfill ? "" : "not ")call webview with an MRAID error")
        exp.isInverted = !shouldFulfill
        self.mockWebView.mock_MRAID_error = { (actualMessage, actualAction) in
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
