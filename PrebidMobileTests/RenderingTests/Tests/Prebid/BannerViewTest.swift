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
    
    func testBannerViewReportsExpirationAndRemovesDeployedViewWithoutFailureWhenRefreshStopped() {
        let bannerView = MockBannerView(
            frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 50)),
            configID: "auid",
            adSize: CGSize(width: 320, height: 50),
            eventHandler: BannerEventHandlerStandalone()
        )
        let expirationExpectation = expectation(description: "Banner expiration callback")
        let delegate = TestBannerDelegate(expireExp: expirationExpectation)
        delegate.onExpire = { bannerView in
            XCTAssertNil(bannerView.deployedView)
        }
        bannerView.delegate = delegate
        let deployedView = UIView()
        bannerView.deployView(deployedView)
        bannerView.isRefreshStopped = true
        let autoRefreshManager = AutoRefreshManager(
            prefetchTime: PrebidConstants.AD_PREFETCH_TIME,
            lockingQueue: nil,
            lockProvider: nil,
            refreshDelayBlock: { 30 },
            mayRefreshNowBlock: { true },
            refreshBlock: {
                XCTFail("Expired banner should cancel refresh instead of refreshing when refresh is stopped")
            }
        )
        autoRefreshManager.setupRefreshTimer()
        XCTAssertNotNil(autoRefreshManager.delayedBlock)
        bannerView.autoRefreshManager = autoRefreshManager
        
        let adLoader = BannerAdLoader(delegate: bannerView)
        bannerView.bannerAdLoaderDidExpire(adLoader)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(bannerView.deployedView)
        XCTAssertEqual(delegate.failCallCount, 0)
        XCTAssertNil(autoRefreshManager.delayedBlock)
    }
    
    func testBannerViewReportsExpirationAndRemovesDeployedViewWithoutFailureWhenRefreshIsConfigured() {
        let bannerView = MockBannerView(
            frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 50)),
            configID: "auid",
            adSize: CGSize(width: 320, height: 50),
            eventHandler: BannerEventHandlerStandalone()
        )
        bannerView.refreshInterval = 30
        let adLoadFlowController = TestAdLoadFlowController(adUnitConfig: bannerView.adUnitConfig)
        let autoRefreshManager = AutoRefreshManager(
            prefetchTime: PrebidConstants.AD_PREFETCH_TIME,
            lockingQueue: nil,
            lockProvider: nil,
            refreshDelayBlock: { 30 },
            mayRefreshNowBlock: { true },
            refreshBlock: {}
        )
        autoRefreshManager.setupRefreshTimer()
        XCTAssertNotNil(autoRefreshManager.delayedBlock)
        bannerView.autoRefreshManager = autoRefreshManager
        let refreshExpectation = expectation(description: "Banner expiration refreshes ad load flow")
        adLoadFlowController.refreshHandler = {
            XCTAssertNil(autoRefreshManager.delayedBlock)
            refreshExpectation.fulfill()
        }
        bannerView.adLoadFlowController = adLoadFlowController
        let expirationExpectation = expectation(description: "Banner expiration callback")
        let delegate = TestBannerDelegate(expireExp: expirationExpectation)
        delegate.onExpire = { bannerView in
            XCTAssertNil(bannerView.deployedView)
        }
        bannerView.delegate = delegate
        let deployedView = UIView()
        bannerView.deployView(deployedView)
        
        let adLoader = BannerAdLoader(delegate: bannerView)
        bannerView.bannerAdLoaderDidExpire(adLoader)
        
        waitForExpectations(timeout: 1.0)
        XCTAssertNil(bannerView.deployedView)
        XCTAssertEqual(delegate.failCallCount, 0)
        XCTAssertEqual(adLoadFlowController.refreshCallCount, 1)
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
