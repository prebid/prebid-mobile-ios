//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

class BidRequesterImpl: NSObject, BidRequester {

    private typealias Completion = (BidResponse?, Error?) -> Void

    private let connection: PrebidServerConnectionProtocol
    private let sdkConfiguration: Prebid
    private let targeting: Targeting
    private let adUnitConfiguration: AdUnitConfig

    private let completionLock = NSLock()
    private var completion: Completion?

    required init(
        connection: PrebidServerConnectionProtocol,
        sdkConfiguration: Prebid,
        targeting: Targeting,
        adUnitConfiguration: AdUnitConfig
    ) {
        self.connection = connection
        self.sdkConfiguration = sdkConfiguration
        self.targeting = targeting
        self.adUnitConfiguration = adUnitConfiguration
        super.init()
    }

    func requestBids(completion: @escaping (BidResponse?, Error?) -> Void) {
        UserAgentService.shared.fetchUserAgent { [weak self] _ in
            self?.makeRequest(completion: completion)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func makeRequest(completion: @escaping Completion) {
        if let setupError = findErrorInSettings() {
            completion(nil, setupError)
            return
        }

        if isRequestInProgress {
            completion(nil, PBMError.requestInProgress())
            return
        }

        setCompletion(completion)

        let requestString = rtbRequest()

        let requestServerURL: String
        do {
            requestServerURL = try Host.shared.getHostURL()
        } catch {
            // Release the completion stored above, or every later request on this
            // instance fails with requestInProgress
            _ = takeCompletion()
            completion(nil, error)
            return
        }

        // `timeoutMillisDynamic` is stored in milliseconds (same unit as `timeoutMillis`),
        // so it must be converted to seconds before being used as a TimeInterval.
        let postTimeout: TimeInterval
        if let dynamicTimeout = sdkConfiguration.timeoutMillisDynamic {
            postTimeout = dynamicTimeout.doubleValue / 1000.0
        } else {
            postTimeout = TimeInterval(sdkConfiguration.timeoutMillis) / 1000.0
        }

        let rtbRequestData = requestString?.data(using: .utf8)

        let requestDate = Date()
        connection.post(requestServerURL, data: rtbRequestData, timeout: postTimeout) { [weak self] serverResponse in
            guard let self else { return }

            // Fix for GitHub Issue #1195: Thread-safe completion handling
            // Protect against duplicate callback invocations (redirects, retries, network bugs)
            guard let completion = self.takeCompletion() else {
                // Completion already called or nil - this is a duplicate callback
                Log.info("WARNING: Network callback invoked multiple times. Ignoring duplicate callback. Thread: \(Thread.current)")
                return
            }

            if serverResponse.statusCode == 204 {
                completion(nil, PBMError.blankResponse())
                return
            }

            if let error = serverResponse.error {
                Log.info("Bid Request Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            Log.info("Bid Response: \(String(data: serverResponse.rawData ?? Data(), encoding: .utf8) ?? "")")

            var bidResponse: BidResponse?
            var transformationError: Error?
            do {
                bidResponse = try BidResponseTransformer.transform(serverResponse)
            } catch {
                transformationError = error
            }

            if let bidResponse, let bidSelector = Registries.bidSelector.typed.active.first {
                self.completeWithSelectedBid(
                    in: bidResponse,
                    selector: bidSelector,
                    requestDate: requestDate,
                    requestServerURL: requestServerURL
                ) { bidResponse, error in
                    completion(bidResponse, error)
                    Prebid.shared.callEventDelegateAsync_prebidBidRequestDidFinishWith(
                        requestData: rtbRequestData,
                        responseData: serverResponse.rawData
                    )
                }
                return
            }

            if let bidResponse {
                // filterOutUncachedBids applies to Original API only. Rendering API renders
                // creatives directly from the bid's own markup and never depends on Prebid
                // Cache to display an ad, so a cache failure there is not a demand failure.
                if self.sdkConfiguration.filterOutUncachedBids
                    && self.adUnitConfiguration.adConfiguration.isOriginalAPI {
                    let bidCount = bidResponse.allBids?.count ?? 0
                    let removedBids = bidResponse.removeBidsWithoutSuccessfulCache()
                    if removedBids > 0 {
                        Log.warn("Ignored \(removedBids) bids without successful Prebid Cache entries.")
                    }
                    if bidResponse.topBidWasFiltered {
                        Log.warn("Top bid was filtered due to failed Prebid Cache entry; promoted next best cached bid.")
                    }
                    if bidResponse.winningBid == nil {
                        let error = bidCount > 0 && bidCount == removedBids ? PBMError.noCachedBids() : PBMError.noWinningBid()
                        completion(nil, error)
                        Prebid.shared.callEventDelegateAsync_prebidBidRequestDidFinishWith(
                            requestData: rtbRequestData,
                            responseData: serverResponse.rawData
                        )
                        return
                    }
                }

                self.updateTimeouts(from: bidResponse, requestDate: requestDate, requestServerURL: requestServerURL)
                self.applyPassthroughSDKConfiguration(from: bidResponse)
            }

            completion(bidResponse, transformationError)
            Prebid.shared.callEventDelegateAsync_prebidBidRequestDidFinishWith(
                requestData: rtbRequestData,
                responseData: serverResponse.rawData
            )
        }
    }

    /// Completes the request with the winner that `selector` chooses among the bids the ad unit can use.
    ///
    /// The selector is called once, on the main thread, and its decision is final: if it chooses no bid,
    /// a bid it wasn't given, or a bid without the targeting the ad unit needs, the request completes
    /// with an error and no bid wins. The SDK's default choice is never used.
    private func completeWithSelectedBid(
        in bidResponse: BidResponse,
        selector: PrebidBidSelecting,
        requestDate: Date,
        requestServerURL: String,
        completion: @escaping (BidResponse?, Error?) -> Void
    ) {
        let allBids = bidResponse.allBids ?? []
        
        // The same cache requirement as without a selector: filterOutUncachedBids applies to Original API
        // only, since Rendering API renders the bid's own markup.
        let requiresServerCache = sdkConfiguration.filterOutUncachedBids
            && adUnitConfiguration.adConfiguration.isOriginalAPI
        let eligibleBids = requiresServerCache ? allBids.filter(\.hasSuccessfulServerCache) : allBids
        
        if eligibleBids.count < allBids.count {
            Log.warn("Ignored \(allBids.count - eligibleBids.count) bids without successful Prebid Cache entries.")
        }
        
        guard !eligibleBids.isEmpty else {
            completion(nil, allBids.isEmpty ? PBMError.noWinningBid() : PBMError.noCachedBids())
            return
        }
        
        let context = BidSelectionContext(
            configId: adUnitConfiguration.configId,
            adFormats: adUnitConfiguration.adConfiguration.adFormats
        )
        let requiresAdServerTargeting = !adUnitConfiguration.adConfiguration.rendersWithoutAdServer
        
        // Holds self until the selection is done: the owner may release the requester once it gets a response.
        let select = { [self] in
            guard let selectedBid = selector.selectBid(from: eligibleBids, context: context) else {
                Log.info("[\(PluginCapability.bidSelector)] \(selector.pluginInfo) chose no bid.")
                completion(nil, PBMError.noWinningBid())
                return
            }
            
            guard eligibleBids.contains(where: { $0 === selectedBid }) else {
                Log.warn("[\(PluginCapability.bidSelector)] \(selector.pluginInfo) chose a bid that isn't one of the bids it was given. No bid wins.")
                completion(nil, PBMError.noWinningBid())
                return
            }
            
            switch SelectedBidTargeting.make(from: selectedBid.targetingInfo ?? [:]) {
            case .success(let targeting):
                selectedBid.selectedBidTargetingInfo = targeting
            case .failure(let failure) where requiresAdServerTargeting:
                Log.warn("[\(PluginCapability.bidSelector)] The bid that \(selector.pluginInfo) chose has no valid targeting: \(failure.message).")
                completion(nil, PBMError.invalidTargeting(failure.message))
                return
            case .failure:
                // The ad unit renders the bid itself and doesn't use its targeting
                break
            }
            
            if requiresAdServerTargeting && !selectedBid.isWinning {
                let reason = "it lacks one of \(TargetingKey.winningBidMarkers.joined(separator: ", "))"
                Log.warn("[\(PluginCapability.bidSelector)] The bid that \(selector.pluginInfo) chose has no valid targeting: \(reason).")
                selectedBid.selectedBidTargetingInfo = nil
                completion(nil, PBMError.invalidTargeting(reason))
                return
            }
            
            bidResponse.commitSelectedBid(selectedBid, from: eligibleBids)
            
            updateTimeouts(from: bidResponse, requestDate: requestDate, requestServerURL: requestServerURL)
            applyPassthroughSDKConfiguration(from: bidResponse)
            
            completion(bidResponse, nil)
        }
        
        if Thread.isMainThread {
            select()
        } else {
            DispatchQueue.main.async(execute: select)
        }
    }

    private func updateTimeouts(from bidResponse: BidResponse, requestDate: Date, requestServerURL: String) {
        guard let tmaxrequest = bidResponse.tmaxrequest else {
            return
        }

        let bidResponseTimeout = tmaxrequest.doubleValue / 1000.0
        let remoteTimeout = Date().timeIntervalSince(requestDate) + bidResponseTimeout + 0.2
        let currentServerURL = try? Host.shared.getHostURL()
        if sdkConfiguration.timeoutMillisDynamic == nil && currentServerURL == requestServerURL {
            let appTimeout = TimeInterval(sdkConfiguration.timeoutMillis) / 1000.0
            let updatedTimeout = min(remoteTimeout, appTimeout)
            // `timeoutMillisDynamic` must be stored in milliseconds (same unit as
            // `timeoutMillis`), so convert the seconds-based `updatedTimeout` back to ms.
            sdkConfiguration.timeoutMillisDynamic = NSNumber(value: updatedTimeout * 1000.0)
            sdkConfiguration.timeoutUpdated = true
        }
    }

    private func applyPassthroughSDKConfiguration(from bidResponse: BidResponse) {
        let passthrough = bidResponse.ext?.extPrebid?.passthrough?.first { $0.type == "prebidmobilesdk" }
        guard let pbsSDKConfig = passthrough?.sdkConfiguration else {
            return
        }

        if let cftBanner = pbsSDKConfig.cftBanner {
            Prebid.shared.creativeFactoryTimeout = cftBanner.doubleValue
        }

        if let cftPreRender = pbsSDKConfig.cftPreRender {
            Prebid.shared.creativeFactoryTimeoutPreRenderContent = cftPreRender.doubleValue
        }
    }

    private func rtbRequest() -> String? {
        let prebidParamsBuilder = PrebidParameterBuilder(
            adConfiguration: adUnitConfiguration,
            sdkConfiguration: sdkConfiguration,
            targeting: targeting,
            userAgentService: connection.userAgentService
        )

        let params = ParameterBuilderService.buildParamsDict(
            with: adUnitConfiguration.adConfiguration,
            extraParameterBuilders: [prebidParamsBuilder]
        )

        return params["openrtb"]
    }

    private func findErrorInSettings() -> NSError? {
        if adUnitConfiguration.adSize != .zero && isInvalidSize(adUnitConfiguration.adSize) {
            return PBMError.prebidInvalidSize()
        }
        if let additionalSizes = adUnitConfiguration.additionalSizes,
           additionalSizes.contains(where: isInvalidSize) {
            return PBMError.prebidInvalidSize()
        }
        if isInvalidID(adUnitConfiguration.configId) {
            return PBMError.prebidInvalidConfigId()
        }
        if isInvalidID(sdkConfiguration.prebidServerAccountId) {
            return PBMError.prebidInvalidAccountId()
        }
        return nil
    }

    private func isInvalidSize(_ size: CGSize) -> Bool {
        size.width < 0 || size.height < 0
    }

    private func isInvalidID(_ idString: String) -> Bool {
        idString.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Completion storage

    private var isRequestInProgress: Bool {
        completionLock.lock()
        defer { completionLock.unlock() }
        return completion != nil
    }

    private func setCompletion(_ newCompletion: @escaping Completion) {
        completionLock.lock()
        defer { completionLock.unlock() }
        completion = newCompletion
    }

    private func takeCompletion() -> Completion? {
        completionLock.lock()
        defer { completionLock.unlock() }
        let taken = completion
        completion = nil
        return taken
    }
}
