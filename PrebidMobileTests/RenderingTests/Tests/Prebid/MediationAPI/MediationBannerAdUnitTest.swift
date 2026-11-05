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

class MediationBannerAdUnitTest: XCTestCase {
    
    var adObject: MockAdObject?
    var mediationDelegate: PrebidMediationDelegate?
    
    let testID = "auid"
    let primarySize = CGSize(width: 320, height: 50)
    
    private func getSDKConfiguration() -> Prebid {
        let config = Prebid.mock
        try! Host.shared.setHostURL(Prebid.devintServerURL, nonTrackingURLString: nil)
        config.prebidServerAccountId = Prebid.devintAccountID
        return config
    }
    
    private let targeting = Targeting.shared
    
    override func setUp() {
        super.setUp()
        
        self.adObject = MockAdObject()
        self.mediationDelegate = MockMediationUtils(adObject: adObject!)
    }
    
    func testConfigSetup() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        XCTAssertEqual(adUnitConfig.configId, testID)
        XCTAssertEqual(adUnitConfig.adSize, primarySize)
        
        let moreSizes = [
            CGSize(width: 300, height: 250),
            CGSize(width: 728, height: 90),
        ]
        
        bannerAdUnit.additionalSizes = moreSizes
        
        XCTAssertEqual(adUnitConfig.additionalSizes?.count, moreSizes.count)
        for i in 0..<moreSizes.count {
            XCTAssertEqual(adUnitConfig.additionalSizes?[i], moreSizes[i])
        }
        
        let refreshInterval: TimeInterval = 40;
        
        bannerAdUnit.refreshInterval = refreshInterval
        XCTAssertEqual(adUnitConfig.refreshInterval, refreshInterval)
    }
    
    func testAdFormats() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        // Default: display banner only
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Single format
        bannerAdUnit.adFormats = [.video]
        XCTAssertEqual(bannerAdUnit.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adFormats, [.video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.video])
        
        // Multiformat
        bannerAdUnit.adFormats = [.banner, .video]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    @available(*, deprecated, message: "Covers the deprecated `adFormat` property.")
    func testDeprecatedAdFormatIsBackedByAdFormats() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        
        XCTAssertEqual(bannerAdUnit.adFormat, .banner)
        
        // Legacy setter replaces the whole set
        bannerAdUnit.adFormat = .video
        XCTAssertEqual(bannerAdUnit.adFormat, .video)
        XCTAssertEqual(bannerAdUnit.adFormats, [.video])
        XCTAssertEqual(bannerAdUnit.adUnitConfig.adFormats, [.video])
        
        // New setter is visible through the legacy getter
        bannerAdUnit.adFormats = [.banner]
        XCTAssertEqual(bannerAdUnit.adFormat, .banner)
        
        // Legacy getter returns a member of a multiformat set
        bannerAdUnit.adFormats = [.banner, .video]
        XCTAssertTrue(bannerAdUnit.adFormats.contains(bannerAdUnit.adFormat))
    }
    
    func testAdFormatsRejectsEmptySet() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        bannerAdUnit.adFormats = [.banner, .video]
        
        bannerAdUnit.adFormats = []
        
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner, .video], "Empty set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    func testAdFormatsRejectsUnsupportedFormats() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let adUnitConfig = bannerAdUnit.adUnitConfig
        
        // Unsupported only
        bannerAdUnit.adFormats = [.native]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner], "Native-only set must be ignored")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // Mixed supported + unsupported must be rejected as a whole
        bannerAdUnit.adFormats = [.banner, .video, .native]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner], "Set containing native must be ignored entirely")
        XCTAssertEqual(adUnitConfig.adFormats, [.banner])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner])
        
        // A valid set is still accepted afterwards
        bannerAdUnit.adFormats = [.banner, .video]
        XCTAssertEqual(bannerAdUnit.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adFormats, [.banner, .video])
        XCTAssertEqual(adUnitConfig.adConfiguration.adFormats, [.banner, .video])
    }
    
    @available(*, deprecated, message: "Covers the deprecated `adFormat` property.")
    func testDeprecatedAdFormatRejectsUnsupportedFormat() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        
        bannerAdUnit.adFormat = .video
        bannerAdUnit.adFormat = .native
        
        XCTAssertEqual(bannerAdUnit.adFormat, .video, "Legacy setter must go through the same validation")
        XCTAssertEqual(bannerAdUnit.adFormats, [.video])
        XCTAssertEqual(bannerAdUnit.adUnitConfig.adFormats, [.video])
    }
    
    func testIsMutedIsBackedByVideoControlsConfig() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let videoControlsConfig = bannerAdUnit.adUnitConfig.adConfiguration.videoControlsConfig
        
        XCTAssertFalse(bannerAdUnit.isMuted, "Outstream video plays with sound unless the publisher asks otherwise")
        
        bannerAdUnit.isMuted = true
        XCTAssertTrue(bannerAdUnit.isMuted)
        XCTAssertTrue(videoControlsConfig.isMuted)
        
        bannerAdUnit.isMuted = false
        XCTAssertFalse(videoControlsConfig.isMuted)
    }
    
    func testIsSoundButtonVisibleIsBackedByVideoControlsConfig() {
        let bannerAdUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let videoControlsConfig = bannerAdUnit.adUnitConfig.adConfiguration.videoControlsConfig
        
        XCTAssertFalse(bannerAdUnit.isSoundButtonVisible, "No mute button unless the publisher asks for one")
        
        bannerAdUnit.isSoundButtonVisible = true
        XCTAssertTrue(bannerAdUnit.isSoundButtonVisible)
        XCTAssertTrue(videoControlsConfig.isSoundButtonVisible)
        
        bannerAdUnit.isSoundButtonVisible = false
        XCTAssertFalse(videoControlsConfig.isSoundButtonVisible)
    }
    
    // The adapters build a fresh rendering config for every creative, so the video controls
    // must be handed over with each winning video bid for `isMuted` to hold across refreshes.
    func testVideoBidHandsVideoControlsConfigToTheAdapter() {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidVideoResponse)
        }])
        
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        adUnit.adFormats = [.banner, .video]
        adUnit.isMuted = true
        
        let asyncExpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(connection: connection,
                           sdkConfiguration: getSDKConfiguration(),
                           targeting: targeting)
        { [weak self] result in
            XCTAssertEqual(result, .prebidDemandFetchSuccess)
            
            let resultExtras: [AnyHashable : Any] = self!.adObject!.localExtras!
            XCTAssertEqual(resultExtras.count, 4)
            
            let videoControlsConfig = resultExtras[PBMMediationVideoAdConfiguration] as? VideoControlsConfiguration
            XCTAssertNotNil(videoControlsConfig, "A video bid must carry the video controls to the adapter")
            XCTAssertTrue(videoControlsConfig === adUnit.adUnitConfig.adConfiguration.videoControlsConfig,
                          "The ad unit hands over its own config; the renderer copies it for each load")
            XCTAssertEqual(videoControlsConfig?.isMuted, true)
            
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    func testAdObjectSetUpCleanUp() {
       
        //a good response with a bid
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidResponse)
        }])
        let initialKeywords = "key1,key2"
        
        adObject!.keywords = initialKeywords
        
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = MediationBannerAdUnit(configID: configId, size: primarySize, mediationDelegate: mediationDelegate!)
        
        let asyncExpectation = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(connection: connection,
                           sdkConfiguration: getSDKConfiguration(),
                           targeting: targeting)
        { [weak self] result in
            XCTAssertEqual(result, .prebidDemandFetchSuccess)
            
            let resultKeywords = self!.adObject!.keywords!
            XCTAssertTrue(resultKeywords.contains("hb_pb:0.10"))
            
            let resultExtras: [AnyHashable : Any] = self!.adObject!.localExtras!
            XCTAssertEqual(resultExtras.count, 3)
            XCTAssertEqual(resultExtras[MockMediationConfigIdKey] as? String, configId)
            let bid = resultExtras[MockMediationAdUnitBidKey] as! NSObject
            XCTAssertTrue(bid.isKind(of: Bid.self))
            
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1)
        
        //a bad response with the same ad object without bids
        
        let noBidConnection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.serverErrorResponse)
        }])
        
        let asyncExpectation2 = expectation(description: "fetchDemand executed")
        
        adUnit.fetchDemand(connection: noBidConnection,
                           sdkConfiguration: getSDKConfiguration(),
                           targeting: targeting)
        { [weak self] result in
            XCTAssertEqual(result, .prebidServerError)
            
            let resultKeywords = self!.adObject!.keywords!
            XCTAssertEqual(resultKeywords, initialKeywords)
            let resultExtras: [AnyHashable : Any] = self!.adObject!.localExtras!
            XCTAssertEqual(resultExtras.count, 0)
            
            asyncExpectation2.fulfill()
        }
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: - fetchDemandBidInfo

    func testFetchDemandBidInfoProvidesWinningBid() {
        let configId = "b6260e2b-bc4c-4d10-bdb5-f7bdd62f5ed4"
        let adUnit = MediationBannerAdUnit(configID: configId, size: primarySize, mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandFetchSuccess)
        assertWinningBidEconomics(bidInfo)
        XCTAssertEqual(bidInfo?.targetingKeywords?["hb_pb"], "0.10")

        XCTAssertTrue(adObject!.keywords!.contains("hb_pb:0.10"))
        XCTAssertEqual(adObject!.localExtras?[MockMediationConfigIdKey] as? String, configId)
        XCTAssertTrue(adObject!.localExtras?[MockMediationAdUnitBidKey] is Bid)
    }

    func testFetchDemandBidInfoOnServerError() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.serverErrorResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidServerError)
        XCTAssertNil(bidInfo?.targetingKeywords)
        XCTAssertNil(bidInfo?.price)
        XCTAssertNil(bidInfo?.creativeId)
    }

    func testFetchDemandBidInfoWhenAdObjectSetUpFails() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: MockRejectingMediationDelegate())

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidWrongArguments)
        // Nothing was attached to the ad object, so only the request id is reported
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31")
        assertNoBidAttached(bidInfo)
    }

    func testFetchDemandBidInfoReportsTheAttachedTargeting() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.twoBiddersResponse)

        // The banner attaches the merged targeting of the response, other bidders' keys included
        XCTAssertEqual(bidInfo?.targetingKeywords?["hb_pb"], "0.10")
        XCTAssertEqual(bidInfo?.targetingKeywords?["hb_pb_appnexus"], "0.05")
        XCTAssertTrue(adObject!.keywords!.contains("hb_pb_appnexus:0.05"))
    }

    func testFetchDemandBidInfoKeepsCompletionForAutoRefresh() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        _ = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertNotNil(adUnit.lastCompletion, "The refresh timer re-runs the request with the stored completion")
        XCTAssertTrue(adUnit.lastAdView === adObject)
    }

    func testFetchDemandWithoutCompletionStillSkipsAutoRefresh() {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(BidResponseTransformer.someValidResponse)
        }])
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)

        adUnit.fetchDemand(connection: connection,
                           sdkConfiguration: getSDKConfiguration(),
                           targeting: targeting,
                           completion: nil)

        // The request has been handled once the requester is released.
        // The predicate is polled roughly once a second.
        let requestFinished = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in adUnit.bidRequester == nil },
            object: nil
        )
        wait(for: [requestFinished], timeout: 5)

        XCTAssertNil(adUnit.lastCompletion)
        XCTAssertNil(adUnit.lastAdView)
    }

    // MARK: - Every call gets a completion

    func testFetchWhileRequestIsInFlightCompletesWithMisuse() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let heldRequest = HeldRequest()
        let runningFetch = startFetch(adUnit, connection: heldRequest.connection)

        let rejected = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(rejected?.resultCode, .prebidSDKMisusePreviousFetchNotCompletedYet)
        assertNoBidAttached(rejected)
        XCTAssertTrue(runningFetch.results.isEmpty, "The running fetch has not been answered yet")

        // The running fetch is left alone and still reports to its own completion
        heldRequest.respond(with: BidResponseTransformer.someValidResponse, in: self)
        wait(for: [runningFetch.completed], timeout: 1)

        XCTAssertEqual(runningFetch.results.map(\.resultCode), [.prebidDemandFetchSuccess])
        XCTAssertEqual(adObject?.keywords?.contains("hb_pb:0.10"), true)
    }

    func testRefreshTickDuringRefreshDoesNotReachTheStoredCompletion() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        // The first request is the app's fetch, the held one is the auto-refresh
        let heldRequest = HeldRequest(after: [BidResponseTransformer.someValidResponse])
        let fetch = startFetch(adUnit, connection: heldRequest.connection, expectedCalls: 2)

        wait(for: [fetch.firstCall], timeout: 1)
        adUnit.autoRefreshManager?.refreshBlock()
        heldRequest.waitUntilSent(in: self)

        // A second tick while the refresh is running: no request, and nothing for the app
        adUnit.autoRefreshManager?.refreshBlock()
        drainMainQueue()
        XCTAssertEqual(fetch.results.map(\.resultCode), [.prebidDemandFetchSuccess])

        heldRequest.respond(with: BidResponseTransformer.someValidResponse, in: self)
        wait(for: [fetch.completed], timeout: 1)
        XCTAssertEqual(fetch.results.map(\.resultCode), [.prebidDemandFetchSuccess, .prebidDemandFetchSuccess])
    }

    func testAutoRefreshDeliversAnotherBidInfoToTheStoredCompletion() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let connection = MockServerConnection(onPost: [
            { (url, data, timeout, callback) in callback(BidResponseTransformer.someValidResponse) },
            { (url, data, timeout, callback) in callback(BidResponseTransformer.serverErrorResponse) },
        ])
        let fetch = startFetch(adUnit, connection: connection, expectedCalls: 2)

        wait(for: [fetch.firstCall], timeout: 1)
        adUnit.autoRefreshManager?.refreshBlock()
        wait(for: [fetch.completed], timeout: 1)

        // The refresh repeats the request of the app's fetch and reports the new result
        XCTAssertEqual(fetch.results.map(\.resultCode), [.prebidDemandFetchSuccess, .prebidServerError])
    }

    func testStopRefreshCancelsThePendingRefresh() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        _ = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)
        XCTAssertNotNil(adUnit.autoRefreshManager?.delayedBlock, "Sanity: a completed fetch schedules the next refresh")

        adUnit.stopRefresh()

        XCTAssertNil(adUnit.autoRefreshManager?.delayedBlock)

        // A tick that was already on its way sends no request
        adUnit.autoRefreshManager?.refreshBlock()
        XCTAssertNil(adUnit.bidRequester)
    }

    func testFetchAfterStopRefreshCompletesAndTurnsRefreshBackOn() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        _ = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)
        adUnit.stopRefresh()

        let bidInfo = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)

        XCTAssertEqual(bidInfo?.resultCode, .prebidDemandFetchSuccess)
        XCTAssertFalse(adUnit.isRefreshStopped)
        XCTAssertNotNil(adUnit.autoRefreshManager?.delayedBlock, "The fetch schedules the next refresh again")
    }

    func testResponseInFlightAtStopRefreshIsDeliveredWithoutSchedulingRefresh() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let heldRequest = HeldRequest()
        let fetch = startFetch(adUnit, connection: heldRequest.connection)

        adUnit.stopRefresh()
        heldRequest.respond(with: BidResponseTransformer.someValidResponse, in: self)
        wait(for: [fetch.completed], timeout: 1)

        XCTAssertEqual(fetch.results.map(\.resultCode), [.prebidDemandFetchSuccess])
        XCTAssertEqual(adObject?.keywords?.contains("hb_pb:0.10"), true)
        XCTAssertNil(adUnit.autoRefreshManager?.delayedBlock, "The stop still holds")
    }

    func testResumeRefreshSchedulesTheNextRefresh() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        _ = fetchBidInfo(adUnit, response: BidResponseTransformer.someValidResponse)
        adUnit.stopRefresh()

        adUnit.resumeRefresh()

        XCTAssertFalse(adUnit.isRefreshStopped)
        XCTAssertNotNil(adUnit.autoRefreshManager?.delayedBlock)
    }

    func testResumeRefreshDuringFetchLeavesSchedulingToTheFetch() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        let heldRequest = HeldRequest()
        let fetch = startFetch(adUnit, connection: heldRequest.connection)
        adUnit.stopRefresh()

        adUnit.resumeRefresh()
        XCTAssertNil(adUnit.autoRefreshManager?.delayedBlock, "No refresh while the fetch is running")

        heldRequest.respond(with: BidResponseTransformer.someValidResponse, in: self)
        wait(for: [fetch.completed], timeout: 1)
        XCTAssertNotNil(adUnit.autoRefreshManager?.delayedBlock)
    }

    func testResumeRefreshBeforeAnyFetchSchedulesNothing() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        adUnit.stopRefresh()

        adUnit.resumeRefresh()

        XCTAssertFalse(adUnit.isRefreshStopped)
        XCTAssertNil(adUnit.autoRefreshManager?.delayedBlock)
    }

    func testFetchWithoutAdViewCompletesWithWrongArguments() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize,
                                           mediationDelegate: ReplaceableAdViewMediationDelegate(adView: nil))

        // No request is expected: the connection fails the test on any post
        let bidInfo = fetchBidInfo(adUnit, connection: MockServerConnection(onPost: [MockServerConnection.PostHandler]()))

        XCTAssertEqual(bidInfo?.resultCode, .prebidWrongArguments)
        XCTAssertNil(bidInfo?.requestId)
        XCTAssertNil(adUnit.bidRequester)
    }

    func testAdViewReleasedBeforeResponseCompletesWithWrongArguments() {
        let delegate = ReplaceableAdViewMediationDelegate(adView: UIView(frame: .zero))
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: delegate)
        let heldRequest = HeldRequest()
        weak var releasedAdView: UIView?

        var fetch: FetchRecorder!
        autoreleasepool {
            releasedAdView = delegate.adView
            fetch = startFetch(adUnit, connection: heldRequest.connection)
            delegate.adView = nil
        }
        XCTAssertNil(releasedAdView, "Sanity: the ad unit holds the ad view weakly")

        heldRequest.respond(with: BidResponseTransformer.someValidResponse, in: self)
        wait(for: [fetch.completed], timeout: 1)

        let bidInfo = fetch.results.first
        XCTAssertEqual(bidInfo?.resultCode, .prebidWrongArguments)
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31")
        assertNoBidAttached(bidInfo)
        XCTAssertNil(adUnit.lastCompletion, "Without the ad view there is nothing to refresh")
    }

    private func fetchBidInfo(_ adUnit: MediationBannerAdUnit, response: PrebidServerResponse) -> BidInfo? {
        let connection = MockServerConnection(onPost: [{ (url, data, timeout, callback) in
            callback(response)
        }])

        return fetchBidInfo(adUnit, connection: connection)
    }

    private func fetchBidInfo(_ adUnit: MediationBannerAdUnit, connection: PrebidServerConnectionProtocol) -> BidInfo? {
        let fetch = startFetch(adUnit, connection: connection)
        wait(for: [fetch.completed], timeout: 1)

        return fetch.results.first
    }

    /// Starts a fetch whose completion records every call. `completed` is fulfilled after
    /// `expectedCalls` calls; more calls fail the test.
    private func startFetch(
        _ adUnit: MediationBannerAdUnit,
        connection: PrebidServerConnectionProtocol,
        expectedCalls: Int = 1
    ) -> FetchRecorder {
        let fetch = FetchRecorder(expectedCalls: expectedCalls)

        adUnit.fetchDemandBidInfo(connection: connection,
                                  sdkConfiguration: getSDKConfiguration(),
                                  targeting: targeting)
        { bidInfo in
            XCTAssertTrue(Thread.isMainThread)
            fetch.record(bidInfo)
        }

        return fetch
    }

    /// Runs the main queue up to this point, so completions already dispatched to it have run.
    private func drainMainQueue() {
        let drained = XCTestExpectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 1)
    }

    private func assertWinningBidEconomics(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        // Values of `BidResponseTransformer.someValidResponse`
        XCTAssertEqual(bidInfo?.price?.doubleValue, 0.1091, file: file, line: line)
        XCTAssertEqual(bidInfo?.currency, "USD", file: file, line: line)
        XCTAssertEqual(bidInfo?.creativeId, "test-creative-id-1", file: file, line: line)
        XCTAssertEqual(bidInfo?.adId, "test-ad-id-12345", file: file, line: line)
        XCTAssertEqual(bidInfo?.requestId, "B4A2D3F4-41B6-4D37-B68B-EE8893E85C31", file: file, line: line)
    }

    private func assertNoBidAttached(_ bidInfo: BidInfo?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(bidInfo?.targetingKeywords, file: file, line: line)
        XCTAssertNil(bidInfo?.price, file: file, line: line)
        XCTAssertNil(bidInfo?.currency, file: file, line: line)
        XCTAssertNil(bidInfo?.creativeId, file: file, line: line)
        XCTAssertNil(bidInfo?.adId, file: file, line: line)
    }

    // MARK: - Auto-refresh vs. video creatives
    
    // The adapters hand the rendered `DisplayView` to AdMob / MAX, which embed it somewhere
    // inside the publisher's ad view. The gate must find it there and follow its playback state.
    func testRefreshIsSkippedWhileMediatedVideoIsPlaying() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        guard let mayRefreshNow = adUnit.autoRefreshManager?.mayRefreshNowBlock else {
            return XCTFail("The ad unit must own an AutoRefreshManager")
        }
        
        let window = UIWindow(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 480)))
        window.addSubview(adObject!)
        window.isHidden = false
        defer { window.isHidden = true }
        adUnit.lastAdView = adObject
        
        // An HTML creative, or nothing yet: refresh as usual
        let hostWrapper = UIView(frame: adObject!.bounds)
        adObject!.addSubview(hostWrapper)
        hostWrapper.addSubview(UIView(frame: hostWrapper.bounds))
        XCTAssertFalse(adUnit.isVideoPlaying)
        XCTAssertTrue(mayRefreshNow(), "Sanity: a visible ad object without a playing video may refresh")
        
        // The host SDK embeds the Prebid-rendered creative below its own wrapper views
        let displayView = DisplayView(frame: hostWrapper.bounds, bid: Bid(bid: ORTBBid(bidID: "", impid: "", price: 0.1)), configId: testID)
        hostWrapper.addSubview(displayView)
        
        displayView.videoAdDidStart()
        XCTAssertTrue(adUnit.isVideoPlaying)
        XCTAssertFalse(mayRefreshNow(), "A mediated video creative in flight must not be torn down by auto-refresh")
        
        displayView.videoAdDidFinish()
        XCTAssertFalse(adUnit.isVideoPlaying)
        XCTAssertTrue(mayRefreshNow(), "Once the video has finished the next tick must proceed")
    }
    
    func testVideoStateFollowsTheCreativeOnScreen() {
        let adUnit = MediationBannerAdUnit(configID: testID, size: primarySize, mediationDelegate: mediationDelegate!)
        adUnit.lastAdView = adObject
        
        let displayView = DisplayView(frame: adObject!.bounds, bid: Bid(bid: ORTBBid(bidID: "", impid: "", price: 0.1)), configId: testID)
        adObject!.addSubview(displayView)
        displayView.videoAdDidStart()
        XCTAssertTrue(adUnit.isVideoPlaying)
        
        // The host SDK replaces the creative (its own ad, or the next Prebid creative)
        displayView.removeFromSuperview()
        XCTAssertFalse(adUnit.isVideoPlaying, "A creative that is no longer on screen must not block refresh")
        
        // A new fetch cycle starts: nothing is tracked until a creative is on screen again
        adUnit.lastAdView = nil
        XCTAssertFalse(adUnit.isVideoPlaying)
    }
}

/// Records every call of a fetch completion.
private final class FetchRecorder {
    let firstCall = XCTestExpectation(description: "first completion call")
    let completed: XCTestExpectation
    private(set) var results: [BidInfo] = []
    private let expectedCalls: Int

    init(expectedCalls: Int) {
        self.expectedCalls = expectedCalls
        completed = XCTestExpectation(description: "completion called \(expectedCalls) time(s)")
    }

    func record(_ bidInfo: BidInfo) {
        results.append(bidInfo)

        if results.count == 1 {
            firstCall.fulfill()
        }
        if results.count == expectedCalls {
            completed.fulfill()
        }
        if results.count > expectedCalls {
            XCTFail("Unexpected completion call with \(bidInfo.resultCode.name())")
        }
    }
}

/// A connection that answers `responses` at once, then holds the next request until the test
/// answers it with `respond(with:in:)`. Holding a request keeps its fetch in progress.
private final class HeldRequest {
    private let sent = XCTestExpectation(description: "held bid request sent")
    private var hasWaitedForSend = false
    private(set) var connection: MockServerConnection!
    private var callback: PrebidServerResponseCallback?

    init(after responses: [PrebidServerResponse] = []) {
        var handlers: [MockServerConnection.PostHandler_NoContentType] = responses.map { response in
            { (url, data, timeout, callback) in callback(response) }
        }
        handlers.append { [weak self] (url, data, timeout, callback) in
            self?.callback = callback
            self?.sent.fulfill()
        }
        connection = MockServerConnection(onPost: handlers)
    }

    /// Waits until the held request has been sent. Can be called more than once.
    func waitUntilSent(in testCase: XCTestCase) {
        guard !hasWaitedForSend else {
            return
        }

        testCase.wait(for: [sent], timeout: 1)
        hasWaitedForSend = true
    }

    func respond(with response: PrebidServerResponse, in testCase: XCTestCase) {
        waitUntilSent(in: testCase)
        callback?(response)
    }
}

/// A mediation delegate whose ad view the test can replace or release.
private final class ReplaceableAdViewMediationDelegate: PrebidMediationDelegate {
    var adView: UIView?

    init(adView: UIView?) {
        self.adView = adView
    }

    func setUpAdObject(with values: [String: Any]) -> Bool { true }
    func cleanUpAdObject() {}
    func getAdView() -> UIView? { adView }
}
