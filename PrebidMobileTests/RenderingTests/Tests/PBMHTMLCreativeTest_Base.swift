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

typealias CreativeViewDelegateHandler = ((AbstractCreative) -> Void)

class PBMHTMLCreativeTest_Base: XCTestCase, CreativeViewDelegate {
    
    let timeout: TimeInterval = 1
    var htmlCreative: MockPBMHTMLCreative!
    var transaction: Transaction!
    
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
        htmlCreative.display(rootViewController: mockViewController)
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
    var creativeInterstitialDidLeaveAppHandler: CreativeViewDelegateHandler?
    func creativeInterstitialDidLeaveApp(_ creative: AbstractCreative) {
        creativeInterstitialDidLeaveAppHandler?(creative)
    }
    
    var creativeInterstitialDidCloseHandler: CreativeViewDelegateHandler?
    func creativeInterstitialDidClose(_ creative: AbstractCreative) {
        creativeInterstitialDidCloseHandler?(creative)
    }
    
    var creativeClickthroughDidCloseHandler: CreativeViewDelegateHandler?
    func creativeClickthroughDidClose(_ creative: AbstractCreative) {
        creativeClickthroughDidCloseHandler?(creative)
    }
    
    var creativeReadyToReimplantHandler: CreativeViewDelegateHandler?
    func creativeReadyToReimplant(_ creative: AbstractCreative) {
        creativeReadyToReimplantHandler?(creative)
    }
    
    var creativeMraidDidCollapseHandler: CreativeViewDelegateHandler?
    func creativeMraidDidCollapse(_ creative: AbstractCreative) {
        creativeMraidDidCollapseHandler?(creative)
    }
    
    var creativeMraidDidExpandHandler: CreativeViewDelegateHandler?
    func creativeMraidDidExpand(_ creative: AbstractCreative) {
        creativeMraidDidExpandHandler?(creative)
    }
    
    var creativeDidCompleteHandler: CreativeViewDelegateHandler?
    func creativeDidComplete(_ creative: AbstractCreative) {
        creativeDidCompleteHandler?(creative)
    }
    
    var creativeWasClickedHandler: ((AbstractCreative) -> Void)?
    func creativeWasClicked(_ creative: AbstractCreative) {
        creativeWasClickedHandler?(creative)
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
