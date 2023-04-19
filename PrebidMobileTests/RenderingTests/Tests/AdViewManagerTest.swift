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

import Foundation
import XCTest

@testable import PrebidMobile

class AdViewManagerTest: XCTestCase, PBMAdViewManagerDelegate {
    
    weak var viewControllerForModalPresentationExpectation: XCTestExpectation?
    weak var displayViewExpectation: XCTestExpectation?
    weak var interstitialDisplayPropertiesExpectation: XCTestExpectation?
    weak var adLoadedExpectation: XCTestExpectation?
    weak var failedToLoadExpectation: XCTestExpectation?
    weak var adDidDisplayExpectation: XCTestExpectation?
    weak var adWasClickedExpectation: XCTestExpectation?
    weak var adViewWasClickedExpectation: XCTestExpectation?
    weak var adDidCompleteExpectation: XCTestExpectation?
    weak var adDidCloseExpectation: XCTestExpectation?
    weak var adClickthroughDidCloseExpectation: XCTestExpectation?
    weak var adDidCollapseExpectation: XCTestExpectation?
    weak var adDidExpandExpectation: XCTestExpectation?
    weak var adDidLeaveAppExpectation: XCTestExpectation?

    var adViewManager:PBMAdViewManager!
    var adLoadManager:PBMAdLoadManagerBase!
    
    var currentlyDisplaying = false
    var loadError:NSError?
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        
        adViewManager = PBMAdViewManager(connection: PrebidServerConnection(), modalManagerDelegate: nil)
        
        adViewManager.adViewManagerDelegate = self
        Prebid.forcedIsViewable = false
        loadError = nil;
    }
    
    func nilExpectations() {
        displayViewExpectation = nil
        interstitialDisplayPropertiesExpectation = nil
        adLoadedExpectation = nil
        failedToLoadExpectation = nil
        adDidDisplayExpectation = nil
        adWasClickedExpectation = nil
        adViewWasClickedExpectation = nil
        adDidCompleteExpectation = nil
        adDidCloseExpectation = nil
        adClickthroughDidCloseExpectation = nil
        adDidCollapseExpectation = nil
        adDidExpandExpectation = nil
        adDidLeaveAppExpectation = nil
        viewControllerForModalPresentationExpectation = nil
    }

    override func tearDown() {
        adLoadManager = nil
        adViewManager = nil
        logToFile = nil
        
        nilExpectations()
        
        Prebid.reset()
        
        super.tearDown()
    }

    // functions called by a higher level object
    func testInit() {
        XCTAssert(adViewManager.autoDisplayOnLoad == true)
    }
    
    func testInitDefaults() {
        let adViewManager = PBMAdViewManager(connection: PrebidServerConnection(), modalManagerDelegate: nil)
        XCTAssertNil(adViewManager.externalTransaction)
        XCTAssert(adViewManager.autoDisplayOnLoad == true)
    }
    
    func testRevenueForNextCreative () {
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative()
        adViewManager.externalTransaction = transaction
        XCTAssert(adViewManager.revenueForNextCreative() == "1234")
    }

    func testShowWithAutoWhileAdNotDisplaying() {
        nilExpectations()
        adLoadedExpectation = expectation(description: "adLoadedExpectation")
        displayViewExpectation = expectation(description: "displayViewExpectation")
        adDidDisplayExpectation = expectation(description: "adDidDisplayExpectation")
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        
        //Force viewability
        Prebid.forcedIsViewable = true
        
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true)
        adViewManager.handleExternalTransaction(transaction)
        
        XCTAssertEqual(adViewManager.externalTransaction, transaction)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testShowWithoutAutoForInterstitial() {
        // setup expectations; nil those that should not be called
        adLoadedExpectation = expectation(description: "Expected a delegate function adLoaded to fire")
        
        //Force viewability
        Prebid.forcedIsViewable = true
        
        adViewManager.handleExternalTransaction(UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true, isInterstitial: true))
        
        XCTAssertNotNil(adViewManager.externalTransaction)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        // setup expecations; nil those that won't be needed
        nilExpectations()
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        // One call to check isAbleToShowCurrentCreative and one
        // to showAsInterstitialFromRootViewController
        viewControllerForModalPresentationExpectation?.expectedFulfillmentCount = 2
        interstitialDisplayPropertiesExpectation = expectation(description: "Expected a delegate function interstitialDisplayProperties to fire")
        adDidDisplayExpectation = expectation(description: "adDidDisplayExpectation")
        // call show
        adViewManager.show()
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    // functions called by a creative
    func testCreativeCompleteWithOneCreative() {
        // setup expectations
        adLoadedExpectation = expectation(description: "adLoadedExpectation")
        displayViewExpectation = expectation(description: "displayViewExpectation")
        adDidDisplayExpectation = expectation(description: "adDidDisplayExpectation")
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        
        //Force viewability
        Prebid.forcedIsViewable = true
        
        // create an ad with one creative
        adViewManager.handleExternalTransaction(UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true))
        XCTAssertNotNil(adViewManager.externalTransaction)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        //Force a creativeDidComplete. Expect that the ad will not attempt to reload.
        adLoadedExpectation = expectation(description: "adLoadedExpectation")
        adLoadedExpectation?.isInverted = true
        
        failedToLoadExpectation = expectation(description: "failedToLoadExpectation")
        failedToLoadExpectation?.isInverted = true

        displayViewExpectation = expectation(description: "creativeReadyForImmediateDisplayExpectation")
        displayViewExpectation?.isInverted = true
        
        adDidCompleteExpectation = expectation(description: "adDidCompleteExpectation")

        guard let testCreative = adViewManager.externalTransaction?.creatives.firstObject as? PBMHTMLCreative else {
            XCTFail("Could not get PBMHTMLCreative")
            return
        }
        testCreative.creativeViewDelegate?.creativeDidComplete(testCreative)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreativeReadyToReimplant() {
        // setup expectations; nil those that aren't needed
        nilExpectations()
        adLoadedExpectation = expectation(description: "Expected a delegate function adLoaded to fire")
        displayViewExpectation = expectation(description: "displayViewExpectation #1")
        adDidDisplayExpectation = expectation(description: "adDidDisplayExpectation")
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        
        //Force viewability
        Prebid.forcedIsViewable = true
        
        adViewManager.handleExternalTransaction(UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true))
        XCTAssertNotNil(adViewManager.externalTransaction)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        // setup expectations
        displayViewExpectation = expectation(description: "displayViewExpectation #2")
        
        guard let testCreative = adViewManager.externalTransaction?.creatives.firstObject as? PBMHTMLCreative else {
            XCTFail("Could not get PBMHTMLCreative")
            return
        }
        adViewManager.creativeReady(toReimplant: testCreative)
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreativeDidDisplay () {
        let testCreative = setUpDelegateTests()
        
        // setup expectations
        adDidDisplayExpectation = expectation(description: "Expected a delegate function adDidDisplay to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeDidDisplay(testCreative)
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testCreativeWasClicked () {
        let testCreative = setUpDelegateTests()
        
        // setup expectations
        adWasClickedExpectation = expectation(description: "Expected a delegate function adWasClicked to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeWasClicked(testCreative)
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testCreativeViewWasClicked () {
        let testCreative = setUpDelegateTests()
        
        // setup expectations
        adViewWasClickedExpectation = expectation(description: "Expected a delegate function adViewWasClicked to fire")
        interstitialDisplayPropertiesExpectation = expectation(description: "Expected a delegate function interstitialDisplayProperties to fire")
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        // One call to check isAbleToShowCurrentCreative and one
        // to showAsInterstitialFromRootViewController
        viewControllerForModalPresentationExpectation?.expectedFulfillmentCount = 2
        // call the adViewManager delegate method.
        adViewManager.currentCreative = testCreative
        adViewManager.creativeViewWasClicked(testCreative)
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testCreativeInterstitialDidClose () {
        let testCreative = setUpDelegateTests()

        // setup expectations
        adDidCloseExpectation = expectation(description: "Expected a delegate function adDidClose to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeInterstitialDidClose(testCreative)
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreativeClickthroughDidClose () {
        let testCreative = setUpDelegateTests()
        adClickthroughDidCloseExpectation = expectation(description: "Expected a delegate function adClickthroughDidClose to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeClickthroughDidClose(testCreative)

        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreativeMraidDidCollapse () {
        let testCreative = setUpDelegateTests()
        adDidCollapseExpectation = expectation(description: "Expected a delegate function adDidCollapse to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeMraidDidCollapse(testCreative)
        
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreativeMraidDidExpand () {
        let testCreative = setUpDelegateTests()
        adDidExpandExpectation = expectation(description: "Expected a delegate function adDidExpand to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeMraidDidExpand(testCreative)
        
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCreativeInterstitialDidLeaveApp () {
        let testCreative = setUpDelegateTests()
        adDidLeaveAppExpectation = expectation(description: "Expected a delegate function adDidLeaveApp to fire")
        
        // call the adViewManager delegate method.
        adViewManager.creativeInterstitialDidLeaveApp(testCreative)
        
        // wait for the delegate expectation to be fullfilled.
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testSetupCreativeNotMainThread() {
        logToFile = .init()
        
        let creative = PBMAbstractCreative(creativeModel:PBMCreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction())
        let thread = MockNSThread(mockIsMainThread: false)
        
        adViewManager.setupCreative(creative, withThread: thread)
        UtilitiesForTesting.checkLogContains("setupCreative must be called on the main thread")
    }
    
    //MARK: PBMAdViewManagerDelegate
    
    func viewControllerForModalPresentation() -> UIViewController? {
        fulfillOrFail(viewControllerForModalPresentationExpectation, "viewControllerForModalPresentationExpectation")
        return UIViewController()
    }
    
    func displayView() -> UIView {
        fulfillOrFail(displayViewExpectation, "displayViewExpectation")
        return UIView();
    }
    
    func interstitialDisplayProperties() -> PBMInterstitialDisplayProperties {
        fulfillOrFail(interstitialDisplayPropertiesExpectation, "interstitialDisplayPropertiesExpectation")
        return PBMInterstitialDisplayProperties()
    }
    
    func adLoaded(_ pbmAdDetails:PBMAdDetails) {
        fulfillOrFail(adLoadedExpectation, "adLoadedExpectation")
    }
    
    func failed(toLoad error:Error) {
        fulfillOrFail(failedToLoadExpectation, "failedToLoadExpectation")
        currentlyDisplaying = false
    }
    
    func adDidComplete() {
        fulfillOrFail(adDidCompleteExpectation, "adDidCompleteExpectation")
        currentlyDisplaying = false
    }
    
    func adDidDisplay() {
        fulfillOrFail(adDidDisplayExpectation, "adDidDisplayExpectation")
    }
    
    func adWasClicked() {
        fulfillOrFail(adWasClickedExpectation, "adWasClickedExpectation")
    }
    
    func adViewWasClicked() {
        fulfillOrFail(adViewWasClickedExpectation, "adWasClickedExpectation")
    }
    
    func adDidExpand() {
        fulfillOrFail(adDidExpandExpectation, "creativeMraidDidExpandExpecation")
    }
    
    func adDidCollapse() {
        fulfillOrFail(adDidCollapseExpectation, "adDidCollapseExpecation")
    }
    
    func adDidLeaveApp() {
        fulfillOrFail(adDidLeaveAppExpectation, "adDidLeaveAppExpectation")
    }
    
    func adClickthroughDidClose() {
        fulfillOrFail(adClickthroughDidCloseExpectation, "adClickthroughDidCloseExpectation")
    }

    func adDidClose() {
        fulfillOrFail(adDidCloseExpectation, "adDidCloseExpectation")
    }

    
    //MARK: Utility methods
    @discardableResult private func setUpDelegateTests () -> PBMHTMLCreative {
        // create an ad with one creative
        let model = PBMCreativeModel(adConfiguration:AdConfiguration())
        model.html = "<html>test html</html>"
        let testCreative = PBMHTMLCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction())
        testCreative.view = PBMWebView()
        return testCreative
    }
}
