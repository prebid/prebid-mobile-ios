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
import StoreKit

@_spi(PBMInternal) @testable import PrebidMobile

class PBMAbstractCreativeTest: XCTestCase, CreativeResolutionDelegate {
    
    var expectation:XCTestExpectation?
    var pbmAbstractCreative: PBMAbstractCreative_Objc!
    let msgAbstractFunctionCalled = "Abstract function called"
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        self.pbmAbstractCreative = PBMAbstractCreative_Objc(creativeModel:CreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction())
        self.pbmAbstractCreative.creativeResolutionDelegate = self
    }
    
    override func tearDown() {
        logToFile = nil
        self.pbmAbstractCreative = nil;
        
        super.tearDown()
    }
    
    func testIsOpened() {
        XCTAssertFalse(self.pbmAbstractCreative.isOpened)
    }
    
    func testSetupViewBackground() {
        logToFile = .init()
        
        self.pbmAbstractCreative.setupView(withThread: MockNSThread(mockIsMainThread: false))
        
        UtilitiesForTesting.checkLogContains("Attempting to set up view on background thread")
    }
    
    func testModalManagerDidFinishPop() {
        logToFile = .init()
        let state = Factory.createModalState(view: PBMWebView(),
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties())
        self.pbmAbstractCreative.modalManagerDidFinishPop(state)
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }

    func testModalManagerDidLeaveApp() {
        logToFile = .init()
        let state = Factory.createModalState(view: PBMWebView(),
                                             adConfiguration:AdConfiguration(),
                                             displayProperties:InterstitialDisplayProperties())
        pbmAbstractCreative.modalManagerDidLeaveApp(state)
        let log = Log.getLogFileAsString() ?? ""
        XCTAssertTrue(log.contains(msgAbstractFunctionCalled))
    }
    
    func testOnResolutionCompleted() {
        expectation = self.expectation(description: "Expected downloadCompleted to be called")
        pbmAbstractCreative.isDownloaded = false
        pbmAbstractCreative.onResolutionCompleted()
        waitForExpectations(timeout: 4, handler: { _ in
            XCTAssertTrue(self.pbmAbstractCreative.isDownloaded)
        })
    }
    
    func testOnResolutionFailed() {
        self.expectation = self.expectation(description: "Expected downloadFailed to be called")
        pbmAbstractCreative.isDownloaded = false
        pbmAbstractCreative.onResolutionFailed(NSError(domain: "OpenXSDK", code: 123, userInfo: [:]))
        waitForExpectations(timeout: 4, handler: { _ in
            XCTAssertTrue(self.pbmAbstractCreative.isDownloaded)
        })
    }
    
    //MARK - PBMCreativeResolutionDelegate
    
    func creativeReady(_ creative: AbstractCreative) {
        expectation?.fulfill()
        XCTAssertTrue(creative.isDownloaded)
    }
    
    func creativeFailed(_ error: Error) {
        expectation?.fulfill()
        XCTAssertTrue(self.pbmAbstractCreative.isDownloaded)
    }
    
    //MARK - Open Measurement

    func testOpenMeasurement() {
        logToFile = .init()
        self.pbmAbstractCreative.createOpenMeasurementSession()
        UtilitiesForTesting.checkLogContains("Abstract function called")
    }

    //MARK - SKStoreProductViewControllerDelegate

    func testProductViewControllerDidFinish_notifiesDelegateAndCallsExitBlockOnce() {
        let delegate = MockCreativeViewDelegate()
        pbmAbstractCreative.creativeViewDelegate = delegate

        var clickthroughDidCloseCount = 0
        delegate.creativeClickthroughDidCloseHandler = { _ in
            clickthroughDidCloseCount += 1
        }

        var exitBlockCount = 0
        pbmAbstractCreative.skStoreProductViewControllerExitBlock = {
            exitBlockCount += 1
        }

        let skadnController = SKStoreProductViewController()
        pbmAbstractCreative.productViewControllerDidFinish(skadnController)

        XCTAssertEqual(clickthroughDidCloseCount, 1)
        XCTAssertEqual(exitBlockCount, 1)
        XCTAssertNil(pbmAbstractCreative.skStoreProductViewControllerExitBlock,
                     "Exit block should be released after being called")

        // A repeated delegate callback must not fire the exit block again
        pbmAbstractCreative.productViewControllerDidFinish(skadnController)
        XCTAssertEqual(exitBlockCount, 1)
    }

    func testHandleProductClickthrough_presentsOnTopmostViewController() {
        let rootVC = MockPresentedViewController()
        let modalVC = MockPresentedViewController()
        rootVC.presentVC = modalVC

        pbmAbstractCreative.viewControllerForPresentingModals = rootVC

        let handled = pbmAbstractCreative.handleProductClickthrough(
            URL(string: "https://example.com")!,
            productParams: [SKStoreProductParameterITunesItemIdentifier: "12345"],
            onExit: {}
        )

        XCTAssertTrue(handled)
        XCTAssertNotNil(pbmAbstractCreative.skStoreProductViewControllerExitBlock)

        let presentationExpectation = expectation(description: "SKStoreProductViewController presented from topmost view controller")
        DispatchQueue.main.async {
            XCTAssertTrue(modalVC.presentVC is SKStoreProductViewController)
            XCTAssertTrue(rootVC.presentVC === modalVC,
                          "Already presented view controller should not be replaced")
            presentationExpectation.fulfill()
        }
        waitForExpectations(timeout: 4)
    }

    func testHandleProductClickthrough_withoutViewController_returnsFalse() {
        logToFile = .init()

        pbmAbstractCreative.viewControllerForPresentingModals = nil

        let handled = pbmAbstractCreative.handleProductClickthrough(
            URL(string: "https://example.com")!,
            productParams: [SKStoreProductParameterITunesItemIdentifier: "12345"],
            onExit: {}
        )

        XCTAssertFalse(handled)
        XCTAssertNil(pbmAbstractCreative.skStoreProductViewControllerExitBlock)
    }
}
