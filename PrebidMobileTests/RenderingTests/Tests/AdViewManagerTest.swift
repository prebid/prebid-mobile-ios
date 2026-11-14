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
import AVFoundation

@_spi(PBMInternal) @testable import PrebidMobile

class AdViewManagerTest: XCTestCase, AdViewManagerDelegate {
    
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
    
    weak var videoWasMutedExpectation: XCTestExpectation?
    weak var videoWasUnmutedExpectation: XCTestExpectation?
    weak var videoDidStartExpectation: XCTestExpectation?
    weak var videoDidPauseExpectation: XCTestExpectation?
    weak var videoDidResumeExpectation: XCTestExpectation?

    var adViewManager:AdViewManagerImpl!
    var adLoadManager:AdLoadManagerBase!
    var videoCreative: VideoCreative?
    // Creatives started with a bare `AVPlayer()` never registered their KVO observers, so their
    // `VideoView.deinit` would throw on removal. Kept alive for the run, like `videoCreative`.
    private var startedCreatives: [VideoCreative] = []
    var testDisplayView: UIView!
    // Holds `testDisplayView` and presents interstitials, in a window on screen: the viewability tracker
    // reports an impression only for an ad that is on screen.
    var onScreenViewController: UIViewController!
    var adWindow: UIWindow!
    // Returned by `viewControllerForModalPresentation()` instead of `onScreenViewController` when set.
    var modalPresenter: UIViewController?
    // The creative's view when `adDidDisplay` fired: whether it was in a window, and its size.
    var creativeViewAtImpression: (isInWindow: Bool, bounds: CGRect)?
    var adLoadedHandler: (() -> Void)?
    
    var currentlyDisplaying = false
    var loadError:NSError?
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        super.setUp()
        
        adViewManager = AdViewManagerImpl(connection: PrebidServerConnection(), modalManagerDelegate: nil)
        
        adViewManager.adViewManagerDelegate = self
        onScreenViewController = UIViewController()
        adWindow = UtilitiesForTesting.showOnScreen(onScreenViewController)
        modalPresenter = nil
        creativeViewAtImpression = nil
        testDisplayView = UIView(frame: onScreenViewController.view.bounds)
        onScreenViewController.view.addSubview(testDisplayView)
        adLoadedHandler = nil
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
        testDisplayView = nil
        modalPresenter = nil
        adWindow.isHidden = true
        adWindow = nil
        onScreenViewController = nil
        adLoadedHandler = nil
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
        let adViewManager = AdViewManagerImpl(connection: PrebidServerConnection(), modalManagerDelegate: nil)
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
        
        let transaction = makeTransactionWithSizedHTMLCreative()
        adViewManager.handleExternalTransaction(transaction)
        
        XCTAssertIdentical(adViewManager.externalTransaction, transaction)
        waitForExpectations(timeout: 3, handler: nil)
        assertCreativeWasOnScreenAtImpression()
    }
    
    func testAdLoadedAfterDisplayViewContainsCreative() {
        nilExpectations()
        adLoadedExpectation = expectation(description: "adLoadedExpectation")
        displayViewExpectation = expectation(description: "displayViewExpectation")
        adDidDisplayExpectation = expectation(description: "adDidDisplayExpectation")
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        
        adLoadedHandler = { [weak self] in
            guard let self else {
                XCTFail("Expected test instance to be available")
                return
            }
            
            XCTAssertEqual(self.testDisplayView.subviews.count, 1)
        }
        
        adViewManager.handleExternalTransaction(makeTransactionWithSizedHTMLCreative())
        
        waitForExpectations(timeout: 3, handler: nil)
        assertCreativeWasOnScreenAtImpression()
    }
    
    func testShowWithoutAutoForInterstitial() throws {
        // The delegate returns a presenter that records the modal instead of asking UIKit to present it.
        // `ModalViewController` loads its view, and so its content view, in `init`, so the creative goes into the modal
        // without a real presentation. The modal is never on screen here, and the impression is not tested; that needs
        // a hosted test. An earlier version presented from the window's root view controller and waited for its
        // `presentedViewController` to become the modal; on a cold simulator that wait sometimes timed out.
        let presenter = MockPresentedViewController()
        modalPresenter = presenter

        // setup expectations; nil those that should not be called
        adLoadedExpectation = expectation(description: "Expected a delegate function adLoaded to fire")
        
        adViewManager.handleExternalTransaction(makeTransactionWithSizedHTMLCreative(isInterstitial: true))
        
        XCTAssertNotNil(adViewManager.externalTransaction)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        // setup expecations; nil those that won't be needed
        nilExpectations()
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        // One call to check isAbleToShowCurrentCreative and one
        // to showAsInterstitialFromRootViewController
        viewControllerForModalPresentationExpectation?.expectedFulfillmentCount = 2
        interstitialDisplayPropertiesExpectation = expectation(description: "Expected a delegate function interstitialDisplayProperties to fire")
        // `ModalManager` calls `present`, puts the creative in the modal and runs the creative's display in one block
        // on the main queue, so the whole block has run when the wait returns.
        presenter.expectationDidPresentViewController = expectation(description: "show() presented the modal")
        // adDidDisplayExpectation stays nil: the modal is not in a window, so an impression would be a bug.
        adViewManager.show()
        waitForExpectations(timeout: 3, handler: nil)
        presenter.expectationDidPresentViewController = nil

        let modal = try XCTUnwrap(presenter.presentVC as? ModalViewController, "show() presents a ModalViewController")
        let creative = try XCTUnwrap(adViewManager.currentCreative)
        let creativeView = try XCTUnwrap(creative.view)
        XCTAssertTrue(creativeView.isDescendant(of: modal.view), "The creative is attached to the modal")
        XCTAssertFalse(creativeView.bounds.isEmpty, "The creative has an area")
        XCTAssertIdentical(creative.viewControllerForPresentingModals, presenter,
                           "The creative ran its display with the presenter as root view controller")
        XCTAssertNotNil(creative.viewabilityTracker, "The creative's display started its viewability tracking")
    }
    
    // functions called by a creative
    func testCreativeCompleteWithOneCreative() {
        // setup expectations
        adLoadedExpectation = expectation(description: "adLoadedExpectation")
        displayViewExpectation = expectation(description: "displayViewExpectation")
        adDidDisplayExpectation = expectation(description: "adDidDisplayExpectation")
        viewControllerForModalPresentationExpectation = expectation(description: "Expected a viewControllerForModalPresentationExpectation delegate to fire")
        
        // create an ad with one creative
        adViewManager.handleExternalTransaction(makeTransactionWithSizedHTMLCreative())
        XCTAssertNotNil(adViewManager.externalTransaction)
        
        waitForExpectations(timeout: 3, handler: nil)
        assertCreativeWasOnScreenAtImpression()
        
        //Force a creativeDidComplete. Expect that the ad will not attempt to reload.
        adLoadedExpectation = expectation(description: "adLoadedExpectation")
        adLoadedExpectation?.isInverted = true
        
        failedToLoadExpectation = expectation(description: "failedToLoadExpectation")
        failedToLoadExpectation?.isInverted = true

        displayViewExpectation = expectation(description: "creativeReadyForImmediateDisplayExpectation")
        displayViewExpectation?.isInverted = true
        
        adDidCompleteExpectation = expectation(description: "adDidCompleteExpectation")

        guard let testCreative = adViewManager.externalTransaction?.creatives.first as? HTMLCreative else {
            XCTFail("Could not get HTMLCreative")
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
        
        adViewManager.handleExternalTransaction(makeTransactionWithSizedHTMLCreative())
        XCTAssertNotNil(adViewManager.externalTransaction)
        
        waitForExpectations(timeout: 3, handler: nil)
        assertCreativeWasOnScreenAtImpression()
        
        // setup expectations
        displayViewExpectation = expectation(description: "displayViewExpectation #2")
        
        guard let testCreative = adViewManager.externalTransaction?.creatives.first as? HTMLCreative else {
            XCTFail("Could not get HTMLCreative")
            return
        }
        adViewManager.creativeReadyToReimplant(_: testCreative)
        
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
        
        let creative = AbstractCreativeImpl(creativeModel:CreativeModel(), transaction:UtilitiesForTesting.createEmptyTransaction())
        let thread = MockNSThread(mockIsMainThread: false)
        
        adViewManager.setupCreative(creative, withThread: thread)
        UtilitiesForTesting.checkLogContains("setupCreative must be called on the main thread")
    }
        
    func testVideoCreativePlaybackEvents() {
        videoDidStartExpectation = expectation(description: "Expected a delegate function videoAdDidStart to fire")
        videoWasMutedExpectation = expectation(description: "Expected a delegate function videoAdWasMuted to fire")
        videoWasUnmutedExpectation = expectation(description: "Expected a delegate function videoAdWasUnmuted to fire")
        videoDidPauseExpectation = expectation(description: "Expected a delegate function videoAdDidPause to fire")
        videoDidResumeExpectation = expectation(description: "Expected a delegate function videoAdDidResume to fire")

        let model = CreativeModel(adConfiguration: AdConfiguration())
        videoCreative = VideoCreative(
            creativeModel: model,
            transaction: UtilitiesForTesting.createEmptyTransaction(),
            videoData: Data()
        )
        videoCreative?.videoView.avPlayer = AVPlayer()
        videoCreative?.creativeViewDelegate = adViewManager
        
        XCTAssertNotNil(videoCreative)
        XCTAssertNotNil(videoCreative?.videoView)
        
        adViewManager.currentCreative = videoCreative
        adViewManager.adViewManagerDelegate = self
 
        videoCreative?.videoView.startPlayback()
        adViewManager.pause()
        adViewManager.resume()
        adViewManager.mute()
        adViewManager.unmute()

        waitForExpectations(timeout: 0.1)
    }

    // A muted start is reported to the delegate; a sound-on start is not, since nothing was unmuted.
    // Any other mute or unmute event fails through `fulfillOrFail` with no expectation set.
    func testConfiguredMuteStateIsReportedWhenPlaybackStarts() {
        let mutedConfiguration = AdConfiguration()
        mutedConfiguration.videoControlsConfig.isMuted = true

        videoDidStartExpectation = expectation(description: "videoAdDidStart for the muted start")
        videoWasMutedExpectation = expectation(description: "videoAdWasMuted once for the muted start")
        startPlayback(with: mutedConfiguration)
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(videoCreative?.videoView.avPlayer.isMuted, true)

        videoWasMutedExpectation = nil
        videoDidStartExpectation = expectation(description: "videoAdDidStart for the sound-on start")
        startPlayback(with: AdConfiguration())
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(videoCreative?.videoView.avPlayer.isMuted, false)
    }

    private func startPlayback(with adConfiguration: AdConfiguration) {
        let model = CreativeModel(adConfiguration: adConfiguration)
        videoCreative = VideoCreative(
            creativeModel: model,
            transaction: UtilitiesForTesting.createEmptyTransaction(),
            videoData: Data()
        )
        videoCreative?.videoView.avPlayer = AVPlayer()
        videoCreative?.creativeViewDelegate = adViewManager
        adViewManager.currentCreative = videoCreative
        adViewManager.adViewManagerDelegate = self
        videoCreative.map { startedCreatives.append($0) }

        videoCreative?.videoView.startPlayback()
    }
    
    // An HTML creative whose web view has a banner size. The tracker's visibility check accepts a view with no
    // area, so the tests check the size themselves (`assertCreativeWasOnScreenAtImpression`).
    private func makeTransactionWithSizedHTMLCreative(isInterstitial: Bool = false) -> Transaction {
        let transaction = UtilitiesForTesting.createTransactionWithHTMLCreative(withView: true, isInterstitial: isInterstitial)
        transaction.creatives.first?.view?.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        return transaction
    }

    private func assertCreativeWasOnScreenAtImpression(file: StaticString = #filePath, line: UInt = #line) {
        guard let state = creativeViewAtImpression else {
            return XCTFail("adDidDisplay did not record the creative's view", file: file, line: line)
        }
        XCTAssertTrue(state.isInWindow, "The creative was on screen at the impression", file: file, line: line)
        XCTAssertFalse(state.bounds.isEmpty, "The creative had an area at the impression", file: file, line: line)
    }

    //MARK: AdViewManagerDelegate
    
    func viewControllerForModalPresentation() -> UIViewController? {
        fulfillOrFail(viewControllerForModalPresentationExpectation, "viewControllerForModalPresentationExpectation")
        return modalPresenter ?? onScreenViewController
    }
    
    var displayView: UIView {
        fulfillOrFail(displayViewExpectation, "displayViewExpectation")
        return testDisplayView
    }
    
    var interstitialDisplayProperties: InterstitialDisplayProperties {
        fulfillOrFail(interstitialDisplayPropertiesExpectation, "interstitialDisplayPropertiesExpectation")
        return InterstitialDisplayProperties()
    }
    
    func adLoaded(_ pbmAdDetails: AdDetails) {
        adLoadedHandler?()
        fulfillOrFail(adLoadedExpectation, "adLoadedExpectation")
    }
    
    func failedToLoad(_ error:Error) {
        fulfillOrFail(failedToLoadExpectation, "failedToLoadExpectation")
        currentlyDisplaying = false
    }
    
    func adDidComplete() {
        fulfillOrFail(adDidCompleteExpectation, "adDidCompleteExpectation")
        currentlyDisplaying = false
    }
    
    func adDidDisplay() {
        if let creativeView = adViewManager?.currentCreative?.view {
            creativeViewAtImpression = (creativeView.window != nil, creativeView.bounds)
        }
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
    
    func videoAdWasMuted() {
        fulfillOrFail(videoWasMutedExpectation, "videoWasMutedExpectation")
    }
    
    func videoAdWasUnmuted() {
        fulfillOrFail(videoWasUnmutedExpectation, "videoWasUnmutedExpectation")
    }
    
    func videoAdDidStart() {
        fulfillOrFail(videoDidStartExpectation, "videoDidStartExpectation")
    }
    
    func videoAdDidPause() {
        fulfillOrFail(videoDidPauseExpectation, "videoDidPauseExpectation")
    }
    
    func videoAdDidResume() {
        fulfillOrFail(videoDidResumeExpectation, "videoDidResumeExpectation")
    }
    
    //MARK: Utility methods
    @discardableResult private func setUpDelegateTests () -> HTMLCreative {
        // create an ad with one creative
        let model = CreativeModel(adConfiguration:AdConfiguration())
        model.html = "<html>test html</html>"
        let testCreative = HTMLCreative(creativeModel:model, transaction:UtilitiesForTesting.createEmptyTransaction())
        testCreative.view = WebView()
        return testCreative
    }
}
