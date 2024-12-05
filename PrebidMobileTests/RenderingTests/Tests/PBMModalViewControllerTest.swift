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

class PBMModalViewControllerTest: XCTestCase, PBMModalViewControllerDelegate {
    
    var expectation:XCTestExpectation?
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    func testConfigure() {
        // Set closeDelay
        let properties = PBMInterstitialDisplayProperties()
        properties.closeDelay = 1
    }
    
    func testConfigureSubView() {
        let controller = PBMModalViewController()
        
        // displayView
        logToFile = .init()
        controller.configureSubView()
        var log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains("Attempted to display a nil view"))
        
        // contentView
        
        controller.setupState(PBMModalState(view: UIView(), adConfiguration: AdConfiguration(), displayProperties:nil, onStatePopFinished: nil, onStateHasLeftApp: nil))
        controller.contentView = nil
        XCTAssertTrue(controller.isRotationEnabled)
        
        logToFile = nil
        logToFile = .init()
        
        controller.configureSubView()
        log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains("ContentView not yet set up by InterfaceBuilder. Nothing to add content to"))
        
        controller.contentView = UIView()
        
        logToFile = nil
        logToFile = .init()
        
        controller.configureSubView()
        log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains("currentDisplayView is already a child of self.view"))
    }
    
    func testButtonPressed() {
        let closeButtonCallback = #selector(PBMModalViewController.closeButtonTapped)
        callMethod(selector: closeButtonCallback, message: "Expected closeButtonCallback to be called")
    }
    
    func testCloseButtonVisibility() {
        let testDelay: TimeInterval = 3
        let controller = PBMModalViewController()
        
        let displayProperties = PBMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = testDelay
        
        let modalState = PBMModalState(view: UIView(), adConfiguration: AdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
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
        
        let viewController = PBMModalViewController()
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
    
    func testCreativeDisplayCompleted_Rewarded() {
        let controller = PBMModalViewController()
        let displayProperties = PBMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = 3
        
        let adConfiguration = AdConfiguration()
        adConfiguration.isRewarded = true
        adConfiguration.winningBidAdFormat = .video
        
        let modalState = PBMModalState(
            view: UIView(),
            adConfiguration: adConfiguration,
            displayProperties: displayProperties,
            onStatePopFinished: nil,
            onStateHasLeftApp: nil
        )
        
        controller.modalState = modalState
        
        controller.closeButtonDecorator.button.isHidden = true
        XCTAssertTrue(controller.closeButtonDecorator.button.isHidden)
        
        let creative = UtilitiesForTesting.createHTMLCreative()
        creative.creativeModel?.adConfiguration = adConfiguration
        controller.creativeDisplayCompleted(creative)
        XCTAssertFalse(controller.closeButtonDecorator.button.isHidden)
    }
    
    func testConfigureCloseButton() {
        expectation = self.expectation(description: "expectation modalViewControllerCloseButtonTapped")
        
        let controller = PBMModalViewController()
        controller.setupState(PBMModalState(view: UIView(), adConfiguration: AdConfiguration(), displayProperties:nil, onStatePopFinished: nil, onStateHasLeftApp: nil))
        
        XCTAssertNotNil(controller.closeButtonDecorator.button)
        XCTAssertFalse(controller.closeButtonDecorator.button.isHidden)
        
        controller.modalViewControllerDelegate = self
        controller.closeButtonDecorator.buttonTappedAction()
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCloseButtonDelay() {
        let displayProperties = PBMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = 1
        
        let modalState = PBMModalState(view: UIView(), adConfiguration: AdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
        
        let controller = PBMModalViewController()
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
        let webView = PBMWebView()
        webView.isRotationEnabled = false
        let view = UIView()
        view.addSubview(webView)
        let modalState = PBMModalState(view: view, adConfiguration: AdConfiguration(), displayProperties:PBMInterstitialDisplayProperties(), onStatePopFinished: nil, onStateHasLeftApp: nil)
        
        let controller = PBMModalViewController()
        XCTAssertTrue(controller.isRotationEnabled)
        
        controller.setupState(modalState)
        XCTAssertFalse(controller.isRotationEnabled)
    }
    
    func testConfigureDisplayView() {
        let controller = PBMModalViewController()
        controller.setupState(PBMModalState(view: UIView(), adConfiguration: AdConfiguration(), displayProperties:nil, onStatePopFinished: nil, onStateHasLeftApp: nil))
        var displayView = controller.displayView
        let contentView = controller.contentView
        
        XCTAssertNil(displayView?.backgroundColor)
        XCTAssertNil(contentView?.backgroundColor)
        
        let width:CGFloat = 100.0
        let height:CGFloat = 110.0
        let displayProperties = PBMInterstitialDisplayProperties()
        displayProperties.contentViewColor = UIColor.red
        displayProperties.contentFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView()
        
        controller.setupState(PBMModalState(view: view, adConfiguration: AdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil))
        
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
        
        let controller = PBMModalViewController()
        
        let displayProperties = PBMInterstitialDisplayProperties()
        displayProperties.closeDelayLeft = closeButtonDelay
        
        let modalState = PBMModalState(view: UIView(), adConfiguration: AdConfiguration(), displayProperties:displayProperties, onStatePopFinished: nil, onStateHasLeftApp: nil)
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
        let modalViewController = PBMModalViewController()
        modalViewController.modalViewControllerDelegate = self
        
        self.expectation = self.expectation(description: message)
        modalViewController.perform(selector)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    //MARK - PBMModalViewControllerDelegate
    func modalViewControllerCloseButtonTapped(_ modalViewController: PBMModalViewController) {
        expectation?.fulfill()
    }
    
    func modalViewControllerDidLeaveApp() {
        expectation?.fulfill()
    }
}
