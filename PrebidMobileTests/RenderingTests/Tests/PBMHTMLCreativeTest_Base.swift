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

typealias PBMCreativeViewDelegateHandler = ((PBMAbstractCreative) -> Void)

class PBMHTMLCreativeTest_Base: XCTestCase, PBMCreativeViewDelegate {
    
    let timeout: TimeInterval = 1
    var htmlCreative: MockPBMHTMLCreative!
    var transaction: PBMTransaction!
    
    var mockCreativeModel: MockPBMCreativeModel!
    var mockEventTracker: MockPBMAdModelEventTracker!
    var mockModalManager: MockModalManager!
    var mockWebView: MockPBMWebView!
    var mockViewController: MockViewController!
    
    override func setUp() {
        
        super.setUp()
        mockViewController = MockViewController()
        
        //Set up MockServer
        let serverConnection = PrebidServerConnection(userAgentService: MockUserAgentService())
        serverConnection.protocolClasses.append(MockServerURLProtocol.self)
        
        //Set up creative model
        mockCreativeModel = MockPBMCreativeModel(adConfiguration: AdConfiguration())
        mockCreativeModel.width = 320
        mockCreativeModel.height = 50
        mockCreativeModel.html = "test"
        
        mockEventTracker = MockPBMAdModelEventTracker(creativeModel: mockCreativeModel, serverConnection: serverConnection)
        mockCreativeModel.eventTracker = mockEventTracker
        
        //Set up HTML Creative
        mockModalManager = MockModalManager()
        mockWebView = MockPBMWebView()
        htmlCreative = MockPBMHTMLCreative(
            creativeModel: mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
            sdkConfiguration: Prebid.mock
        )
        
        htmlCreative.downloadBlock = createLoader(connection: serverConnection)
        htmlCreative.creativeViewDelegate = self
        htmlCreative.modalManager = mockModalManager
        //Simulate creativeFactory
        htmlCreative.setupView()
        
        //Simulate PBMBannerView.creativeReadyForImmediateDisplay:
        //Add the view to the "PBMBannerView" (in this case, the viewController's view)
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
        super.tearDown()
    }
    
    // MARK: - CreativeViewDelegate
    var creativeInterstitialDidLeaveAppHandler: PBMCreativeViewDelegateHandler?
    func creativeInterstitialDidLeaveApp(_ creative: PBMAbstractCreative) {
        creativeInterstitialDidLeaveAppHandler?(creative)
    }
    
    var creativeInterstitialDidCloseHandler: PBMCreativeViewDelegateHandler?
    func creativeInterstitialDidClose(_ creative: PBMAbstractCreative) {
        creativeInterstitialDidCloseHandler?(creative)
    }
    
    var creativeClickthroughDidCloseHandler: PBMCreativeViewDelegateHandler?
    func creativeClickthroughDidClose(_ creative: PBMAbstractCreative) {
        creativeClickthroughDidCloseHandler?(creative)
    }
    
    var creativeReadyToReimplantHandler: PBMCreativeViewDelegateHandler?
    func creativeReady(toReimplant creative: PBMAbstractCreative) {
        creativeReadyToReimplantHandler?(creative)
    }
    
    var creativeMraidDidCollapseHandler: PBMCreativeViewDelegateHandler?
    func creativeMraidDidCollapse(_ creative: PBMAbstractCreative) {
        creativeMraidDidCollapseHandler?(creative)
    }
    
    var creativeMraidDidExpandHandler: PBMCreativeViewDelegateHandler?
    func creativeMraidDidExpand(_ creative: PBMAbstractCreative) {
        creativeMraidDidExpandHandler?(creative)
    }
    
    var creativeDidCompleteHandler: PBMCreativeViewDelegateHandler?
    func creativeDidComplete(_ creative: PBMAbstractCreative) {
        creativeDidCompleteHandler?(creative)
    }
    
    var creativeWasClickedHandler: ((PBMAbstractCreative) -> Void)?
    func creativeWasClicked(_ creative: PBMAbstractCreative) {
        creativeWasClickedHandler?(creative)
    }
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative) {}
    
    // MARK: - Utilities
    /**
     Setup an expectation and associated, mocked `PBMWebView` to fulfill that expectation.
     
     - parameters:
     - shouldFulfill: Whether or not the expecation is expected to fulfill
     - message: If `shouldFulfill`, the error message to check against
     - action: If `shouldFulfill`, the action to check against
     */
    func mraidErrorExpectation(shouldFulfill: Bool, message expectedMessage: String? = nil, action expectedAction: PBMMRAIDAction? = nil, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Should \(shouldFulfill ? "" : "not ")call webview with an MRAID error")
        exp.isInverted = !shouldFulfill
        mockWebView.mock_MRAID_error = { (actualMessage, actualAction) in
            if shouldFulfill {
                PBMAssertEq(actualMessage, expectedMessage, file: file, line: line)
                PBMAssertEq(actualAction, expectedAction, file: file, line: line)
            }
            exp.fulfill()
        }
    }
    
    func createLoader(connection: PrebidServerConnectionProtocol) -> PBMCreativeFactoryDownloadDataCompletionClosure {
        let result: PBMCreativeFactoryDownloadDataCompletionClosure =  {url, completionBlock in
            let downloader = PBMDownloadDataHelper(serverConnection:connection)
            downloader.downloadData(for: url, completionClosure: { (data:Data?, error:Error?) in
                completionBlock(data,error)
            })
        }
        
        return result
    }
}
