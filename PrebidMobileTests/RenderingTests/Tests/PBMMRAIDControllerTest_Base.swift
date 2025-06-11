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
@testable @_spi(PBMInternal) import PrebidMobile

class PBMMRAIDControllerTest_Base: XCTestCase, CreativeViewDelegate {
    
    let timeout: TimeInterval = 1
    
    var serverConnection: PrebidServerConnection!
    var transaction: Transaction!
    var mockHtmlCreative: MockPBMHTMLCreative!
    var mockCreativeModel: MockPBMCreativeModel!
    var mockEventTracker: MockPBMAdModelEventTracker!
    var mockModalManager: MockModalManager!
    var mockWebView: MockPBMWebView!
    var mockViewController: MockViewController!
    
    var MRAIDController: PBMMRAIDController!
    
    override func setUp() {
        
        super.setUp()
        self.mockViewController = MockViewController()
        
        //Set up MockServer
        self.serverConnection = PrebidServerConnection(userAgentService: MockUserAgentService())
        self.serverConnection.protocolClasses.append(MockServerURLProtocol.self)
        
        //Set up creative model
        self.mockCreativeModel = MockPBMCreativeModel(adConfiguration: AdConfiguration())
        self.mockCreativeModel.width = 320
        self.mockCreativeModel.height = 50
        self.mockCreativeModel.html = "test"
        
        self.mockEventTracker = MockPBMAdModelEventTracker(creativeModel: self.mockCreativeModel,
                                                           serverConnection: self.serverConnection)
        self.mockCreativeModel.eventTracker = self.mockEventTracker
        
        //Set up HTML Creative
        self.mockModalManager = MockModalManager()
        self.mockWebView = MockPBMWebView()
        self.mockHtmlCreative = MockPBMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: self.mockWebView,
            sdkConfiguration: Prebid.mock
        )
        
        self.mockHtmlCreative.creativeViewDelegate = self
        self.mockHtmlCreative.modalManager = self.mockModalManager
        //Simulate creativeFactory
        self.mockHtmlCreative.setupView()
        
        //Simulate PBMBannerView.creativeReadyForImmediateDisplay:
        //Add the view to the "PBMBannerView" (in this case, the viewController's view)
        //Then call creative.display
        guard let creativeView = self.mockHtmlCreative.view else {
            XCTFail("No View")
            return
        }
        self.mockViewController.view.addSubview(creativeView)
        self.mockHtmlCreative.display(rootViewController: self.mockViewController)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.mockHtmlCreative = nil
        self.mockCreativeModel = nil
        self.mockModalManager = nil
        self.mockWebView = nil
        self.serverConnection = nil
        
        super.tearDown()
    }
    
    // MARK: - CreativeViewDelegate
    var creativeInterstitialDidLeaveAppHandler: CreativeViewDelegateHandler?
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {
        self.creativeInterstitialDidLeaveAppHandler?(creative)
    }
    
    var creativeInterstitialDidCloseHandler: CreativeViewDelegateHandler?
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {
        self.creativeInterstitialDidCloseHandler?(creative)
    }
    
    var creativeClickthroughDidCloseHandler: CreativeViewDelegateHandler?
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {
        self.creativeClickthroughDidCloseHandler?(creative)
    }
    
    var creativeReadyToReimplantHandler: CreativeViewDelegateHandler?
    func creativeReadyToReimplant(_ creative: AbstractCreative) {
        self.creativeReadyToReimplantHandler?(creative)
    }
    
    var creativeMraidDidCollapseHandler: CreativeViewDelegateHandler?
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {
        self.creativeMraidDidCollapseHandler?(creative)
    }
    
    var creativeMraidDidExpandHandler: CreativeViewDelegateHandler?
    func creativeMraidDidExpand(_ creative: AbstractCreative) {
        self.creativeMraidDidExpandHandler?(creative)
    }
    
    var creativeDidCompleteHandler: CreativeViewDelegateHandler?
    func creativeDidComplete(_ creative: AbstractCreative) {
        self.creativeDidCompleteHandler?(creative)
    }
    
    var creativeWasClickedHandler: ((AbstractCreative) -> Void)?
    func creativeWasClicked(_ creative: AbstractCreative) {
        self.creativeWasClickedHandler?(creative)
    }
    
    func videoCreativeDidComplete(_ creative: AbstractCreative) {}
    func creativeDidDisplay(_ creative: AbstractCreative) {}
    func creativeViewWasClicked(_ creative: AbstractCreative) {}
    func creativeFullScreenDidFinish(_ creative: AbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: AbstractCreative) {}
    
    // MARK: - Utilities
    /**
     Setup an expectation and associated, mocked `PBMWebView` to fulfill that expectation.
     
     - parameters:
     - shouldFulfill: Whether or not the expecation is expected to fulfill
     - message: If `shouldFulfill`, the error message to check against
     - action: If `shouldFulfill`, the action to check against
     */
    
    func mraidErrorExpectation(shouldFulfill: Bool, message expectedMessage: String? = nil, action expectedAction: PBMMRAIDAction? = nil, file: StaticString = #file, line: UInt = #line) {
        let exp = self.expectation(description: "Should \(shouldFulfill ? "" : "not ")call webview with an MRAID error")
        exp.isInverted = !shouldFulfill
        self.mockWebView.mock_MRAID_error = { (actualMessage, actualAction) in
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
