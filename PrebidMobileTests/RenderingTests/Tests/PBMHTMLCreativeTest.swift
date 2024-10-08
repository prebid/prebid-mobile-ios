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
import UIKit

@testable import PrebidMobile

class PBMHTMLCreativeTest_PublicAPI: PBMHTMLCreativeTest_Base {
    
    override func tearDown() {
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testSetupView_failsWithNoHTML() {
        
        //Re-create the html creative with nil html
        self.mockCreativeModel.html = nil
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: self.mockWebView,
            sdkConfiguration: Prebid.mock
        )
        self.htmlCreative.setupView()
        
        PBMAssertEq(self.htmlCreative.view, nil)
    }
    
    func testSetupViewFailWithVast() {
        self.mockCreativeModel.html = UtilitiesForTesting.loadFileAsStringFromBundle("prebid_vast_response.xml")
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: self.mockWebView,
            sdkConfiguration: Prebid.mock
        )
        self.htmlCreative.setupView()
        
        PBMAssertEq(self.htmlCreative.view, nil)
    }
    
    func testSetupView_sizesWebViewCorrectly() {
        self.htmlCreative.setupView()
        
        let expectedFrame = CGRect(x: 0, y: 0, width: self.mockCreativeModel.width, height: self.mockCreativeModel.height)
        PBMAssertEq(self.htmlCreative.view?.frame, expectedFrame)
    }
    
    func testSetupView_sanitizesHTML() {
        self.mockCreativeModel.html = "<p>html content</p>"
        let expectedHTML = "<html><body>\(self.mockCreativeModel.html!)</body></html>"
        
        var actualHTML: String?
        mockWebView.mock_loadHTML = { (html, _, _) in actualHTML = html }
        
        self.htmlCreative.setupView()
        self.htmlCreative.display(withRootViewController:mockViewController)
        
        PBMAssertEq(actualHTML, expectedHTML)
    }
    
    func testDisplay_failsWithInvalidView() {
        //TODO: Update this test to check the log instead
        
        //Set view to nil. Expect that display will fail and thus constraints will be nil
        self.htmlCreative.view = nil
        self.htmlCreative.display(withRootViewController: UIViewController())
        PBMAssertEq(self.htmlCreative.view?.constraints, nil)
        
        //Set view to non-nil. Expect that display will succeed and this constraints will be non-nil.
        self.htmlCreative.view = UIView()
        self.htmlCreative.display(withRootViewController: UIViewController())
        PBMAssertEq(self.htmlCreative.view?.constraints, [])
    }
    
    func testDisplay_triggersImpression() {
        
        Prebid.forcedIsViewable = true
        defer { Prebid.reset() }
        
        let impressionExpectation = self.expectation(description: "Should have triggered an impression")
        var expectedEvents = [PBMTrackingEvent.loaded, .impression]
        self.mockEventTracker.mock_trackEvent = { (event) in
            let nextEvent = expectedEvents.first
            PBMAssertEq(nextEvent == nil, false)
            if (nextEvent != nil) {
                PBMAssertEq(event, nextEvent)
                expectedEvents.remove(at: 0)
                if (expectedEvents.isEmpty) {
                    impressionExpectation.fulfill()
                }
            }
        }
        
        mockWebView.mock_loadHTML = { (_, _, _) in
            self.mockWebView.delegate?.webViewReady(toDisplay: self.mockWebView!)
        }
        
        self.htmlCreative.display(withRootViewController: UIViewController())
        
        self.waitForExpectations(timeout: 1)
    }
    
    func testCompanionClickthrough() {
        let companionTrackingClickExpectation = self.expectation(description: "companionTrackingClickExpectation")
        self.mockEventTracker.mock_trackEvent = { (event) in
            if (event == PBMTrackingEvent.companionClick) {
                companionTrackingClickExpectation.fulfill()
            }
        }
        
        self.mockCreativeModel.isCompanionAd = true
        let mockViewController = MockViewController()
        self.htmlCreative.display(withRootViewController: mockViewController)
        self.htmlCreative.webView(self.mockWebView, receivedClickthroughLink:URL(string: "http://companionTrackingURL")!)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - Measurement
    
    func testMeassurementSession() {
        
        let measurement = MockMeasurementWrapper()
        
        // Measurement expectations
        let expectationInjectJS = self.expectation(description:"expectationInjectJS")
        measurement.injectJSLibClosure = { html in
            expectationInjectJS.fulfill()
        }
        
        let expectationInitializeSession = self.expectation(description:"expectationInitializeSession")
        
        // Session's expectations
        let expectationSessionStart = self.expectation(description:"expectationSessionStart")
        let expectationSessionStop = self.expectation(description:"expectationSessionStop")
        
        measurement.initializeSessionClosure = { session in
            guard let session = session as? MockMeasurementSession else {
                XCTFail()
                return
            }
            
            session.startClosure = {
                expectationSessionStart.fulfill()
            }
            
            session.stopClosure = {
                expectationSessionStop.fulfill()
            }
            
            expectationInitializeSession.fulfill()
        }
        
        let measurementExpectations = [
            expectationInjectJS,
            expectationInitializeSession, // The session must be initialized after WebView had finished loading OM script
            expectationSessionStart,
        ]
        
        let pbmCreativeModel = PBMCreativeModel(adConfiguration: AdConfiguration())
        pbmCreativeModel.displayDurationInSeconds = 30
        pbmCreativeModel.html = "<html>test html</html>"
        
        self.transaction = UtilitiesForTesting.createEmptyTransaction()
        transaction.measurementWrapper = measurement
        
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:transaction,
            webView: nil,
            sdkConfiguration: Prebid.mock
        )
        
        self.htmlCreative.setupView()
        self.htmlCreative.display(withRootViewController:mockViewController)
        transaction.creatives.add(self.htmlCreative!)
        self.htmlCreative.createOpenMeasurementSession();
        
        wait(for: measurementExpectations, timeout: 5, enforceOrder: true);
        
        self.htmlCreative = nil
        self.transaction = nil
        
        wait(for: [expectationSessionStop], timeout: 1);
    }
    
    func testEventClick() {
        
        let expectation = self.expectation(description: "PBMTrackingEventClick Expectation")
        expectation.expectedFulfillmentCount = 2
        
        self.mockEventTracker.mock_trackEvent = { (event) in
            if (event == PBMTrackingEvent.click) {
                expectation.fulfill()
            }
        }
        
        let mockViewController = MockViewController()
        self.htmlCreative.display(withRootViewController: mockViewController)
        
        // Play video
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("playVideo/amazingVideo"))
        
        // MRAID resize
        let validResizeProperties: MRAIDResizeProperties = {
            let rsp = MRAIDResizeProperties()
            rsp.width = 320
            rsp.height = 50
            return rsp
        }()
        
        self.mockWebView.mraidState = .default
        self.mockWebView.mock_MRAID_getResizeProperties = { $0(validResizeProperties) }
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("resize"))
        self.waitForExpectations(timeout: 3)
    }
}

class PBMHTMLCreativeTest : XCTestCase, PBMCreativeResolutionDelegate, PBMCreativeViewDelegate {
    
    // expectations
    var expectationDownloadCompleted: XCTestExpectation?
    var expectationDownloadFailed: XCTestExpectation?
    var expectationCreativeDidComplete: XCTestExpectation!
    var expectationCreativeDidDisplay: XCTestExpectation!
    var expectationCreativeWasClicked: XCTestExpectation!
    var expectationBlockForAWhile: XCTestExpectation!
    
    // test objects
    var htmlCreative: MockPBMHTMLCreative!
    var transaction: PBMTransaction!
    let mockViewController = MockViewController()
    
    let clickThroughURL = URL(string:"http://www.openx.com")!
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        
        //There should be no network traffic
        MockServer.shared.reset()
        MockServer.shared.notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
        
        PrebidJSLibraryManager.shared.downloadLibraries()
        
        let serverConnection = PrebidServerConnection()
        serverConnection.protocolClasses.append(MockServerURLProtocol.self)
        
        //Test
        let pbmCreativeModel = PBMCreativeModel(adConfiguration: AdConfiguration())
        pbmCreativeModel.displayDurationInSeconds = 30
        pbmCreativeModel.html = "<html>test html</html>"
        
        self.htmlCreative = MockPBMHTMLCreative(creativeModel:pbmCreativeModel, transaction:UtilitiesForTesting.createEmptyTransaction())
        self.htmlCreative.creativeResolutionDelegate = self
        self.htmlCreative.creativeViewDelegate = self
        
        Prebid.forcedIsViewable = false
    }
    
    override func tearDown() {
        self.expectationDownloadCompleted = nil
        self.expectationDownloadFailed = nil
        self.expectationCreativeDidComplete = nil
        self.expectationCreativeDidDisplay = nil
        self.expectationCreativeWasClicked = nil
        self.expectationBlockForAWhile = nil
        self.htmlCreative = nil
        logToFile = nil
        PBMFunctions.application = nil
        super.tearDown()
    }
    
    func testWebViewLoad() {
        self.expectationDownloadCompleted = self.expectation(description: "Expected downloadCompleted to be called")
        self.expectationBlockForAWhile = self.expectation(description: "Expected webViewReadyToDisplay to be called")
        
        self.htmlCreative.setupView()
        
        logToFile = .init()
        
        self.htmlCreative.display(withRootViewController:mockViewController)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:{
            let log = Log.getLogFileAsString() ?? ""
            XCTAssertTrue(log.contains("PBMWebView is ready to display"))
            self.expectationBlockForAWhile?.fulfill()
        })
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWebViewFailLoad() {
        self.expectationDownloadCompleted = self.expectation(description: "Expected downloadCompleted to be called")
        self.expectationDownloadFailed = self.expectation(description: "Expected downloadFailed to be called")
        self.htmlCreative.setupView()
        
        logToFile = .init()
        
        let webView = self.htmlCreative.view as! PBMWebView
        self.htmlCreative.webView(webView, failedToLoadWithError:PBMError.error(message: "Failed to load html", type: .internalError))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:{
            let log = Log.getLogFileAsString() ?? ""
            XCTAssertTrue(log.contains("Failed to load html"))
            self.expectationDownloadFailed?.fulfill()
        })
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testClickthrough() {
        PBMFunctions.application = nil
        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")
        self.expectationCreativeWasClicked = self.expectation(description: "Expected creativeWasClicked to be called")
        
        self.htmlCreative.setupView()
        self.htmlCreative.display(withRootViewController:mockViewController)
        
        let webView = self.htmlCreative.view as! PBMWebView
        self.htmlCreative.webView(webView, receivedClickthroughLink:self.clickThroughURL)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testClickthroughOpening() {
        testClickthroughOpening(useExternalBrowser: true)
        testClickthroughOpening(useExternalBrowser: false)
    }
    
    func testClickthroughOpening(useExternalBrowser: Bool) {
        let sdkConfiguration = Prebid.mock
        sdkConfiguration.useExternalClickthroughBrowser = useExternalBrowser
        
        let attemptedToOpenBrowser = expectation(description: "attemptedToOpenBrowser")
        attemptedToOpenBrowser.isInverted = !useExternalBrowser
        
        let mockApplication = MockUIApplication()
        mockApplication.openURLClosure = { url in
            XCTAssertEqual(url, self.clickThroughURL)
            attemptedToOpenBrowser.fulfill()
            return true
        }
        
        let pbmCreativeModel = PBMCreativeModel(adConfiguration: AdConfiguration())
        let mockWebView = MockPBMWebView()
        htmlCreative = MockPBMHTMLCreative(
            creativeModel: pbmCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
            sdkConfiguration: sdkConfiguration
        )
        PBMFunctions.application = mockApplication
        
        htmlCreative.webView(mockWebView, receivedClickthroughLink:self.clickThroughURL)
        
        waitForExpectations(timeout: 3)
    }
    
    func testHasVastTag() {
        let adConfiguration = AdConfiguration()
        let pbmCreativeModel = PBMCreativeModel(adConfiguration: adConfiguration)
        self.htmlCreative = MockPBMHTMLCreative(creativeModel: pbmCreativeModel, transaction: UtilitiesForTesting.createEmptyTransaction())
        
        let validXML1 = "<VAST version=\"123\""
        XCTAssertTrue(self.htmlCreative.hasVastTag(validXML1))
        
        let validXML2 = "<   VAST       version    =     \"123\">"
        XCTAssertTrue(self.htmlCreative.hasVastTag(validXML2))
        
        let incorrectXML1 = "<VASTversion =\"123\"><what>"
        XCTAssertFalse(self.htmlCreative.hasVastTag(incorrectXML1))
        
        let incorrectXML2 = "<html>VAST version=123</html>"
        XCTAssertFalse(self.htmlCreative.hasVastTag(incorrectXML2))
    }
    
    func testViewability() {
        self.htmlCreative.setupView()
        self.htmlCreative.creativeResolutionDelegate = nil
        
        let parentWindow = UIWindow()
        let parentView = UIView()
        
        parentWindow.frame  = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        self.htmlCreative.view?.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 50)
        
        parentView.addSubview(self.htmlCreative.view!)
        parentWindow.addSubview(parentView)
        
        self.expectationCreativeDidDisplay = self.expectation(description: "Expected creativeDidDisplay to be called")
        
        let viewabilityTracker = PBMCreativeViewabilityTracker(creative: self.htmlCreative)
        viewabilityTracker.checkViewability()
        
        self.waitForExpectations(timeout: 1, handler: nil)
        
        self.htmlCreative.view?.removeFromSuperview()
        self.htmlCreative.view?.frame = CGRect(x: 101.0, y: 101.0, width: 100, height: 100)
        
        parentView.addSubview(self.htmlCreative.view!)
        
        self.expectationCreativeDidDisplay = self.expectation(description: "Expected creativeDidDisplay should not be called")
        self.expectationCreativeDidDisplay.isInverted = true
        viewabilityTracker.checkViewability()
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRewardEvent_Banner() {
        let time: NSNumber = 5
        let exp = expectation(description: "Reward completion")
        
        let ortbRewarded = PBMORTBRewardedConfiguration()
        ortbRewarded.completion = PBMORTBRewardedCompletion()
        ortbRewarded.completion?.banner = PBMORTBRewardedCompletionBanner()
        ortbRewarded.completion?.banner?.time = time
        
        let adConfiguration = AdConfiguration()
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
        adConfiguration.isRewarded = true
        let creativeModel = PBMCreativeModel(adConfiguration: adConfiguration)
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: creativeModel,
            transaction: UtilitiesForTesting.createEmptyTransaction()
        )
        
        htmlCreative.onViewabilityChanged(
            true,
            viewExposure: PBMViewExposure(
                exposureFactor: 5,
                visibleRectangle: CGRect(origin: .zero, size: CGSize(width: 300, height: 250))
            )
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time.intValue + 1)) {
            if self.htmlCreative.creativeModel?.userHasEarnedReward == true {
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testRewardEvent_Endcard() {
        let time: NSNumber = 5
        let exp = expectation(description: "Reward completion")
        
        let ortbRewarded = PBMORTBRewardedConfiguration()
        ortbRewarded.completion = PBMORTBRewardedCompletion()
        ortbRewarded.completion?.video = PBMORTBRewardedCompletionVideo()
        ortbRewarded.completion?.video?.endcard = PBMORTBRewardedCompletionVideoEndcard()
        ortbRewarded.completion?.video?.endcard?.time = time
        
        let adConfiguration = AdConfiguration()
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
        adConfiguration.isRewarded = true
        let creativeModel = PBMCreativeModel(adConfiguration: adConfiguration)
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: creativeModel,
            transaction: UtilitiesForTesting.createEmptyTransaction()
        )
        
        htmlCreative.creativeModel?.isCompanionAd = true
        
        htmlCreative.onViewabilityChanged(
            true,
            viewExposure: PBMViewExposure(
                exposureFactor: 5,
                visibleRectangle: CGRect(origin: .zero, size: CGSize(width: 300, height: 250))
            )
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time.intValue + 1)) {
            
            if self.htmlCreative.creativeModel?.userHasEarnedReward == true {
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testPostRewardEvent_Banner() {
        let rewardTime: NSNumber = 2
        let postRewardTime: NSNumber = 2
        let exp = expectation(description: "Post reward completion")
        
        let ortbRewarded = PBMORTBRewardedConfiguration()
        ortbRewarded.completion = PBMORTBRewardedCompletion()
        ortbRewarded.completion?.banner = PBMORTBRewardedCompletionBanner()
        ortbRewarded.completion?.banner?.time = rewardTime
        ortbRewarded.close = PBMORTBRewardedClose()
        ortbRewarded.close?.postrewardtime = postRewardTime
        
        let adConfiguration = AdConfiguration()
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
        adConfiguration.isRewarded = true
        let creativeModel = PBMCreativeModel(adConfiguration: adConfiguration)
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: creativeModel,
            transaction: UtilitiesForTesting.createEmptyTransaction()
        )
        
        htmlCreative.onViewabilityChanged(
            true,
            viewExposure: PBMViewExposure(
                exposureFactor: 5,
                visibleRectangle: CGRect(origin: .zero, size: CGSize(width: 300, height: 250))
            )
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(rewardTime.intValue + postRewardTime.intValue + 1)) {
            if self.htmlCreative.creativeModel?.userPostRewardEventSent == true {
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testPostRewardEvent_Endcard() {
        let rewardTime: NSNumber = 2
        let postRewardTime: NSNumber = 2
        let exp = expectation(description: "Post reward completion")
        
        let ortbRewarded = PBMORTBRewardedConfiguration()
        ortbRewarded.completion = PBMORTBRewardedCompletion()
        ortbRewarded.completion?.video = PBMORTBRewardedCompletionVideo()
        ortbRewarded.completion?.video?.endcard = PBMORTBRewardedCompletionVideoEndcard()
        ortbRewarded.completion?.video?.endcard?.time = rewardTime
        ortbRewarded.close = PBMORTBRewardedClose()
        ortbRewarded.close?.postrewardtime = postRewardTime
        
        let adConfiguration = AdConfiguration()
        adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: ortbRewarded)
        adConfiguration.isRewarded = true
        let creativeModel = PBMCreativeModel(adConfiguration: adConfiguration)
        self.htmlCreative = MockPBMHTMLCreative(
            creativeModel: creativeModel,
            transaction: UtilitiesForTesting.createEmptyTransaction()
        )
        
        htmlCreative.creativeModel?.isCompanionAd = true
        
        htmlCreative.onViewabilityChanged(
            true,
            viewExposure: PBMViewExposure(
                exposureFactor: 5,
                visibleRectangle: CGRect(origin: .zero, size: CGSize(width: 300, height: 250))
            )
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(rewardTime.intValue + postRewardTime.intValue + 1)) {
            if self.htmlCreative.creativeModel?.userPostRewardEventSent == true {
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10)
    }
    
    //MARK: - PBMCreativeResolutionDelegate
    
    func creativeDidComplete(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    
    func creativeDidDisplay(_ creative: PBMAbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func creativeWasClicked(_ creative: PBMAbstractCreative) {
        expectationCreativeWasClicked.fulfill()
    }
    
    func videoCreativeDidComplete(_ creative: PBMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: PBMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: PBMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: PBMAbstractCreative) {}
    
    func creativeReady(toReimplant creative: PBMAbstractCreative) {
        XCTAssert(false)
    }
    
    func creativeMraidDidCollapse(_ creative: PBMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: PBMAbstractCreative) {}
    
    func creativeReady(_ creative: PBMAbstractCreative) {
        fulfillOrFail(self.expectationDownloadCompleted, "expectationCreativeReady")
    }
    
    func creativeFailed(_ error: Error) {
        XCTFail("error: \(error)")
    }
    
    func creativeFullScreenDidFinish(_ creative: PBMAbstractCreative) {}
    func creativeDidSendRewardedEvent(_ creative: PBMAbstractCreative) {}
}
