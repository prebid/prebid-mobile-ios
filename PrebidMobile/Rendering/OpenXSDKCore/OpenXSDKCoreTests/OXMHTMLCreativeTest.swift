import Foundation
import XCTest

import UIKit
@testable import OpenXApolloSDK


class OXMHTMLCreativeTest_PublicAPI: OXMHTMLCreativeTest_Base {
    override func tearDown() {
        OXASDKConfiguration.resetSingleton()
        
        super.tearDown()
    }
    
    func testSetupView_failsWithNoHTML() {
        
        //Re-create the html creative with nil html
        self.mockCreativeModel.html = nil
        self.htmlCreative = MockOXMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: self.mockWebView,
               sdkConfiguration: OXASDKConfiguration()
        )
        self.htmlCreative.setupView()
        
        OXMAssertEq(self.htmlCreative.view, nil)
    }

    func testSetupViewFailWithVast() {
        self.mockCreativeModel.html = UtilitiesForTesting.loadFileAsStringFromBundle("openx_vast_response.xml")
        self.htmlCreative = MockOXMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: self.mockWebView,
               sdkConfiguration: OXASDKConfiguration()
        )
        self.htmlCreative.setupView()

        OXMAssertEq(self.htmlCreative.view, nil)
    }

    func testSetupView_sizesWebViewCorrectly() {
        self.htmlCreative.setupView()

        let expectedFrame = CGRect(x: 0, y: 0, width: self.mockCreativeModel.width, height: self.mockCreativeModel.height)
        OXMAssertEq(self.htmlCreative.view?.frame, expectedFrame)
    }

    func testSetupView_sanitizesHTML() {
        self.mockCreativeModel.html = "<p>html content</p>"
        let expectedHTML = "<html><body>\(self.mockCreativeModel.html!)</body></html>"

        var actualHTML: String?
        mockWebView.mock_loadHTML = { (html, _, _) in actualHTML = html }

        self.htmlCreative.setupView()
        self.htmlCreative.display(withRootViewController:mockViewController)

        OXMAssertEq(actualHTML, expectedHTML)
    }

    func testDisplay_failsWithInvalidView() {
        //TODO: Update this test to check the log instead
        
        //Set view to nil. Expect that display will fail and thus constraints will be nil
        self.htmlCreative.view = nil
        self.htmlCreative.display(withRootViewController: UIViewController())
        OXMAssertEq(self.htmlCreative.view?.constraints, nil)

        //Set view to non-nil. Expect that display will succeed and this constraints will be non-nil.
        self.htmlCreative.view = UIView()
        self.htmlCreative.display(withRootViewController: UIViewController())
        OXMAssertEq(self.htmlCreative.view?.constraints, [])
    }

    func testDisplay_triggersImpression() {
        OXASDKConfiguration.singleton.forcedIsViewable = true
        let impressionExpectation = self.expectation(description: "Should have triggered an impression")
        var expectedEvents = [OXMTrackingEvent.loaded, .impression]
        self.mockEventTracker.mock_trackEvent = { (event) in
            let nextEvent = expectedEvents.first
            OXMAssertEq(nextEvent == nil, false)
            if (nextEvent != nil) {
                OXMAssertEq(event, nextEvent)
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
            if (event == OXMTrackingEvent.companionClick) {
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
        
        let oxmCreativeModel = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        oxmCreativeModel.displayDurationInSeconds = 30
        oxmCreativeModel.html = "<html>test html</html>"
        
        self.transaction = UtilitiesForTesting.createEmptyTransaction()
        transaction.measurementWrapper = measurement
      
        self.htmlCreative = MockOXMHTMLCreative(
            creativeModel: self.mockCreativeModel,
            transaction:transaction,
            webView: nil,
               sdkConfiguration: OXASDKConfiguration()
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
        
        let expectation = self.expectation(description: "OXMTrackingEventClick Expectation")
        expectation.expectedFulfillmentCount = 4
        
        self.mockEventTracker.mock_trackEvent = { (event) in
            if (event == OXMTrackingEvent.click) {
                expectation.fulfill()
            }
        }
        
        let mockViewController = MockViewController()
        self.htmlCreative.display(withRootViewController: mockViewController)
        
        // Calendar event
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("createCalendarevent/event"))
        
        // Store picture
        self.htmlCreative.webView(self.mockWebView, receivedMRAIDLink:UtilitiesForTesting.getMRAIDURL("storepicture/picture"))
        
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

class OXMHTMLCreativeTest : XCTestCase, OXMCreativeResolutionDelegate, OXMCreativeViewDelegate {
    
    // expectations
    var expectationDownloadCompleted: XCTestExpectation?
    var expectationDownloadFailed: XCTestExpectation?
    var expectationCreativeDidComplete: XCTestExpectation!
    var expectationCreativeDidDisplay: XCTestExpectation!
    var expectationCreativeWasClicked: XCTestExpectation!
    var expectationBlockForAWhile: XCTestExpectation!
    
    // test objects
    var htmlCreative: MockOXMHTMLCreative!
    var transaction: OXMTransaction!
    let mockViewController = MockViewController()
    
    let clickThroughURL = URL(string:"http://www.openx.com")!
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()

        //There should be no network traffic
        MockServer.singleton().reset()
        MockServer.singleton().notFoundRule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            XCTFail("Unexpected request for \(urlRequest)")
        }
        
        OXMJSLibraryManager.shared().clearData()
        
        let oxmServerConnection = OXMServerConnection()
        oxmServerConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        //Test
        let oxmCreativeModel = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        oxmCreativeModel.displayDurationInSeconds = 30
        oxmCreativeModel.html = "<html>test html</html>"

        self.htmlCreative = MockOXMHTMLCreative(creativeModel:oxmCreativeModel, transaction:UtilitiesForTesting.createEmptyTransaction())
        self.htmlCreative.creativeResolutionDelegate = self
        self.htmlCreative.creativeViewDelegate = self
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
        OXMFunctions.application = nil
        super.tearDown()
    }
    
    func testWebViewLoad() {
        self.expectationDownloadCompleted = self.expectation(description: "Expected downloadCompleted to be called")
        self.expectationBlockForAWhile = self.expectation(description: "Expected webViewReadyToDisplay to be called")

        self.htmlCreative.setupView()
        
        logToFile = .init()
        
        self.htmlCreative.display(withRootViewController:mockViewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:{
            let log = OXMLog.singleton.getLogFileAsString()
            XCTAssertTrue(log.contains("OXMWebView is ready to display"))
            self.expectationBlockForAWhile?.fulfill()
        })
        
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testWebViewFailLoad() {
        self.expectationDownloadCompleted = self.expectation(description: "Expected downloadCompleted to be called")
        self.expectationDownloadFailed = self.expectation(description: "Expected downloadFailed to be called")
        self.htmlCreative.setupView()
        
        logToFile = .init()

        let webView = self.htmlCreative.view as! OXMWebView
        self.htmlCreative.webView(webView, failedToLoadWithError:OXMError.error(message: "Failed to load html", type: .internalError))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute:{
            let log = OXMLog.singleton.getLogFileAsString()
            XCTAssertTrue(log.contains("Failed to load html"))
            self.expectationDownloadFailed?.fulfill()
        })
        
        self.waitForExpectations(timeout: 5, handler: nil)
    } 
    
    func testClickthrough() {
        OXMFunctions.application = nil
        self.expectationDownloadCompleted = self.expectation(description: "expectationCreativeReady")
        self.expectationCreativeWasClicked = self.expectation(description: "Expected creativeWasClicked to be called")
        
        self.htmlCreative.setupView()
        self.htmlCreative.display(withRootViewController:mockViewController)

        let webView = self.htmlCreative.view as! OXMWebView
        self.htmlCreative.webView(webView, receivedClickthroughLink:self.clickThroughURL)
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testClickthroughOpening() {
        testClickthroughOpening(useExternalBrowser: true)
        testClickthroughOpening(useExternalBrowser: false)
    }
    
    func testClickthroughOpening(useExternalBrowser: Bool) {
        let sdkConfiguration = OXASDKConfiguration()
        sdkConfiguration.useExternalClickthroughBrowser = useExternalBrowser
        
        let attemptedToOpenBrowser = expectation(description: "attemptedToOpenBrowser")
        attemptedToOpenBrowser.isInverted = !useExternalBrowser
        
        let mockApplication = MockUIApplication()
        mockApplication.openURLClosure = { url in
            XCTAssertEqual(url, self.clickThroughURL)
            attemptedToOpenBrowser.fulfill()
            return true
        }
        
        let oxmCreativeModel = OXMCreativeModel(adConfiguration: OXMAdConfiguration())
        let mockWebView = MockOXMWebView()
        htmlCreative = MockOXMHTMLCreative(
            creativeModel: oxmCreativeModel,
            transaction:UtilitiesForTesting.createEmptyTransaction(),
            webView: mockWebView,
               sdkConfiguration: sdkConfiguration
        )
        OXMFunctions.application = mockApplication
        
        htmlCreative.webView(mockWebView, receivedClickthroughLink:self.clickThroughURL)
        
        waitForExpectations(timeout: 3)
    }

    func testHasVastTag() {
        let adConfiguration = OXMAdConfiguration()
        let oxmCreativeModel = OXMCreativeModel(adConfiguration: adConfiguration)
        self.htmlCreative = MockOXMHTMLCreative(creativeModel: oxmCreativeModel, transaction: UtilitiesForTesting.createEmptyTransaction())

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

        let viewabilityTracker = OXMCreativeViewabilityTracker(creative: self.htmlCreative)
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

    //MARK: - OXMCreativeResolutionDelegate
    
    func creativeDidComplete(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidComplete.fulfill()
    }
    
    func creativeDidDisplay(_ creative: OXMAbstractCreative) {
        self.expectationCreativeDidDisplay.fulfill()
    }
    
    func creativeWasClicked(_ creative: OXMAbstractCreative) {
        expectationCreativeWasClicked.fulfill()
    }
    
    func videoCreativeDidComplete(_ creative: OXMAbstractCreative) {}
    func creativeViewWasClicked(_ creative: OXMAbstractCreative) {}
    func creativeClickthroughDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidClose(_ creative: OXMAbstractCreative) {}
    func creativeInterstitialDidLeaveApp(_ creative: OXMAbstractCreative) {}
    
    func creativeReady(toReimplant creative: OXMAbstractCreative) {
        XCTAssert(false)
    }
    
    func creativeMraidDidCollapse(_ creative: OXMAbstractCreative) {}
    func creativeMraidDidExpand(_ creative: OXMAbstractCreative) {}
    
    func creativeReady(_ creative: OXMAbstractCreative) {
        fulfillOrFail(self.expectationDownloadCompleted, "expectationCreativeReady")
    }
    
    func creativeFailed(_ error: Error) {
        XCTFail("error: \(error)")
    }
    
    func creativeFullScreenDidFinish(_ creative: OXMAbstractCreative) {}
}
