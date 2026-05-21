/*   Copyright 2018-2025 Prebid.org, Inc.

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

// MARK: - Tests

class PluginRendererFactoryTest: XCTestCase {

    let pluginRegister = PrebidMobilePluginRegister.shared

    let loadingDelegate = StubDisplayViewLoadingDelegate()
    let interactionDelegate = StubDisplayViewInteractionDelegate()
    let interstitialLoadingDelegate = StubInterstitialLoadingDelegate()
    let interstitialInteractionDelegate = StubInterstitialInteractionDelegate()

    override func setUp() {
        super.setUp()
        pluginRegister.unregisterAllPlugins()
    }

    override func tearDown() {
        pluginRegister.unregisterAllPlugins()
        super.tearDown()
    }

    // MARK: - Banner Tests

    func testCreateBannerView_WithDefaultRenderer_ReturnsDisplayView() {
        // No custom renderer registered — should use PrebidRenderer (SDK default)
        let bid = makeBid()
        let frame = CGRect(origin: .zero, size: bid.size)

        let view = createBannerView(
            with: frame,
            bid: bid,
            configId: "test-config",
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        XCTAssertNotNil(view)
        XCTAssertTrue(view is DisplayView)
    }

    func testCreateBannerView_WithCustomRenderer_UsesCustomRenderer() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockView = MockDisplayView()
        mockRenderer.bannerViewToReturn = mockView

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")
        let frame = CGRect(origin: .zero, size: bid.size)

        let view = createBannerView(
            with: frame,
            bid: bid,
            configId: "test-config",
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        XCTAssertTrue(mockRenderer.createBannerViewCalled)
        XCTAssertTrue(view === mockView)
    }

    func testCreateBannerView_CustomRendererReturnsNil_FallsBackToSDKRenderer() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        mockRenderer.bannerViewToReturn = nil  // returns nil

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")
        let frame = CGRect(origin: .zero, size: bid.size)

        let view = createBannerView(
            with: frame,
            bid: bid,
            configId: "test-config",
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        XCTAssertTrue(mockRenderer.createBannerViewCalled)
        // Should fall back to SDK renderer (DisplayView)
        XCTAssertNotNil(view)
        XCTAssertTrue(view is DisplayView)
    }

    func testCreateBannerView_RendererVersionMismatch_FallsBackToSDKRenderer() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockView = MockDisplayView()
        mockRenderer.bannerViewToReturn = mockView

        pluginRegister.registerPlugin(mockRenderer)

        // Bid requests version "3.0" but registered renderer is "2.0"
        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "3.0")
        let frame = CGRect(origin: .zero, size: bid.size)

        let view = createBannerView(
            with: frame,
            bid: bid,
            configId: "test-config",
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        // Version mismatch means PrebidMobilePluginRegister returns sdkRenderer
        XCTAssertFalse(mockRenderer.createBannerViewCalled)
        XCTAssertNotNil(view)
        XCTAssertTrue(view is DisplayView)
    }

    func testCreateBannerView_PassesCorrectAdConfiguration() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockView = MockDisplayView()
        mockRenderer.bannerViewToReturn = mockView

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0", width: 728, height: 90)
        let frame = CGRect(origin: .zero, size: bid.size)

        let _ = createBannerView(
            with: frame,
            bid: bid,
            configId: "my-config-id",
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        XCTAssertEqual(mockRenderer.lastBannerAdConfiguration?.configId, "my-config-id")
    }

    func testCreateBannerView_WithPreparedAdConfiguration_PassesSameConfiguration() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockView = MockDisplayView()
        mockRenderer.bannerViewToReturn = mockView

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0", width: 300, height: 250)
        let frame = CGRect(origin: .zero, size: bid.size)
        let preparedSize = CGSize(width: 1, height: 1)
        let adConfiguration = AdUnitConfig(configId: "prepared-config", size: preparedSize)

        let _ = createBannerView(
            with: frame,
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        XCTAssertTrue(mockRenderer.lastBannerAdConfiguration === adConfiguration)
        XCTAssertEqual(mockRenderer.lastBannerAdConfiguration?.configId, "prepared-config")
        XCTAssertEqual(mockRenderer.lastBannerAdConfiguration?.adConfiguration.size, preparedSize)
    }

    // MARK: - Interstitial Tests

    func testCreateInterstitialController_WithDefaultRenderer_ReturnsInterstitialController() {
        let bid = makeBid()

        let controller = createInterstitialController(
            bid: bid,
            configId: "test-config",
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertNotNil(controller)
        XCTAssertTrue(controller is InterstitialController)
    }

    func testCreateInterstitialController_WithCustomRenderer_UsesCustomRenderer() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")

        let controller = createInterstitialController(
            bid: bid,
            configId: "test-config",
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertTrue(mockRenderer.createInterstitialControllerCalled)
        XCTAssertTrue(controller === mockController)
    }

    func testCreateInterstitialController_CustomRendererReturnsNil_FallsBackToSDKRenderer() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        mockRenderer.interstitialControllerToReturn = nil

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")

        let controller = createInterstitialController(
            bid: bid,
            configId: "test-config",
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertTrue(mockRenderer.createInterstitialControllerCalled)
        XCTAssertNotNil(controller)
        XCTAssertTrue(controller is InterstitialController)
    }

    func testCreateInterstitialController_SetsIsInterstitialAd() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")

        let _ = createInterstitialController(
            bid: bid,
            configId: "test-config",
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertTrue(mockRenderer.lastInterstitialAdConfiguration?.adConfiguration.isInterstitialAd == true)
    }

    func testCreateInterstitialController_WithPreparedAdConfiguration_PassesSameConfiguration() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")
        let adConfiguration = AdUnitConfig(configId: "prepared-config")
        adConfiguration.adConfiguration.isInterstitialAd = true
        adConfiguration.adConfiguration.isRewarded = true
        adConfiguration.adFormats = [.video]

        let _ = createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertTrue(mockRenderer.lastInterstitialAdConfiguration === adConfiguration)
        XCTAssertTrue(mockRenderer.lastInterstitialAdConfiguration?.adConfiguration.isInterstitialAd == true)
        XCTAssertTrue(mockRenderer.lastInterstitialAdConfiguration?.adConfiguration.isRewarded == true)
        XCTAssertEqual(mockRenderer.lastInterstitialAdConfiguration?.adFormats, [.video])
    }

    func testCreateInterstitialController_WithPreparedAdConfiguration_DoesNotOverrideInterstitialFlag() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")
        let adConfiguration = AdUnitConfig(configId: "prepared-config")
        adConfiguration.adConfiguration.isInterstitialAd = false

        let _ = createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertTrue(mockRenderer.lastInterstitialAdConfiguration === adConfiguration)
        XCTAssertFalse(mockRenderer.lastInterstitialAdConfiguration?.adConfiguration.isInterstitialAd == true)
    }

    // MARK: - Extended Interstitial Tests (Video/Rewarded)

    func testCreateInterstitialController_WithRewardedFlag_SetsIsRewarded() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")

        let _ = createInterstitialController(
            bid: bid,
            configId: "test-config",
            isRewarded: true,
            adFormats: nil,
            videoControlsConfig: nil,
            videoParameters: nil,
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertTrue(mockRenderer.lastInterstitialAdConfiguration?.adConfiguration.isRewarded == true)
    }

    func testCreateInterstitialController_WithVideoAdFormats_SetsAdFormats() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")

        let _ = createInterstitialController(
            bid: bid,
            configId: "test-config",
            isRewarded: false,
            adFormats: [.video],
            videoControlsConfig: nil,
            videoParameters: nil,
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertEqual(mockRenderer.lastInterstitialAdConfiguration?.adFormats, [.video])
    }

    func testCreateInterstitialController_WithVideoParameters_SetsVideoParameters() {
        let mockRenderer = MockTrackingPluginRenderer(name: "CustomRenderer", version: "2.0")
        let mockController = MockInterstitialController()
        mockRenderer.interstitialControllerToReturn = mockController

        pluginRegister.registerPlugin(mockRenderer)

        let bid = makeBid(rendererName: "CustomRenderer", rendererVersion: "2.0")
        let videoParams = VideoParameters(mimes: ["video/mp4"])

        let _ = createInterstitialController(
            bid: bid,
            configId: "test-config",
            isRewarded: false,
            adFormats: nil,
            videoControlsConfig: nil,
            videoParameters: videoParams,
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertEqual(
            mockRenderer.lastInterstitialAdConfiguration?.adConfiguration.videoParameters.mimes,
            ["video/mp4"]
        )
    }

    func testCreateBannerView_NoRendererPreference_UsesPrebidRenderer() {
        // Bid has no renderer metadata — should use default PrebidRenderer
        let bid = makeBid()
        let frame = CGRect(origin: .zero, size: bid.size)

        let view = createBannerView(
            with: frame,
            bid: bid,
            configId: "test-config",
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )

        XCTAssertNotNil(view)
        XCTAssertTrue(view is DisplayView)
    }

    func testCreateInterstitialController_NoRendererPreference_UsesPrebidRenderer() {
        let bid = makeBid()

        let controller = createInterstitialController(
            bid: bid,
            configId: "test-config",
            loadingDelegate: interstitialLoadingDelegate,
            interactionDelegate: interstitialInteractionDelegate
        )

        XCTAssertNotNil(controller)
        XCTAssertTrue(controller is InterstitialController)
    }
}

// MARK: - Helpers

extension PluginRendererFactoryTest {

    func makeBid(
        rendererName: String? = nil,
        rendererVersion: String? = nil,
        width: Int = 320,
        height: Int = 50
    ) -> Bid {
        let rawBid = ORTBBid<ORTBBidExt>(bidID: "test", impid: "imp1", price: 1.5)
        rawBid.w = NSNumber(value: width)
        rawBid.h = NSNumber(value: height)
        rawBid.ext = .init()
        rawBid.ext?.prebid = .init()
        rawBid.ext?.prebid?.targeting = [
            "hb_pb": "1.50",
            "hb_bidder": "appnexus",
            "hb_cache_id": "cache123"
        ]

        if let rendererName = rendererName, let rendererVersion = rendererVersion {
            rawBid.ext?.prebid?.meta = [
                Bid.KEY_RENDERER_NAME: rendererName,
                Bid.KEY_RENDERER_VERSION: rendererVersion
            ]
        }

        return Bid(bid: rawBid)
    }

    func createBannerView(
        with frame: CGRect,
        bid: Bid,
        configId: String,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> PrebidMobileDisplayViewProtocol? {
        let adConfiguration = AdUnitConfig(configId: configId, size: bid.size)
        return createBannerView(
            with: frame,
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }

    func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> PrebidMobileDisplayViewProtocol? {
        PluginRendererFactory.createBannerView(
            with: frame,
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }

    func createInterstitialController(
        bid: Bid,
        configId: String,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        createInterstitialController(
            bid: bid,
            configId: configId,
            isRewarded: false,
            adFormats: nil,
            videoControlsConfig: nil,
            videoParameters: nil,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }

    func createInterstitialController(
        bid: Bid,
        configId: String,
        isRewarded: Bool,
        adFormats: Set<AdFormat>?,
        videoControlsConfig: VideoControlsConfiguration?,
        videoParameters: VideoParameters?,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        let adConfiguration = AdUnitConfig(configId: configId)
        adConfiguration.adConfiguration.isInterstitialAd = true
        adConfiguration.adConfiguration.isRewarded = isRewarded || bid.rewardedConfig != nil

        if let adFormats = adFormats {
            adConfiguration.adFormats = adFormats
        }

        if let videoControlsConfig = videoControlsConfig {
            adConfiguration.adConfiguration.videoControlsConfig = videoControlsConfig
        }

        if let videoParameters = videoParameters {
            adConfiguration.adConfiguration.videoParameters = videoParameters
        }

        return createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }

    func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        PluginRendererFactory.createInterstitialController(
            bid: bid,
            adConfiguration: adConfiguration,
            loadingDelegate: loadingDelegate,
            interactionDelegate: interactionDelegate
        )
    }
}

// MARK: - Mock Renderer That Tracks Calls

class MockTrackingPluginRenderer: NSObject, PrebidMobilePluginRenderer {
    let name: String
    let version: String
    var data: [String: Any]?

    var createBannerViewCalled = false
    var createInterstitialControllerCalled = false

    var bannerViewToReturn: PrebidMobileDisplayViewProtocol?
    var interstitialControllerToReturn: PrebidMobileInterstitialControllerProtocol?

    var lastBannerBid: Bid?
    var lastBannerAdConfiguration: AdUnitConfig?
    var lastInterstitialBid: Bid?
    var lastInterstitialAdConfiguration: AdUnitConfig?

    init(name: String, version: String) {
        self.name = name
        self.version = version
    }

    func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> PrebidMobileDisplayViewProtocol? {
        createBannerViewCalled = true
        lastBannerBid = bid
        lastBannerAdConfiguration = adConfiguration
        return bannerViewToReturn
    }

    func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        createInterstitialControllerCalled = true
        lastInterstitialBid = bid
        lastInterstitialAdConfiguration = adConfiguration
        return interstitialControllerToReturn
    }
}

// MARK: - Mock Display View

class MockDisplayView: UIView, PrebidMobileDisplayViewProtocol {
    var loadAdCalled = false

    func loadAd() {
        loadAdCalled = true
    }
}

// MARK: - Mock Interstitial Controller

class MockInterstitialController: NSObject, PrebidMobileInterstitialControllerProtocol {
    var loadAdCalled = false
    var showCalled = false

    func loadAd() {
        loadAdCalled = true
    }

    func show() {
        showCalled = true
    }
}

// MARK: - Stub Delegates

class StubDisplayViewLoadingDelegate: NSObject, DisplayViewLoadingDelegate {
    func displayViewDidLoadAd(_ displayView: UIView) {}
    func displayView(_ displayView: UIView, didFailWithError error: Error) {}
}

class StubDisplayViewInteractionDelegate: NSObject, DisplayViewInteractionDelegate {
    func trackImpression(forDisplayView: UIView) {}
    func viewControllerForModalPresentation(fromDisplayView: UIView) -> UIViewController? { nil }
    func didLeaveApp(from displayView: UIView) {}
    func willPresentModal(from displayView: UIView) {}
    func didDismissModal(from displayView: UIView) {}
}

class StubInterstitialLoadingDelegate: NSObject, InterstitialControllerLoadingDelegate {
    func interstitialControllerDidLoadAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func interstitialController(_ interstitialController: PrebidMobileInterstitialControllerProtocol, didFailWithError error: Error) {}
}

class StubInterstitialInteractionDelegate: NSObject, InterstitialControllerInteractionDelegate {
    func trackImpression(forInterstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func interstitialControllerDidClickAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func interstitialControllerDidDisplay(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func interstitialControllerDidComplete(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    func viewControllerForModalPresentation(fromInterstitialController: PrebidMobileInterstitialControllerProtocol) -> UIViewController? { nil }
    func interstitialControllerDidLeaveApp(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
}
