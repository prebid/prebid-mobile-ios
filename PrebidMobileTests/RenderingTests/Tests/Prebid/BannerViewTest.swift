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

class MockBannerView: BannerView {
    override var lastBidResponse: BidResponse? {
        return WinningBidResponseFabricator.makeWinningBidResponse(bidPrice: 0.85)
    }
}

// Returns a bid response whose winning bid references a named plugin renderer.
private class MockBannerViewWithCustomRenderer: BannerView {
    var mockRendererName: String = ""
    var mockRendererVersion: String = ""

    override var lastBidResponse: BidResponse? {
        let rawBid = RawSampleCustomRendererBidFabricator.makeSampleCustomRendererBid(
            rendererName: mockRendererName,
            rendererVersion: mockRendererVersion
        )
        let rawResponse = ORTBBidResponse<ORTBBidResponseExt, [String: Any], ORTBBidExt>(requestID: "")
        rawResponse.seatbid = [.init(bid: [rawBid])]
        return BidResponse(jsonDictionary: rawResponse.jsonDictionary)
    }
}

class BannerViewTest: XCTestCase {
    override func tearDown() {
        Prebid.reset()
        
        super.tearDown()
    }
    
    func testConfigSetup() {
        let testID = "auid"
        
        let primarySize = CGSize(width: 320, height: 50)
        
        let bannerView = MockBannerView(frame: CGRect(origin: .zero, size: primarySize), configID: testID, adSize: primarySize, eventHandler: BannerEventHandlerStandalone())
        let adUnitConfig = bannerView.adUnitConfig
        
        XCTAssertEqual(adUnitConfig.configId, testID)
        XCTAssertEqual(adUnitConfig.adSize, primarySize)
        
        let moreSizes = [
            CGSize(width: 300, height: 250),
            CGSize(width: 728, height: 90),
        ]
        
        bannerView.additionalSizes = moreSizes
        
        XCTAssertEqual(adUnitConfig.additionalSizes?.count, moreSizes.count)
        for i in 0..<moreSizes.count {
            XCTAssertEqual(adUnitConfig.additionalSizes?[i], moreSizes[i])
        }
        
        let refreshInterval: TimeInterval = 40;
        
        bannerView.refreshInterval = refreshInterval
        XCTAssertEqual(adUnitConfig.refreshInterval, refreshInterval)
    }
    
    func testAccountErrorPropagation() {
        let testID = "auid"
        
        Prebid.shared.prebidServerAccountId = ""
        let primarySize = CGSize(width: 320, height: 50)
        
        let bannerView = MockBannerView(frame: CGRect(origin: .zero, size: primarySize), configID: testID, adSize: primarySize, eventHandler: BannerEventHandlerStandalone())
        let exp = expectation(description: "loading callback called")
        let delegate = TestBannerDelegate(exp: exp)
        bannerView.delegate = delegate
        
        bannerView.loadAd()
        
        waitForExpectations(timeout: 3)
    }
    
    func testVideoPlaybackDelegateEvents() throws {
        let testID = "auid"
        
        let primarySize = CGSize(width: 320, height: 50)
        let frame = CGRect(origin: .zero, size: primarySize)
        
        let bannerView = MockBannerView(frame: frame, configID: testID, adSize: primarySize, eventHandler: BannerEventHandlerStandalone())
        let delegate = TestBannerViewVideoPlaybackDelegate()
        bannerView.videoPlaybackDelegate = delegate
        
        let config = AdUnitConfig(configId: testID, size: primarySize)
        let bid = Bid(bid: ORTBBid(bidID: "", impid: "", price: 0.1))
        let displayView = DisplayView(frame: frame, bid: bid, adConfiguration: config)
        bannerView.deployView(displayView)
        
        // The dsiplay view delegate is set asynchronously, so we need to wait for that
        let predicate = NSPredicate { obj, _ in
            (obj as? DisplayView)?.videoPlaybackDelegate != nil
        }
        let delegateExpectation = expectation(for: predicate, evaluatedWith: displayView, handler: nil)
        wait(for: [delegateExpectation], timeout: 3.0)
        
        // Simulate video playback events
        displayView.videoAdDidPause()
        displayView.videoAdDidResume()
        displayView.videoAdWasMuted()
        displayView.videoAdWasUnmuted()
        
        XCTAssertTrue(delegate.events.contains(.pause))
        XCTAssertTrue(delegate.events.contains(.resume))
        XCTAssertTrue(delegate.events.contains(.mute))
        XCTAssertTrue(delegate.events.contains(.unmute))
        XCTAssertFalse(delegate.events.contains(.complete))
        
        displayView.videoAdDidFinish()
        XCTAssertTrue(delegate.events.contains(.complete))
    }
    
    @objc private class TestBannerDelegate: NSObject, BannerViewDelegate {
        let exp: XCTestExpectation
        
        init(exp: XCTestExpectation) {
            self.exp = exp
        }
        
        func bannerViewPresentationController() -> UIViewController? {
            return nil
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWith error: Error) {
            XCTAssertEqual(error as NSError?, PBMError.prebidInvalidAccountId() as NSError?)
            XCTAssertNotNil(bannerView.lastBidResponse)
            exp.fulfill()
        }
        
        func bannerView(_ bannerView: BannerView, didReceiveAdWithAdSize adSize: CGSize) {
            XCTFail("Ad unexpectedly loaded successfully...")
            exp.fulfill()
        }
    }
    
    @objc private class TestBannerViewVideoPlaybackDelegate: NSObject, BannerViewVideoPlaybackDelegate {
        
        struct BannerViewVideoPlaybackDelegateEvents: OptionSet {
            let rawValue: Int8
            
            static let pause = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 0)
            static let resume = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 1)
            static let mute = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 2)
            static let unmute = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 3)
            static let complete = BannerViewVideoPlaybackDelegateEvents(rawValue: 1 << 4)
        }
        
        var events: BannerViewVideoPlaybackDelegateEvents = []
        
        func videoPlaybackDidPause(_ banner: PrebidMobile.BannerView) {
            events.insert(.pause)
        }
        
        func videoPlaybackDidResume(_ banner: PrebidMobile.BannerView) {
            events.insert(.resume)
        }
        
        func videoPlaybackWasMuted(_ banner: PrebidMobile.BannerView) {
            events.insert(.mute)
        }
        
        func videoPlaybackWasUnmuted(_ banner: PrebidMobile.BannerView) {
            events.insert(.unmute)
        }
        
        func videoPlaybackDidComplete(_ banner: PrebidMobile.BannerView) {
            events.insert(.complete)
        }
    }
}

class BannerViewDidInjectViewTests: XCTestCase {

    private let pluginName = "SampleRenderer"
    private let pluginVersion = "1.0.0"
    private let adSize = CGSize(width: 320, height: 50)

    override func setUp() {
        super.setUp()
        PrebidMobilePluginRegister.shared.unregisterAllPlugins()
    }

    override func tearDown() {
        PrebidMobilePluginRegister.shared.unregisterAllPlugins()
        Prebid.reset()
        super.tearDown()
    }

    // MARK: - Happy path

    func testDidInjectViewIsCalledOnMatchingPlugin() {
        let renderer = makeMockRenderer()
        PrebidMobilePluginRegister.shared.registerPlugin(renderer)

        let bannerView = makeRendererBannerView()
        bannerView.deployView(UIView())

        flushMainQueue()

        XCTAssertEqual(renderer.didInjectViewCallCount, 1)
    }

    func testDidInjectViewReceivesCorrectViewAndBannerView() {
        let renderer = makeMockRenderer()
        PrebidMobilePluginRegister.shared.registerPlugin(renderer)

        let bannerView = makeRendererBannerView()
        let injectedView = UIView()
        bannerView.deployView(injectedView)

        flushMainQueue()

        XCTAssertIdentical(renderer.capturedInjectedView, injectedView)
        XCTAssertIdentical(renderer.capturedBannerView, bannerView)
    }

    func testDidInjectViewCalledAgainOnSubsequentDeploy() {
        let renderer = makeMockRenderer()
        PrebidMobilePluginRegister.shared.registerPlugin(renderer)

        let bannerView = makeRendererBannerView()
        bannerView.deployView(UIView())
        flushMainQueue()
        bannerView.deployView(UIView())
        flushMainQueue()

        XCTAssertEqual(renderer.didInjectViewCallCount, 2)
    }

    // MARK: - No-op cases

    func testDidInjectViewNotCalledWhenBidResponseIsNil() {
        let renderer = makeMockRenderer()
        PrebidMobilePluginRegister.shared.registerPlugin(renderer)

        // Plain BannerView — lastBidResponse is nil because no ad has loaded.
        let bannerView = BannerView(
            frame: CGRect(origin: .zero, size: adSize),
            configID: "test-id",
            adSize: adSize
        )
        bannerView.deployView(UIView())

        flushMainQueue()

        XCTAssertEqual(renderer.didInjectViewCallCount, 0)
    }

    // MARK: - Helpers

    private func makeMockRenderer() -> MockPrebidMobilePluginRenderer {
        MockPrebidMobilePluginRenderer(name: pluginName, version: pluginVersion)
    }

    private func makeRendererBannerView() -> MockBannerViewWithCustomRenderer {
        let bannerView = MockBannerViewWithCustomRenderer(
            frame: CGRect(origin: .zero, size: adSize),
            configID: "test-id",
            adSize: adSize,
            eventHandler: BannerEventHandlerStandalone()
        )
        bannerView.mockRendererName = pluginName
        bannerView.mockRendererVersion = pluginVersion
        return bannerView
    }

    // Processes all pending main-queue work queued before this call.
    private func flushMainQueue() {
        let exp = expectation(description: "main queue flush")
        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 1.0)
    }
}
