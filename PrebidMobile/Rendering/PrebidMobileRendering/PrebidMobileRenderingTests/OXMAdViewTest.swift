
import Foundation
import UIKit
import XCTest
@testable import OpenXSDKCore

class PBMAdViewTest: XCTestCase, PBMAdViewDelegate {
    
    // MARK: - Test Properties
    
    var expectationAdDidLoadCalled:XCTestExpectation!
    var expectationAdDidFailToLoadCalled:XCTestExpectation!
    var expectationAdDidDisplayCalled:XCTestExpectation!
    var expectationAdDidCompleteCalled:XCTestExpectation!
    var expectationAdDidLeaveApplication:XCTestExpectation!
    var expectationAdWasClickedCalled:XCTestExpectation!
    var expectationAdClickthroughDidCloseCalled:XCTestExpectation!
    var expectationAdInterstitialDidCloseCalled:XCTestExpectation!
    var expectationAdDidCollapseCalled:XCTestExpectation!
    var expectationAdDidExpandCalled:XCTestExpectation!
    
    var adDidLoadedCompletion: ((PBMAdDetails) -> Void)?
    
    // MARK: - Initialization
    
    override func tearDown() {
        PBMLog.whereAmI()
        
        self.expectationAdDidLoadCalled = nil
        self.expectationAdDidFailToLoadCalled = nil
        self.expectationAdDidDisplayCalled = nil
        self.expectationAdDidCompleteCalled = nil
        self.expectationAdWasClickedCalled = nil
        self.expectationAdClickthroughDidCloseCalled = nil
        self.expectationAdInterstitialDidCloseCalled = nil
        self.expectationAdDidCollapseCalled = nil
        self.expectationAdDidExpandCalled = nil
    }
    
    // MARK: - Tests
    
    func testPBMConfiguration() {
        let config = PBMSDKConfiguration()
        let ExpectedValue = 99.0
        config.creativeFactoryTimeout = ExpectedValue
        XCTAssertEqual(ExpectedValue, config.creativeFactoryTimeout)
        
        config.creativeFactoryTimeoutPreRenderContent = ExpectedValue
        XCTAssertEqual(ExpectedValue, config.creativeFactoryTimeoutPreRenderContent)

    }
    
    func testDefaultInitialization() {
        
        let config = PBMSDKConfiguration()
        config.defaultDomain = "foo.com"
        config.defaultAdUnitId = "abc123"
        config.defaultAutoRefreshDelay = -100
        
        let adView = PBMAdView(connection: PBMServerConnection(), config:config)
        
        XCTAssert(adView.adUnitId == "abc123", "Expected adUnitId to be nil string, but it was \(String(describing: adView.adUnitId))")
        XCTAssert(adView.domain == "foo.com", "Expected domain to be nil string, but it was \(String(describing: adView.domain))")
        XCTAssert(adView.vastURL == nil, "Expected vastURL to be nil string, but it was \(String(describing: adView.vastURL))")
        XCTAssert(adView.delegate == nil, "Expected delegate to not be nil (because we set it in setup)")
        XCTAssert(adView.autoRefreshDelay == PBMAutoRefresh.AUTO_REFRESH_DELAY_MIN, "Expected autorefreshDelay to be clamped to Min")
        XCTAssert(adView.autoRefreshMax == 0)
    }
    
    func testAdDidLoad() {
        
        //Mock a connection
        MockServer.singleton().reset()
        var expectationACJ = expectation(description: "expectationACJ")
        
        let rule = MockServerRule(urlNeedle: "mockserver.com", mimeType: MockServerMimeType.JSON.rawValue, fileName: "ACJPublisherRevenue500.json")
        rule.mockServerReceivedRequestHandler = { (urlRequest:URLRequest) in
            expectationACJ.fulfill()
        }
        MockServer.singleton().add(rule)
        
        let oxmServerConnection = PBMServerConnection()
        oxmServerConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        
        //Create the ad view
        let adView = PBMAdView(connection: oxmServerConnection, config:PBMSDKConfiguration.singleton)
        adView.adUnitId = "abc123"
        adView.domain = "mockserver.com"
        adView.delegate = self
        
        //Load
        self.expectationAdDidLoadCalled = expectation(description: "expectationAdDidLoadCalled")
        self.expectationAdDidDisplayCalled = expectation(description: "expectationAdDidDisplayCalled")
        
        adDidLoadedCompletion = { adDetails in
            XCTAssert(adDetails.transactionId == "ABC123")
        }
        
        adView.load()
        waitForExpectations(timeout: 3.0, handler:nil)
        
        //Refresh and complete
        expectationACJ = expectation(description: "expectationACJ")
        self.expectationAdDidLoadCalled = expectation(description: "expectationAdDidLoadCalled")
        self.expectationAdDidDisplayCalled = expectation(description: "expectationAdDidDisplayCalled")
        self.expectationAdDidCompleteCalled = expectation(description: "expectationAdDidCompleteCalled")
        
        waitForExpectations(timeout: 15.0, handler:nil)
    }
    
    func testAutoRefreshMax() {
        
        let adView = PBMAdView()
        let adViewManager = PBMAdViewManager(connection: PBMServerConnection())
        
        adView.adViewManager = adViewManager
        
        XCTAssertNil(adViewManager.adLoadManager!.adConfiguration.autoRefreshMax)
        XCTAssertEqual(adView.autoRefreshMax, 0)
        
        adView.autoRefreshMax = 1
        
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.autoRefreshMax, 1)
        XCTAssertEqual(adView.autoRefreshMax, 1)
        
        adView.autoRefreshMax = 0

        XCTAssertNil(adViewManager.adLoadManager!.adConfiguration.autoRefreshMax)
        XCTAssertEqual(adView.autoRefreshMax, 0)
    }
    
    func testAdDidFailToLoad() {
        
        //Mock a connection
        MockServer.singleton().reset()
        let oxmServerConnection = PBMServerConnection()
        oxmServerConnection.protocolClasses.add(MockServerURLProtocol.self)
        
        //Create the ad view
        let adView = PBMAdView(connection: oxmServerConnection, config:PBMSDKConfiguration.singleton)
        PBMLog.info("adView: \(adView)")
        adView.adUnitId = "abc123"
        adView.domain = "mockserver.com"
        adView.delegate = self
        
        //Load
        self.expectationAdDidFailToLoadCalled = expectation(description: "expectationAdDidLoadCalled")
        
        adView.load()
        waitForExpectations(timeout: 3.0, handler:nil)
    }
    
    //TODO: Expand this to be a more "natural" example of replaceWithCreative being used.
    func testReplaceWithCreative() {
        
        let adView = PBMAdView()
        PBMLog.info("adView: \(adView)")
        adView.delegate = self
        
        XCTAssert(adView.subviews.count == 0, "Expected PBMAdView to have no subviews initially")
        
        let creative = UtilitiesForTesting.createHTMLCreative()
        
        adView.replaceWithCreative(creative)
        
        XCTAssert(adView.subviews.count == 1, "Expected PBMAdView to have exactly one subview after replaceWithCreative")
        XCTAssert(adView.subviews.contains(creative.view!), "Expected the subview to be the webview from the creative")
    }
    
    func testReplaceWithCreativeWithoutView() {
        
        let adView = PBMAdView()
        PBMLog.info("adView: \(adView)")
        adView.delegate = self
        
        XCTAssert(adView.subviews.count == 0, "Expected PBMAdView to have no subviews initially")
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        adView.replaceWithCreative(creative)

        XCTAssertNil(creative.view)
        XCTAssertEqual(adView.subviews.count, 0)
    }
    
    // MARK: - PBMAdInterface
    
    func testAdInterfaceGetters() {
        
        let adView = PBMAdView()
        let adViewManager = PBMAdViewManager(connection: PBMServerConnection())
        
        // Test data
        let auid = "test auid"
        let domain = "test domain"
        let adUnitType: PBMAdUnitIdentifierType = .vast
        let htmlToLoad = "test htmlToLoad"
        let autoDisplayOnLoad = !adViewManager.autoDisplayOnLoad
        let connectionTimeoutInSeconds: TimeInterval = 777
        let userParameters = PBMUserParameters()
        let flexAdSize = "test flexAdSize"
        let revenue = "1234"

        // Prepare
        adViewManager.adLoadManager!.adConfiguration.auid = auid
        adViewManager.adLoadManager!.adConfiguration.domain = domain
        adViewManager.adLoadManager!.adConfiguration.oxmAdUnitIdentifierType = adUnitType
        adViewManager.adLoadManager!.adConfiguration.arbitraryhtml = htmlToLoad
        adViewManager.autoDisplayOnLoad = autoDisplayOnLoad
        adViewManager.adLoadManager!.adConfiguration.connectionTimeoutInSeconds = connectionTimeoutInSeconds
        adViewManager.adLoadManager!.adConfiguration.userParameters = userParameters
        adViewManager.adLoadManager!.adConfiguration.flexAdSize = flexAdSize
        
        adViewManager.ads.add(UtilitiesForTesting.getTestAd(revenue: revenue) as Any);

        // Test
        
        adView.adViewManager = adViewManager
        
        XCTAssertEqual(adView.adUnitId, auid)
        XCTAssertEqual(adView.domain, domain)
        XCTAssertEqual(adView.adUnitIdentifierType, adUnitType)
        XCTAssertEqual(adView.htmlToLoad, htmlToLoad)
        XCTAssertEqual(adView.autoDisplayOnLoad, autoDisplayOnLoad)
        XCTAssertEqual(adView.connectionTimeoutInSeconds, connectionTimeoutInSeconds)
        XCTAssertTrue(adView.userParameters === userParameters)
        XCTAssertEqual(adView.flexAdSize, flexAdSize)
        
        XCTAssertEqual(adView.revenueForNextCreative, revenue)
    }
    
    func testAdInterfaceSetters() {
        
        let adView = PBMAdView()
        let adViewManager = PBMAdViewManager(connection: PBMServerConnection())
        
        // Test data
        let auid = "test auid"
        let domain = "test domain"
        let adUnitType: PBMAdUnitIdentifierType = .vast
        let htmlToLoad = "test htmlToLoad"
        let autoDisplayOnLoad = !adViewManager.autoDisplayOnLoad
        let connectionTimeoutInSeconds: TimeInterval = 777
        let userParameters = PBMUserParameters()
        let flexAdSize = "test flexAdSize"
        
        // Prepare
        
        adView.adViewManager = adViewManager
        
        adView.adUnitId = auid
        adView.domain = domain
        adView.adUnitIdentifierType = adUnitType
        adView.htmlToLoad = htmlToLoad
        adView.autoDisplayOnLoad = autoDisplayOnLoad
        adView.connectionTimeoutInSeconds = connectionTimeoutInSeconds
        adView.userParameters = userParameters
        adView.flexAdSize = flexAdSize
        
        // Test

        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.auid, auid)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.domain, domain)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.oxmAdUnitIdentifierType, adUnitType)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.arbitraryhtml, htmlToLoad)
        XCTAssertEqual(adViewManager.autoDisplayOnLoad, autoDisplayOnLoad)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.connectionTimeoutInSeconds, connectionTimeoutInSeconds)
        XCTAssertTrue(adViewManager.adLoadManager!.adConfiguration.userParameters === userParameters)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.flexAdSize, flexAdSize)
    }
    
    func testAutoDetectLocation() {
        
        // Prepare
        
        var adView: PBMAdView? = PBMAdView()
        XCTAssertFalse(adView!.autoDetectLocation)
        
        let mockCLLocationManager = MockCLLocationManager(enableLocationServices: true, authorizationStatus: .authorizedAlways)
        let locationManager = PBMLocationManager(clLocationManager: mockCLLocationManager, geoCoder: MockGeoCoder(), reachability: MockReachability.self)
        let initialLocationClientsCount = locationManager.clientsCount
        
        adView!.locationManager = locationManager
        
        // Tests
        
        adView!.autoDetectLocation = true;
        
        XCTAssertEqual(locationManager.clientsCount, initialLocationClientsCount + 1)
        
        // The location clients count should be decreased in the dealloc
        adView = nil
        
        XCTAssertEqual(locationManager.clientsCount, initialLocationClientsCount)
    }
    
    // MARK: - Tests Interstitial-Specific
    
    func testInterstitialSpecificProperiesGetters() {
        let adView = PBMAdView()
        let adViewManager = PBMAdViewManager(connection: PBMServerConnection())
        
        // Test data
        let isInterstitial = !adViewManager.adLoadManager!.adConfiguration.isInterstitial
        let forceMediatedInterstitial = !adViewManager.adLoadManager!.adConfiguration.forceMediatedInterstitial
        let vastURL = "test VaseURL"
        
        // Prepare
        
        adView.adViewManager = adViewManager
        
        adView.isInterstitial = isInterstitial
        adView.forceMediatedInterstitial = forceMediatedInterstitial
        adView.vastURL = vastURL
        
        // Test
        
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.isInterstitial, isInterstitial)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.forceMediatedInterstitial, forceMediatedInterstitial)
        XCTAssertEqual(adViewManager.adLoadManager!.adConfiguration.vastURL, vastURL)
    }
    
    func testInterstitialSpecificProperiesSetters() {
        let adView = PBMAdView()
        let adViewManager = PBMAdViewManager(connection: PBMServerConnection())
        
        // Test data
        let isInterstitial = !adViewManager.adLoadManager!.adConfiguration.isInterstitial
        let forceMediatedInterstitial = !adViewManager.adLoadManager!.adConfiguration.forceMediatedInterstitial
        let vastURL = "test VaseURL"
        
        // Prepare
        adViewManager.adLoadManager!.adConfiguration.isInterstitial = isInterstitial
        adViewManager.adLoadManager!.adConfiguration.forceMediatedInterstitial = forceMediatedInterstitial
        adViewManager.adLoadManager!.adConfiguration.vastURL = vastURL
        
        // Test
        
        adView.adViewManager = adViewManager
        
        XCTAssertEqual(adView.isInterstitial, isInterstitial)
        XCTAssertEqual(adView.forceMediatedInterstitial, forceMediatedInterstitial)
        XCTAssertEqual(adView.vastURL, vastURL)
    }
    
    // MARK: - Tests PBMAdViewManagerDelegate
    
    func testAdDidComplete() {
        let adView = PBMAdView()
        adView.delegate = self
        
        self.expectationAdDidCompleteCalled = expectation(description: "expectationAdClickthroughDidCloseCalled")
        
        adView.adDidComplete()
        
        waitForExpectations(timeout: 1)
    }
    
    func testAdLoaded() {
        let adView = PBMAdView()
        adView.delegate = self
        
        self.expectationAdDidLoadCalled = expectation(description: "expectationAdDidLoadCalled")
        
        adView.adLoaded(PBMAdDetails())
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeClickthroughDidClose() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        self.expectationAdClickthroughDidCloseCalled = expectation(description: "expectationAdClickthroughDidCloseCalled")
        adView.creativeClickthroughDidClose(creative)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeInterstitialDidClose() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        self.expectationAdInterstitialDidCloseCalled = expectation(description: "expectationAdInterstitialDidCloseCalled")
        adView.creativeInterstitialDidClose(creative)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeInterstitialDidLeaveApp() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        expectationAdDidLeaveApplication = expectation(description: "expectationAdDidLeaveApplication")
        adView.creativeInterstitialDidLeaveApp(creative)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeMraidDidCollapse() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        self.expectationAdDidCollapseCalled = expectation(description: "expectationAdDidCollapseCalled")
        adView.creativeMraidDidCollapse(creative)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeMraidDidExpand() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        self.expectationAdDidExpandCalled = expectation(description: "expectationadDidExpandCalled")
        adView.creativeMraidDidExpand(creative)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeReadyForImmediateDisplay() {
        
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative()
        
        self.expectationAdDidDisplayCalled = expectation(description: "expectationAdDidDisplayCalled")
        
        adView.creativeReadyForImmediateDisplay(creative)
        
        waitForExpectations(timeout: 3, handler: { _ in
            XCTAssertTrue(Thread.isMainThread)
        })
    }
    
    func testCreativeReadyForImmediateDisplayGlobalQueue() {
        
        let adView = PBMAdView()
        adView.delegate = self

        let creative = UtilitiesForTesting.createHTMLCreative()
        
        self.expectationAdDidDisplayCalled = expectation(description: "expectationAdDidDisplayCalled")
        
        DispatchQueue.global().async {
            adView.creativeReadyForImmediateDisplay(creative)
        }
        
        waitForExpectations(timeout: 3, handler: { _ in
            XCTAssertTrue(Thread.isMainThread)
        })
    }
    
    func testCreativeReadyForImmediateDisplayWithoutView() {
        
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        UtilitiesForTesting.prepareLogFile()
        defer {
            PBMLog.singleton.logToFile = false
        }
        
        self.expectationAdDidDisplayCalled = expectation(description: "expectationAdDidDisplayCalled")
        self.expectationAdDidDisplayCalled.isInverted = true
        
        adView.creativeReadyForImmediateDisplay(creative)
        
        let log = PBMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains("Creative \(creative) has no view"))
        
        waitForExpectations(timeout: 1, handler: { _ in
            XCTAssertTrue(adView.delegate === self) // need to be sure that the test class is still a delegate
        })
    }
    
    func testCreativeWasClickedWithoutURL() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        self.expectationAdWasClickedCalled = expectation(description: "expectationAdWasClickedCalled")
        adView.creativeWasClicked(creative, displayClickthrough: nil)
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeWasClickedWithoutViewController() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:false)
        
        self.expectationAdWasClickedCalled = expectation(description: "expectationAdWasClickedCalled")
        
        UtilitiesForTesting.prepareLogFile()
        defer {
            PBMLog.singleton.logToFile = false
        }
        
        adView.creativeWasClicked(creative, displayClickthrough: URL(string:"openx.com"))
        
        let log = PBMLog.singleton.getLogFileAsString()
        
        XCTAssert(log.contains("Could not determine a root view controller"))
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreativeWasClicked() {
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = UtilitiesForTesting.createHTMLCreative(withView:true)
        
        let mockVC = MockViewController()
        mockVC.view.addSubview(adView)
        
        self.expectationAdWasClickedCalled = expectation(description: "expectationAdWasClickedCalled")
        
        adView.creativeWasClicked(creative, displayClickthrough: URL(string:"openx.com"))
        
        waitForExpectations(timeout: 1)

        InterstitialManager.singleton.interstitialClosed()
    }
    
    // MARK: - Tests InterstitialManagerDelegate
    
    func testInterstitialAdClosed() {
        
        let adView = PBMAdView()
        adView.delegate = self
        
        let creative = PBMAbstractCreative(oxmCreativeModel: PBMCreativeModel())
        
        adView.currentCreative = creative
        
        adView.adViewManager.ads.add(UtilitiesForTesting.getTestAd(revenue: "123") as Any);

        self.expectationAdInterstitialDidCloseCalled = expectation(description:"expectationAdInterstitialDidCloseCalled")
        self.expectationAdDidCompleteCalled = expectation(description:"expectationAdDidCompleteCalled")
        
        adView.interstitialAdClosed()
        
        waitForExpectations(timeout: 1)
    }
    
    func testClickthroughBrowserClosed() {
        
        let adView = PBMAdView()
        adView.delegate = self
        
        self.expectationAdClickthroughDidCloseCalled = expectation(description:"expectationAdClickthroughDidCloseCalled")
        
        adView.clickthroughBrowserClosed()
        
        waitForExpectations(timeout: 1)
    }
    
    func testInterstitialDidLeaveApp() {
        
        let adView = PBMAdView()
        adView.delegate = self
        
        expectationAdDidLeaveApplication = expectation(description:"expectationAdDidLeaveApplication")
        
        adView.interstitialDidLeaveApp()
        
        waitForExpectations(timeout: 1)
    }

    //MARK: - PBMAdViewDelegate
    
    // Called every time an ad had loaded and is ready for display
    func adDidLoad(adView:PBMAdView, adDetails:PBMAdDetails) {
        PBMLog.info("adView: \(adView)")
        adDidLoadedCompletion?(adDetails)
        self.expectationAdDidLoadCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    // Called whenever the load process fails to produce a viable ad
    func adDidFailToLoad(adView:PBMAdView, error:Error) {
        PBMLog.info("adView: \(adView), error: \(error)")
        fulfillOrFail(expectationAdDidFailToLoadCalled, "expectationAdDidFailToLoadCalled")
        XCTAssert(Thread.isMainThread)
    }
    
    // Called after an ad has rendered to the device's screen
    func adDidDisplay(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdDidDisplayCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    // Called once an ad has finished displaying all of it's creatives
    func adDidComplete(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdDidCompleteCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    // Called when the user clicks on an ad and a clickthrough is about to occur
    func adWasClicked(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdWasClickedCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    // Called when the user closes a clickthrough
    func adClickthroughDidClose(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdClickthroughDidCloseCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    // Called when a user has closed an interstitial
    func adInterstitialDidClose(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdInterstitialDidCloseCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    func adDidExpand(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdDidExpandCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    func adDidCollapse(adView:PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdDidCollapseCalled.fulfill()
        XCTAssert(Thread.isMainThread)
    }
    
    func adDidLeaveApplication(adView: PBMAdView) {
        PBMLog.info("adView: \(adView)")
        self.expectationAdDidLeaveApplication.fulfill()
        XCTAssert(Thread.isMainThread)
    }
}
