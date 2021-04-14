//
//  OXMModalViewControllerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//

import XCTest

@testable import PrebidMobileRendering

class OXMModalViewControllerTest: XCTestCase, OXMModalViewControllerDelegate {
    
    var expectation:XCTestExpectation?
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testConfigure() {
        // Set closeDelay
        let properties = OXMInterstitialDisplayProperties()
        properties.closeDelay = 1
    }
    
    func testConfigureSubView() {
        let controller = OXMModalViewController()
        
        // displayView
        logToFile = .init()
        controller.configureSubView()
        var log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains("Attempted to display a nil view"))
        
        // contentView

        controller.setupState(OXMModalState(view: UIView(), adConfiguration: OXMAdConfiguration(), displayProperties:nil, onStatePopFinished: nil, onStateHasLeftApp: nil))
        controller.contentView = nil
        XCTAssertTrue(controller.isRotationEnabled)
        
        logToFile = nil
        logToFile = .init()
        
        controller.configureSubView()
        log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains("ContentView not yet set up by InterfaceBuilder. Nothing to add content to"))
        
        controller.contentView = UIView()
        
        logToFile = nil
        logToFile = .init()
        
        controller.configureSubView()
        log = OXMLog.singleton.getLogFileAsString()
        XCTAssertTrue(log.contains("currentDisplayView is already a child of self.view"))
}
    
    func testButtonPressed() {
        let closeButtonCallback = #selector(OXMModalViewController.closeButtonTapped)
        callMethod(selector: closeButtonCallback, message: "Expected closeButtonCallback to be called")
        
        let clickThroughBrowserViewWillLeaveApp = #selector(OXMModalViewController.clickThroughBrowserViewWillLeaveApp)
        callMethod(selector: clickThroughBrowserViewWillLeaveApp, message: "Expected clickThroughBrowserViewWillLeaveApp to be called")
    }
    
    func testClickthroughBrowserViewDelegate() {
        let clickThroughBrowserViewCloseButtonTapped = #selector(OXMModalViewController.clickThroughBrowserViewCloseButtonTapped)
        callMethod(selector: clickThroughBrowserViewCloseButtonTapped, message: "Expected clickThroughBrowserViewCloseButtonTapped to be called")
        
        let clickThroughBrowserViewWillLeaveApp = #selector(OXMModalViewController.clickThroughBrowserViewWillLeaveApp)
        callMethod(selector: clickThroughBrowserViewWillLeaveApp, message: "Expected clickThroughBrowserViewWillLeaveApp to be called")
    }
    
    func testCloseButtonVisibility() {
        let testDelay: TimeInterval = 3
        let controller = OXMModalViewController()
        
        let displayProperties = OXMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = testDelay

        let modalState = OXMModalState(view: UIView(), adConfiguration: OXMAdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
        controller.modalState = modalState
        
        let expectationShowCloseButton = self.expectation(description: "expectationShowCloseButton")
        let startTest = Date()
        controller.setupCloseButtonDelay()
        controller.showCloseButtonBlock = { // Hack: replace block. Must be after setupCloseButtonDelay()
            expectationShowCloseButton.fulfill()
            let delay = Date().timeIntervalSince(startTest)
            XCTAssertTrue(delay > testDelay)
        }
        
        waitForExpectations(timeout: testDelay + 1)
    }
    
    func testCloseButtonVisibilityWithInterruptionLessThanTotalDelay() {
        
        checkCloseButtonVisibilityWithInterruption(closeButtonDelay: 5,
                                                   interruptionTimeout: 2,
                                                   interruptionInterval: 1)
    }
    
    func testCloseButtonVisibilityWithInterruptionBiggerThanTotalDelay() {
        
        checkCloseButtonVisibilityWithInterruption(closeButtonDelay: 5,
                                                   interruptionTimeout: 2,
                                                   interruptionInterval: 4)
    }
    
    func testTopLevelUI() {
        
        let viewController = OXMModalViewController()
        viewController.preferAppStatusBarHidden = false
        
        let rootWindow = UIWindow(frame: UIScreen.main.bounds)
        rootWindow.isHidden = false
        rootWindow.rootViewController = viewController
        _ = viewController.view
        viewController.viewWillAppear(false)
        
        XCTAssertTrue(viewController.prefersStatusBarHidden)
        
        viewController.viewWillDisappear(false)
        
        XCTAssertFalse(viewController.prefersStatusBarHidden)
    }
    
    func testCreativeDisplayCompleted() {
        let controller = OXMModalViewController()
        let displayProperties = OXMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = 3
        
        let adConfiguration = OXMAdConfiguration()
        adConfiguration.isOptIn = true
        
        let modalState = OXMModalState(view: UIView(), adConfiguration: adConfiguration, displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
        controller.modalState = modalState
        
        controller.closeButtonDecorator.button.isHidden = true;
        XCTAssertTrue(controller.closeButtonDecorator.button.isHidden)
        
        let creative = UtilitiesForTesting.createHTMLCreative()
        controller.creativeDisplayCompleted(creative)
        XCTAssertFalse(controller.closeButtonDecorator.button.isHidden)
    }
    
    func testConfigureCloseButton() {
        expectation = self.expectation(description: "expectation modalViewControllerCloseButtonTapped")
        
        let controller = OXMModalViewController()
        controller.setupState(OXMModalState(view: UIView(), adConfiguration: OXMAdConfiguration(), displayProperties:nil, onStatePopFinished: nil, onStateHasLeftApp: nil))
        
        XCTAssertNotNil(controller.closeButtonDecorator.button)
        XCTAssertFalse(controller.closeButtonDecorator.button.isHidden)
        
        controller.modalViewControllerDelegate = self
        controller.closeButtonDecorator.buttonTappedAction()
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCloseButtonDelay() {        
        let displayProperties = OXMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = 1
        
        let modalState = OXMModalState(view: UIView(), adConfiguration: OXMAdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
        
        let controller = OXMModalViewController()
        controller.modalState = modalState
        
        let expectationShowCloseButtonInitial = self.expectation(description: "expectationShowCloseButtonInitial")
        
        controller.setupCloseButtonDelay()
        controller.closeButtonDecorator.button.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + displayProperties.closeDelayLeft + 0.5, execute:{
            XCTAssertFalse(controller.closeButtonDecorator.button.isHidden)
            expectationShowCloseButtonInitial.fulfill()
        })
        
        wait(for: [expectationShowCloseButtonInitial], timeout: 2)
    }
    
    func testRotationDisabled() {
        let webView = OXMWebView()
        webView.isRotationEnabled = false
        let view = UIView()
        view.addSubview(webView)
        let modalState = OXMModalState(view: view, adConfiguration: OXMAdConfiguration(), displayProperties:OXMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
       
        let controller = OXMModalViewController()
        XCTAssertTrue(controller.isRotationEnabled)

        controller.setupState(modalState)
        XCTAssertFalse(controller.isRotationEnabled)
    }
    
    func testConfigureDisplayView() {
        let controller = OXMModalViewController()
        controller.setupState(OXMModalState(view: UIView(), adConfiguration: OXMAdConfiguration(), displayProperties:nil, onStatePopFinished: nil, onStateHasLeftApp: nil))
        var displayView = controller.displayView
        let contentView = controller.contentView
        
        XCTAssertNil(displayView?.backgroundColor)
        XCTAssertNil(contentView?.backgroundColor)
        
        let width:CGFloat = 100.0
        let height:CGFloat = 110.0
        let displayProperties = OXMInterstitialDisplayProperties()
        displayProperties.contentViewColor = UIColor.red
        displayProperties.contentFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView()
        
        controller.setupState(OXMModalState(view: view, adConfiguration: OXMAdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil))

        displayView = controller.displayView
        XCTAssertEqual(displayView?.backgroundColor, UIColor.clear)
        XCTAssertEqual(contentView?.backgroundColor, UIColor.red)
        
        let hasConstraint = { (attr: NSLayoutConstraint.Attribute, value: CGFloat) -> Bool in
            controller.contentView!.constraints
                .contains(where: { $0.firstAttribute == attr && $0.constant == value })
        }
        
        XCTAssertTrue(hasConstraint(.width, width))
        XCTAssertTrue(hasConstraint(.height, height))
    }
    
    // MARK: Test Implementation
    
    private func checkCloseButtonVisibilityWithInterruption(closeButtonDelay: TimeInterval,
                                                            interruptionTimeout: TimeInterval,
                                                            interruptionInterval: TimeInterval ) {
        
        let controller = OXMModalViewController()
        
        let displayProperties = OXMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = closeButtonDelay
        
        let modalState = OXMModalState(view: UIView(), adConfiguration: OXMAdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
        controller.modalState = modalState
        
        let expectationShowCloseButtonInitial = self.expectation(description: "expectationShowCloseButtonInitial")
        expectationShowCloseButtonInitial.isInverted = true
        
        controller.setupCloseButtonDelay()
        controller.showCloseButtonBlock = { // Hack: replace block. Must be after setupCloseButtonDelay()
            expectationShowCloseButtonInitial.fulfill()
        }
        
        wait(for: [expectationShowCloseButtonInitial], timeout: interruptionTimeout)
        
        controller.onCloseDelayInterrupted()
        
        XCTAssertNil(controller.showCloseButtonBlock)
        XCTAssertNil(controller.startCloseDelay)
        
        sleep(UInt32(interruptionInterval))
        
        let startTest = Date()
        let delayLeftExpectation = closeButtonDelay - interruptionTimeout
        
        let expectationShowCloseButtonFinal = self.expectation(description: "expectationShowCloseButtonFinal")
        
        controller.setupCloseButtonDelay()
        controller.showCloseButtonBlock = { // Hack: replace block. Must be after setupCloseButtonDelay()
            expectationShowCloseButtonFinal.fulfill()
            let delay = Date().timeIntervalSince(startTest)
            XCTAssertEqual(delay, delayLeftExpectation, accuracy: 0.1)
        }
        
        waitForExpectations(timeout: delayLeftExpectation + 1)
    }
    
    // MARK: Helper Methods
    
    func callMethod(selector: Selector, message: String) {
        let modalViewController = OXMModalViewController()
        modalViewController.modalViewControllerDelegate = self
        
        self.expectation = self.expectation(description: message)
        modalViewController.perform(selector)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    //MARK - OXMModalViewControllerDelegate
    func modalViewControllerCloseButtonTapped(_ modalViewController: OXMModalViewController) {
        expectation?.fulfill()
    }
    
    func modalViewControllerDidLeaveApp() {
        expectation?.fulfill()
    }
}
