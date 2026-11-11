/*   Copyright 2018-2026 Prebid.org, Inc.

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

private final class StubBidSelector: NSObject, PrebidBidSelecting {

    let pluginInfo: PrebidPluginInfo

    private let selection: ([Bid]) -> Bid?

    private(set) var calls: [(bids: [Bid], context: BidSelectionContext, isMainThread: Bool)] = []
    private(set) var registerCount = 0
    private(set) var unregisterCount = 0

    init(name: String = "test-selector", _ selection: @escaping ([Bid]) -> Bid?) {
        self.pluginInfo = PrebidPluginInfo(name: name, version: "1.0")
        self.selection = selection
    }

    func selectBid(from bids: [Bid], context: BidSelectionContext) -> Bid? {
        calls.append((bids, context, Thread.isMainThread))
        return selection(bids)
    }

    func onRegister() {
        registerCount += 1
    }

    func onUnregister() {
        unregisterCount += 1
    }
}

/// Stands for an ad server event handler, e.g. the GAM one.
private final class AdServerBannerEventHandler: NSObject, BannerEventHandler {
    
    weak var loadingDelegate: BannerEventLoadingDelegate?
    weak var interactionDelegate: BannerEventInteractionDelegate?
    
    var adSizes: [CGSize] = []
    
    func requestAd(with bidResponse: BidResponse?) {}
    
    func trackImpression() {}
}

class BidSelectorTests: XCTestCase {

    private let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"

    private var sdkConfiguration: Prebid!

    override func setUp() {
        super.setUp()

        sdkConfiguration = Prebid.mock
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        sdkConfiguration.prebidServerAccountId = Prebid.devintAccountID
    }

    override func tearDown() {
        sdkConfiguration.filterOutUncachedBids = false
        Prebid.reset()

        super.tearDown()
    }

    // MARK: - Registration

    func testRegisterAndUnregister() {
        let selector = StubBidSelector { $0.first }

        Prebid.register(selector, as: .bidSelector)

        XCTAssertTrue(Prebid.contains(selector, as: .bidSelector))
        XCTAssertEqual(selector.registerCount, 1)

        Prebid.unregister(selector, as: .bidSelector)

        XCTAssertFalse(Prebid.contains(selector, as: .bidSelector))
        XCTAssertEqual(selector.unregisterCount, 1)
    }

    func testOnlyOneSelectorIsRegistered() {
        let first = StubBidSelector(name: "first") { $0.first }
        let second = StubBidSelector(name: "second") { $0.last }

        Prebid.register(first, as: .bidSelector)
        Prebid.register(second, as: .bidSelector)

        XCTAssertTrue(Prebid.contains(first, as: .bidSelector))
        XCTAssertFalse(Prebid.contains(second, as: .bidSelector), "A second selector is ignored while one is registered")
        XCTAssertEqual(second.registerCount, 0)

        Prebid.unregister(first, as: .bidSelector)
        Prebid.register(second, as: .bidSelector)

        XCTAssertTrue(Prebid.contains(second, as: .bidSelector))
    }

    // MARK: - Without a selector

    func testWithoutSelectorTheServerWinnerWins() {
        let response = requestBids(with: [Self.serverWinner, Self.runnerUp])

        XCTAssertNil(response.error)
        XCTAssertEqual(response.bidResponse?.winningBid?.price, 0.75)
        XCTAssertEqual(response.bidResponse?.targetingInfo?["hb_bidder"], "openx")
        // The losing bid's keys are merged in, as before
        XCTAssertEqual(response.bidResponse?.targetingInfo?["hb_pb_appnexus"], "2.00")
    }

    // MARK: - Selection

    func testSelectorChoosesTheWinner() {
        let selector = StubBidSelector { bids in bids.max { $0.price < $1.price } }
        Prebid.register(selector, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp])

        XCTAssertNil(response.error)
        XCTAssertEqual(response.bidResponse?.winningBid?.price, 2.00)

        XCTAssertEqual(selector.calls.count, 1, "The selector is called once per auction")
        XCTAssertEqual(selector.calls.first?.bids.count, 2)
        XCTAssertTrue(selector.calls.first?.isMainThread ?? false)
        XCTAssertEqual(selector.calls.first?.context.configId, configId)
        XCTAssertEqual(selector.calls.first?.context.adFormats, [.banner])
    }

    func testTargetingComesFromTheSelectedBidOnly() {
        Prebid.register(StubBidSelector { bids in bids.max { $0.price < $1.price } }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp])
        let targeting = response.bidResponse?.targetingInfo

        // The generic keys are filled in from the selected bid's bidder-specific keys
        XCTAssertEqual(targeting?["hb_pb"], "2.00")
        XCTAssertEqual(targeting?["hb_bidder"], "appnexus")
        XCTAssertEqual(targeting?["hb_size"], "320x50")
        XCTAssertEqual(targeting?["hb_cache_id"], "appnexus-cache-id")
        XCTAssertEqual(targeting?["hb_cache_host"], "prebid-cache.example.com")
        XCTAssertEqual(targeting?["hb_cache_path"], "/cache")
        XCTAssertEqual(targeting?["hb_pb_appnexus"], "2.00")

        // Nothing comes from the server's winner, not even a key the selected bid lacks
        XCTAssertNil(targeting?["hb_deal"])
        XCTAssertNil(targeting?["hb_pb_openx"])
        XCTAssertNil(targeting?["hb_bidder_openx"])
        XCTAssertNil(targeting?["hb_deal_openx"])

        // Integrations that read the winning bid's own keys (e.g. mediation interstitials) see the same set
        XCTAssertEqual(response.bidResponse?.winningBid?.targetingInfo, targeting)
        XCTAssertTrue(response.bidResponse?.winningBid?.isWinning ?? false)
    }

    func testSelectorTakesPrecedenceOverForceSdkToChooseWinner() {
        Targeting.shared.forceSdkToChooseWinner = true
        defer { Targeting.shared.forceSdkToChooseWinner = false }
        Prebid.register(StubBidSelector { bids in bids.max { $0.price < $1.price } }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp])

        XCTAssertEqual(response.bidResponse?.winningBid?.price, 2.00)
    }

    func testSelectorChoosingNoBidEndsTheAuctionWithoutWinner() {
        Prebid.register(StubBidSelector { _ in nil }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp])

        XCTAssertNil(response.bidResponse, "The SDK doesn't fall back to the server's winner")
        XCTAssertEqual(response.error as NSError?, PBMError.noWinningBid() as NSError?)
        XCTAssertEqual(PBMError.demandResult(from: response.error), .prebidDemandNoBids)
    }

    func testSelectorChoosingABidItWasNotGivenEndsTheAuctionWithoutWinner() {
        let staleBid = BidResponse(jsonDictionary: Self.responseDictionary(with: [Self.runnerUp])).allBids![0]
        Prebid.register(StubBidSelector { _ in staleBid }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp])

        XCTAssertNil(response.bidResponse)
        XCTAssertEqual(response.error as NSError?, PBMError.noWinningBid() as NSError?)
        XCTAssertNil(staleBid.selectedBidTargetingInfo)
    }

    func testSelectorIsCalledOnTheMainThreadWhenTheResponseArrivesOnAnotherThread() {
        let selector = StubBidSelector { $0.first }
        Prebid.register(selector, as: .bidSelector)

        let connection = MockServerConnection(onPost: [{ _, _, _, callback in
            DispatchQueue.global().async {
                callback(BidResponseTransformer.buildResponse(Self.responseString(with: [Self.serverWinner])))
            }
        }])

        // The requester's owner keeps it alive until the response arrives
        let requester = makeRequester(connection: connection)
        
        let completed = expectation(description: "requestBids completed")
        requester.requestBids { bidResponse, error in
            XCTAssertNotNil(bidResponse)
            XCTAssertNil(error)
            completed.fulfill()
        }
        waitForExpectations(timeout: 5)

        XCTAssertEqual(selector.calls.count, 1)
        XCTAssertTrue(selector.calls.first?.isMainThread ?? false)
    }

    // MARK: - Eligible bids

    func testOriginalAPIWithFilterOutUncachedBidsOffersCachedBidsOnly() {
        sdkConfiguration.filterOutUncachedBids = true
        let selector = StubBidSelector { $0.first }
        Prebid.register(selector, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp], isOriginalAPI: true)

        // The server's winner has no Prebid Cache entry, so the selector never sees it
        XCTAssertEqual(selector.calls.first?.bids.count, 1)
        XCTAssertEqual(selector.calls.first?.bids.first?.price, 2.00)
        XCTAssertEqual(response.bidResponse?.winningBid?.price, 2.00)
        XCTAssertEqual(response.bidResponse?.allBids?.count, 1)
        XCTAssertFalse(response.bidResponse?.topBidWasFiltered ?? true)
    }

    func testNoCachedBidPromotionWhenTheSelectorChoosesNoBid() {
        sdkConfiguration.filterOutUncachedBids = true
        Prebid.register(StubBidSelector { _ in nil }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp], isOriginalAPI: true)

        XCTAssertNil(response.bidResponse, "The cached runner-up is not promoted in place of the selector's decision")
        XCTAssertEqual(response.error as NSError?, PBMError.noWinningBid() as NSError?)
    }

    func testSelectorIsNotCalledWhenNoBidIsCached() {
        sdkConfiguration.filterOutUncachedBids = true
        let selector = StubBidSelector { $0.first }
        Prebid.register(selector, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner], isOriginalAPI: true)

        XCTAssertTrue(selector.calls.isEmpty)
        XCTAssertEqual(response.error as NSError?, PBMError.noCachedBids() as NSError?)
    }

    func testRenderingAPIHasNoServerCacheRequirement() {
        sdkConfiguration.filterOutUncachedBids = true
        let selector = StubBidSelector { $0.first }
        Prebid.register(selector, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.runnerUp], isOriginalAPI: false)

        XCTAssertEqual(selector.calls.first?.bids.count, 2)
        XCTAssertEqual(response.bidResponse?.winningBid?.price, 0.75)
    }

    // MARK: - Targeting validation

    func testBidWithoutWinnerKeysIsInvalidForAnAdServer() {
        Prebid.register(StubBidSelector { bids in bids.first { $0.price == 3.00 } }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.bidWithoutTargeting])

        XCTAssertNil(response.bidResponse)
        XCTAssertEqual(PBMError.demandResult(from: response.error), .prebidDemandInvalidTargeting)
    }

    func testCacheIdIsRequiredWhenCacheReportingIsOn() {
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
        // The server's winner has no hb_cache_id
        Prebid.register(StubBidSelector { $0.first }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner])

        XCTAssertNil(response.bidResponse)
        XCTAssertEqual(PBMError.demandResult(from: response.error), .prebidDemandInvalidTargeting)
    }

    func testBidWithoutTargetingWinsWhenRenderedWithoutAnAdServer() {
        Prebid.register(StubBidSelector { bids in bids.first { $0.price == 3.00 } }, as: .bidSelector)

        let response = requestBids(with: [Self.serverWinner, Self.bidWithoutTargeting], rendersWithoutAdServer: true)

        XCTAssertNil(response.error)
        XCTAssertEqual(response.bidResponse?.winningBid?.price, 3.00)
        XCTAssertNil(response.bidResponse?.targetingInfo, "The server winner's keys are not used")
    }

    func testRenderingAdUnitsWithoutAnAdServerAreMarked() {
        let standaloneBanner = BannerView(frame: .zero, configID: configId, adSize: CGSize(width: 320, height: 50))
        let gamBanner = BannerView(
            frame: .zero,
            configID: configId,
            adSize: CGSize(width: 320, height: 50),
            eventHandler: AdServerBannerEventHandler()
        )
        let standaloneInterstitial = InterstitialRenderingAdUnit(configID: configId)
        let standaloneRewarded = RewardedAdUnit(configID: configId)

        XCTAssertTrue(standaloneBanner.adUnitConfig.adConfiguration.rendersWithoutAdServer)
        XCTAssertFalse(gamBanner.adUnitConfig.adConfiguration.rendersWithoutAdServer)
        XCTAssertTrue(standaloneInterstitial.adUnitConfig.adConfiguration.rendersWithoutAdServer)
        XCTAssertTrue(standaloneRewarded.adUnitConfig.adConfiguration.rendersWithoutAdServer)
        XCTAssertTrue((standaloneBanner.adUnitConfig.copy() as! AdUnitConfig).adConfiguration.rendersWithoutAdServer)
    }

    // MARK: - Selected bid targeting

    func testServerWinnerKeepsItsKeys() {
        let targeting = [
            "hb_pb": "0.75", "hb_bidder": "openx", "hb_size": "300x250",
            "hb_pb_openx": "0.75", "hb_bidder_openx": "openx", "hb_size_openx": "300x250",
        ]

        XCTAssertEqual(try SelectedBidTargeting.make(from: targeting).get(), targeting)
    }

    func testGenericKeysAreFilledInFromBidderSpecificKeys() {
        let targeting = [
            "hb_pb_rubicon": "1.20",
            "hb_bidder_rubicon": "rubicon",
            "hb_size_rubicon": "300x250",
            "hb_format_rubicon": "video",
            "hb_deal_rubicon": "deal-1",
            "hb_cache_id_rubicon": "cache-1",
            "hb_uuid_rubicon": "uuid-1",
            "hb_cache_host_rubico": "prebid-cache.example.com",
            "hb_cache_path_rubico": "/cache",
            "hb_env_rubicon": "mobile-app",
        ]

        let result = try? SelectedBidTargeting.make(from: targeting).get()

        XCTAssertEqual(result, targeting.merging([
            "hb_pb": "1.20",
            "hb_bidder": "rubicon",
            "hb_size": "300x250",
            "hb_format": "video",
            "hb_deal": "deal-1",
            "hb_cache_id": "cache-1",
            "hb_uuid": "uuid-1",
            "hb_cache_host": "prebid-cache.example.com",
            "hb_cache_path": "/cache",
            "hb_env": "mobile-app",
        ]) { $1 })
    }

    func testBidderAliasResolvesToItsOwnKeys() {
        let targeting = [
            "hb_pb_appnexus2": "1.50",
            "hb_bidder_appnexus2": "appnexus2",
        ]

        let result = try? SelectedBidTargeting.make(from: targeting).get()

        XCTAssertEqual(result?["hb_bidder"], "appnexus2")
        XCTAssertEqual(result?["hb_pb"], "1.50")
    }

    func testTruncatedBidderSpecificKeysAreResolved() {
        // Prebid Server truncates keys to 20 characters by default
        let targeting = [
            "hb_bidder_averylongb": "averylongbidder",
            "hb_pb_averylongbidde": "0.50",
            "hb_cache_id_averylon": "cache-1",
        ]

        let result = try? SelectedBidTargeting.make(from: targeting).get()

        XCTAssertEqual(result?["hb_bidder"], "averylongbidder")
        XCTAssertEqual(result?["hb_pb"], "0.50")
        XCTAssertEqual(result?["hb_cache_id"], "cache-1")
    }

    func testKeysOfOtherFamiliesAreNotMistakenForAKey() {
        let targeting = [
            "hb_bidder_openx": "openx",
            "hb_pb_cat_dur_openx": "1.00_food_30s",
        ]

        let result = try? SelectedBidTargeting.make(from: targeting).get()

        XCTAssertEqual(result?["hb_bidder"], "openx")
        XCTAssertNil(result?["hb_pb"])
    }

    func testBidWithoutBidderKeysIsLeftAsIs() {
        let targeting = ["custom_key": "value"]

        XCTAssertEqual(try SelectedBidTargeting.make(from: targeting).get(), targeting)
    }

    func testSeveralBiddersAreAmbiguous() {
        let targeting = [
            "hb_bidder_openx": "openx",
            "hb_bidder_rubicon": "rubicon",
        ]

        XCTAssertEqual(
            SelectedBidTargeting.make(from: targeting),
            .failure(.ambiguousBidder(codes: ["openx", "rubicon"]))
        )
    }

    func testSeveralTruncatedFormsOfAKeyAreAmbiguous() {
        let targeting = [
            "hb_bidder_appnexus": "appnexus",
            "hb_pb_appn": "1.00",
            "hb_pb_appnex": "2.00",
        ]

        XCTAssertEqual(
            SelectedBidTargeting.make(from: targeting),
            .failure(.ambiguousKey("hb_pb", candidates: ["hb_pb_appn", "hb_pb_appnex"]))
        )
    }

    // MARK: - Helpers

    private typealias Response = (bidResponse: BidResponse?, error: Error?)

    private func makeRequester(
        connection: PrebidServerConnectionProtocol,
        isOriginalAPI: Bool = false,
        rendersWithoutAdServer: Bool = false
    ) -> BidRequester {
        let adUnitConfig = AdUnitConfig(configId: configId, size: CGSize(width: 320, height: 50))
        adUnitConfig.adConfiguration.isOriginalAPI = isOriginalAPI
        adUnitConfig.adConfiguration.rendersWithoutAdServer = rendersWithoutAdServer

        return Factory.createBidRequester(
            connection: connection,
            sdkConfiguration: sdkConfiguration,
            targeting: Targeting.shared,
            adUnitConfiguration: adUnitConfig
        )
    }

    private func requestBids(
        with bids: [[String: Any]],
        isOriginalAPI: Bool = false,
        rendersWithoutAdServer: Bool = false
    ) -> Response {
        let connection = MockServerConnection(onPost: [{ _, _, _, callback in
            callback(BidResponseTransformer.buildResponse(Self.responseString(with: bids)))
        }])

        var response: Response = (nil, nil)
        let completed = expectation(description: "requestBids completed")

        makeRequester(
            connection: connection,
            isOriginalAPI: isOriginalAPI,
            rendersWithoutAdServer: rendersWithoutAdServer
        ).requestBids { bidResponse, error in
            response = (bidResponse, error)
            completed.fulfill()
        }
        waitForExpectations(timeout: 5)

        return response
    }

    /// The winner Prebid Server picked: generic and bidder-specific keys, a deal, no Prebid Cache entry.
    private static let serverWinner: [String: Any] = bid(id: "openx-bid", price: 0.75, targeting: [
        "hb_pb": "0.70", "hb_bidder": "openx", "hb_size": "300x250", "hb_deal": "openx-deal",
        "hb_pb_openx": "0.70", "hb_bidder_openx": "openx", "hb_size_openx": "300x250", "hb_deal_openx": "openx-deal",
    ])

    /// A higher bid that Prebid Server didn't pick: bidder-specific keys only, with a Prebid Cache entry.
    private static let runnerUp: [String: Any] = bid(id: "appnexus-bid", price: 2.00, targeting: [
        "hb_pb_appnexus": "2.00",
        "hb_bidder_appnexus": "appnexus",
        "hb_size_appnexus": "320x50",
        "hb_cache_id_appnexus": "appnexus-cache-id",
        "hb_cache_host_appnex": "prebid-cache.example.com",
        "hb_cache_path_appnex": "/cache",
    ], cache: ["bids": ["url": "https://prebid-cache.example.com/cache?uuid=appnexus-cache-id", "cacheId": "appnexus-cache-id"]])

    /// A bid without any targeting keys.
    private static let bidWithoutTargeting: [String: Any] = bid(id: "no-targeting-bid", price: 3.00, targeting: nil)

    private static func bid(
        id: String,
        price: Double,
        targeting: [String: String]?,
        cache: [String: Any]? = nil
    ) -> [String: Any] {
        var prebid: [String: Any] = ["type": "banner"]
        prebid["targeting"] = targeting
        prebid["cache"] = cache

        return [
            "id": id,
            "impid": "imp-id",
            "price": price,
            "adm": "<html></html>",
            "w": 320,
            "h": 50,
            "ext": ["prebid": prebid],
        ]
    }

    private static func responseDictionary(with bids: [[String: Any]]) -> [String: Any] {
        [
            "id": "response-id",
            "seatbid": [["bid": bids, "seat": "prebid"]],
            "cur": "USD",
        ]
    }

    private static func responseString(with bids: [[String: Any]]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: responseDictionary(with: bids))
        return String(data: data, encoding: .utf8)!
    }
}
