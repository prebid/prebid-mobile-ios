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

@_spi(PBMInternal) @testable import PrebidMobile

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

// Returns a bid response whose winning bid is of the given format (banner or video).
private class MockBannerViewWithBidFormat: BannerView {
    var mockBidFormat = "banner"
    
    override var lastBidResponse: BidResponse? {
        let rawBid = RawWinningBidFabricator.makeRawWinningBid(price: 0.85, bidder: "some bidder", cacheID: "some-cache-id")
        rawBid.ext?.prebid?.type = mockBidFormat
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
    
    func testAdFormats() {
        let primarySize = CGSize(width: 300, height: 250)
        let bannerView = BannerView(frame: CGRect(origin: .zero, size: primarySize), configID: "auid", adSize: primarySize)
        let adUnitConfig = bannerView.adUnitConfig
        
        // Default: display banner only
        XCTAssertEqual(bannerView.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Single format
        bannerView.adFormats = [.video]
        XCTAssertEqual(bannerView.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
        
        // Multiformat
        bannerView.adFormats = [.banner, .video]
        XCTAssertEqual(bannerView.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    @available(*, deprecated, message: "Covers the deprecated `adFormat` property.")
    func testDeprecatedAdFormatIsBackedByAdFormats() {
        let primarySize = CGSize(width: 300, height: 250)
        let bannerView = BannerView(frame: CGRect(origin: .zero, size: primarySize), configID: "auid", adSize: primarySize)
        
        XCTAssertEqual(bannerView.adFormat, .banner)
        
        // Legacy setter replaces the whole set
        bannerView.adFormat = .video
        XCTAssertEqual(bannerView.adFormat, .video)
        XCTAssertEqual(bannerView.adFormats, [.video])
        XCTAssertEqual(bannerView.adUnitConfig.adFormats, [.video])
        
        // New setter is visible through the legacy getter
        bannerView.adFormats = [.banner]
        XCTAssertEqual(bannerView.adFormat, .banner)
        
        // Legacy getter returns a member of a multiformat set
        bannerView.adFormats = [.banner, .video]
        XCTAssertTrue(bannerView.adFormats.contains(bannerView.adFormat))
    }
    
    func testAdFormatsRejectsEmptySet() {
        let primarySize = CGSize(width: 300, height: 250)
        let bannerView = BannerView(frame: CGRect(origin: .zero, size: primarySize), configID: "auid", adSize: primarySize)
        let adUnitConfig = bannerView.adUnitConfig
        
        bannerView.adFormats = [.banner, .video]
        
        bannerView.adFormats = []
        
        XCTAssertEqual(bannerView.adFormats, [.banner, .video], "Empty set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    func testAdFormatsRejectsUnsupportedFormats() {
        let primarySize = CGSize(width: 300, height: 250)
        let bannerView = BannerView(frame: CGRect(origin: .zero, size: primarySize), configID: "auid", adSize: primarySize)
        let adUnitConfig = bannerView.adUnitConfig
        
        // Unsupported only
        bannerView.adFormats = [.native]
        XCTAssertEqual(bannerView.adFormats, [.banner], "Native-only set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Mixed supported + unsupported must be rejected as a whole
        bannerView.adFormats = [.banner, .video, .native]
        XCTAssertEqual(bannerView.adFormats, [.banner], "Set containing native must be ignored entirely")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // A valid set is still accepted afterwards
        bannerView.adFormats = [.banner, .video]
        XCTAssertEqual(bannerView.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    @available(*, deprecated, message: "Covers the deprecated `adFormat` property.")
    func testDeprecatedAdFormatRejectsUnsupportedFormat() {
        let primarySize = CGSize(width: 300, height: 250)
        let bannerView = BannerView(frame: CGRect(origin: .zero, size: primarySize), configID: "auid", adSize: primarySize)
        
        bannerView.adFormat = .video
        bannerView.adFormat = .native
        
        XCTAssertEqual(bannerView.adFormat, .video, "Legacy setter must go through the same validation")
        XCTAssertEqual(bannerView.adFormats, [.video])
        XCTAssertEqual(bannerView.adUnitConfig.adFormats, [.video])
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

    // Regression: `AdUnitConfig` is shared across refreshes of a multiformat
    // banner, so `isBuiltInVideo` must be derived from the current bid on every
    // load rather than latched to `true` once a video creative has won.
    func testIsBuiltInVideoTracksWinningBidFormatAcrossRefreshes() {
        let size = CGSize(width: 300, height: 250)
        let frame = CGRect(origin: .zero, size: size)
        let config = AdUnitConfig(configId: "configID", size: size)
        config.adFormats = [.banner, .video]
        
        XCTAssertFalse(config.adConfiguration.isBuiltInVideo)
        
        // Auction 1: video wins
        let videoView = DisplayView(frame: frame, bid: makeBid(type: "video"), adConfiguration: config)
        videoView.loadAd()
        XCTAssertEqual(config.adConfiguration.winningBidAdFormat, .video)
        XCTAssertTrue(config.adConfiguration.isBuiltInVideo)
        
        // Auction 2 (refresh, same config): HTML banner wins
        let bannerView = DisplayView(frame: frame, bid: makeBid(type: "banner"), adConfiguration: config)
        bannerView.loadAd()
        XCTAssertEqual(config.adConfiguration.winningBidAdFormat, .banner)
        XCTAssertFalse(config.adConfiguration.isBuiltInVideo,
                       "isBuiltInVideo must be cleared when a non-video creative wins on refresh")
        
        // Auction 3: video wins again
        let videoView2 = DisplayView(frame: frame, bid: makeBid(type: "video"), adConfiguration: config)
        videoView2.loadAd()
        XCTAssertTrue(config.adConfiguration.isBuiltInVideo)
    }
    
    // MARK: - Auto-refresh vs. video creatives
    
    // Regression: the primary ad server can win over a Prebid video bid (no matching line item,
    // app event timeout). `lastBidResponse` still holds the losing video bid, so the timer must
    // not be cancelled based on it - the GAM creative on screen must keep refreshing.
    func testAdServerWinOverVideoBidKeepsAutoRefresh() {
        let bannerView = makeBannerView(bidFormat: "video")
        let window = makeVisible(bannerView)
        defer { window.isHidden = true }
        armRefreshTimer(bannerView)
        
        let adServerCreative = UIView(frame: bannerView.bounds)
        bannerView.bannerAdLoader(BannerAdLoader(delegate: bannerView), loadedAdView: adServerCreative, adSize: bannerView.bounds.size)
        
        XCTAssertNotNil(bannerView.autoRefreshManager?.delayedBlock, "Loading an ad must never cancel the refresh timer")
        waitForDeploy(of: adServerCreative, in: bannerView)
        XCTAssertFalse(bannerView.isVideoPlaying)
        XCTAssertTrue(bannerView.mayRefreshNow, "The ad server creative on screen must keep refreshing")
    }
    
    func testBannerWinningBidKeepsAutoRefresh() {
        let bannerView = makeBannerView(bidFormat: "banner")
        armRefreshTimer(bannerView)
        
        bannerView.bannerAdLoader(BannerAdLoader(delegate: bannerView), loadedAdView: UIView(frame: bannerView.bounds), adSize: bannerView.bounds.size)
        
        XCTAssertNotNil(bannerView.autoRefreshManager?.delayedBlock, "An HTML banner keeps the configured auto-refresh")
    }
    
    // The gate is driven by the creative's own playback callbacks, evaluated on every tick,
    // so it self-recovers once playback ends and protects a replay ("watch again") too.
    func testRefreshIsSkippedWhileVideoIsPlaying() {
        let bannerView = makeBannerView(bidFormat: "video")
        let window = makeVisible(bannerView)
        defer { window.isHidden = true }
        
        let videoCreative = DisplayView(frame: bannerView.bounds, bid: makeBid(type: "video"), adConfiguration: bannerView.adUnitConfig)
        bannerView.deployView(videoCreative)
        waitForDeploy(of: videoCreative, in: bannerView)
        XCTAssertTrue(bannerView.mayRefreshNow, "Sanity: nothing is playing yet")
        
        videoCreative.videoAdDidStart()
        XCTAssertTrue(bannerView.isVideoPlaying)
        XCTAssertFalse(bannerView.mayRefreshNow, "A video creative in flight must not be torn down by auto-refresh")
        
        videoCreative.videoAdDidFinish()
        XCTAssertFalse(bannerView.isVideoPlaying)
        XCTAssertTrue(bannerView.mayRefreshNow, "Once the video has finished the next tick must proceed")
        
        // Watch again
        videoCreative.videoAdDidStart()
        XCTAssertFalse(bannerView.mayRefreshNow, "A replay is protected like the first playback")
    }
    
    // HTML creatives and plugin-rendered views never report playback, so they keep refreshing.
    func testCreativeWithoutPlaybackEventsDoesNotBlockRefresh() {
        let bannerView = makeBannerView(bidFormat: "video")
        let window = makeVisible(bannerView)
        defer { window.isHidden = true }
        
        let pluginCreative = MockDisplayView(frame: bannerView.bounds)
        bannerView.deployView(pluginCreative)
        waitForDeploy(of: pluginCreative, in: bannerView)
        
        XCTAssertFalse(bannerView.isVideoPlaying)
        XCTAssertTrue(bannerView.mayRefreshNow)
    }
    
    private func makeVisible(_ bannerView: BannerView) -> UIWindow {
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 480)))
        window.addSubview(bannerView)
        window.isHidden = false
        return window
    }
    
    // `deployView` installs the view on the main queue asynchronously.
    private func waitForDeploy(of view: UIView, in bannerView: BannerView) {
        let predicate = NSPredicate { obj, _ in
            (obj as? BannerView)?.deployedView === view
        }
        wait(for: [expectation(for: predicate, evaluatedWith: bannerView, handler: nil)], timeout: 3.0)
    }
    
    private func makeBannerView(bidFormat: String) -> MockBannerViewWithBidFormat {
        let size = CGSize(width: 300, height: 250)
        let bannerView = MockBannerViewWithBidFormat(frame: CGRect(origin: .zero, size: size),
                                                     configID: "configID",
                                                     adSize: size,
                                                     eventHandler: BannerEventHandlerStandalone())
        bannerView.mockBidFormat = bidFormat
        return bannerView
    }
    
    private func armRefreshTimer(_ bannerView: BannerView) {
        guard let controller = bannerView.adLoadFlowController else {
            return XCTFail("BannerView must own an AdLoadFlowController")
        }
        bannerView.adLoadFlowControllerWillRequestPrimaryAd(controller)
        XCTAssertNotNil(bannerView.autoRefreshManager?.delayedBlock, "Sanity: the timer is armed when the primary ad is requested")
    }
    
    private func makeBid(type: String) -> Bid {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "", impid: "", price: 0.1)
        rawBid.ext = .init()
        rawBid.ext?.prebid = .init()
        rawBid.ext?.prebid?.type = type
        return Bid(bid: rawBid)
    }
    
    func testBannerViewReportsExpirationAndKeepsDeployedViewWhenRefreshStopped() {
        let bannerView = MockBannerView(
            frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 50)),
            configID: "auid",
            adSize: CGSize(width: 320, height: 50),
            eventHandler: BannerEventHandlerStandalone()
        )
        bannerView.isRefreshStopped = true

        assertExpirationKeepsDeployedView(of: bannerView)
    }

    func testBannerViewReportsExpirationAndKeepsDeployedViewWhenRefreshIsDisabled() {
        let bannerView = MockBannerView(
            frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 50)),
            configID: "auid",
            adSize: CGSize(width: 320, height: 50),
            eventHandler: BannerEventHandlerStandalone()
        )
        // Outstream video is not refreshable: the interval is forced to 0.
        bannerView.adUnitConfig.adConfiguration.winningBidAdFormat = .video
        bannerView.refreshInterval = 0
        XCTAssertEqual(bannerView.refreshInterval, 0)

        assertExpirationKeepsDeployedView(of: bannerView)
    }

    private func assertExpirationKeepsDeployedView(
        of bannerView: MockBannerView,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let adLoadFlowController = TestAdLoadFlowController(adUnitConfig: bannerView.adUnitConfig)
        bannerView.adLoadFlowController = adLoadFlowController
        let autoRefreshManager = AutoRefreshManager(
            prefetchTime: PrebidConstants.AD_PREFETCH_TIME,
            lockingQueue: nil,
            lockProvider: nil,
            refreshDelayBlock: { 30 },
            mayRefreshNowBlock: { true },
            refreshBlock: {}
        )
        autoRefreshManager.setupRefreshTimer()
        XCTAssertNotNil(autoRefreshManager.delayedBlock, file: file, line: line)
        bannerView.autoRefreshManager = autoRefreshManager
        let deployedView = UIView()
        bannerView.deployView(deployedView)
        let expirationExpectation = expectation(description: "Banner expiration callback")
        let delegate = TestBannerDelegate(expireExp: expirationExpectation)
        delegate.onExpire = { bannerView in
            XCTAssertTrue(bannerView.deployedView === deployedView, file: file, line: line)
        }
        bannerView.delegate = delegate

        let adLoader = BannerAdLoader(delegate: bannerView)
        bannerView.bannerAdLoaderDidExpire(adLoader)

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(bannerView.deployedView === deployedView, file: file, line: line)
        XCTAssertTrue(deployedView.superview === bannerView, file: file, line: line)
        XCTAssertNotNil(autoRefreshManager.delayedBlock, file: file, line: line)
        XCTAssertEqual(adLoadFlowController.refreshCallCount, 0, file: file, line: line)
        XCTAssertEqual(delegate.failCallCount, 0, file: file, line: line)

        autoRefreshManager.cancelRefreshTimer()
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
            XCTAssertNil(autoRefreshManager.delayedBlock)
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
