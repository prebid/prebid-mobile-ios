/*   Copyright 2018-2019 Prebid.org, Inc.
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

import UIKit
import ObjectiveC.runtime

/// Base class for ad units built for original type of integration.
@objcMembers
public class AdUnit: NSObject, DispatcherDelegate {
    
    /// ORTB: imp[].ext.data.pbadslot
    public var pbAdSlot: String? {
        get { adUnitConfig.getPbAdSlot()}
        set { adUnitConfig.setPbAdSlot(newValue) }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    var adSizes: [CGSize] {
        get { [adUnitConfig.adSize] + (adUnitConfig.additionalSizes ?? []) }
    }
    
    private static let PB_MIN_RefreshTime = 30000.0
    
    private(set) var dispatcher: Dispatcher?
    
    private(set) var adUnitConfig: AdUnitConfig
    
    private var bidRequester: BidRequesterProtocol
    
    /// This flag is set to check if the refresh needs to be made though the user has not invoked the fetch demand after initialization
    private var isInitialFetchDemandCallMade = false
    
    private var adServerObject: AnyObject?
    
    private var lastFetchDemandCompletion: ((_ bidInfo: BidInfo) -> Void)?
    
    /// notification flag set to check if the prebid response is received within the specified time
    private var didReceiveResponse = false
    
    /// notification flag set to determine if delegate call needs to be made after timeout delegate is sent
    private var timeOutSignalSent = false
    
    private(set) lazy var impressionTracker = PrebidImpressionTracker(
        isInterstitial: adUnitConfig.adConfiguration.isInterstitialAd
    )
    
    private(set) lazy var skadnStoreKitAdsHelper = PrebidStoreKitAdsHelper(
        isInterstitial: adUnitConfig.adConfiguration.isInterstitialAd
    )
    
    private let eventManager = EventManager()
    
    /// Initializes a new `AdUnit` instance with the specified configuration ID, size, and ad formats.
    ///
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - size: The primary size of the ad. If `nil`, a default size of `.zero` is used.
    ///   - adFormats: A set of ad formats supported by the ad unit.
    public init(configId: String, size: CGSize?, adFormats: Set<AdFormat>) {
        adUnitConfig = AdUnitConfig(configId: configId, size: size ?? CGSize.zero)
        adUnitConfig.adConfiguration.isOriginalAPI = true
        adUnitConfig.adFormats = adFormats
        
        bidRequester = Factory.createBidRequester(
            connection: PrebidServerConnection.shared,
            sdkConfiguration: Prebid.shared,
            targeting: Targeting.shared,
            adUnitConfiguration: adUnitConfig
        )
        
        super.init()
        
        // PBS should cache the bid for original api.
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
    }
    
    // Internal only!
    convenience init(
        bidRequester: BidRequesterProtocol,
        configId: String,
        size: CGSize?,
        adFormats: Set<AdFormat>
    ) {
        self.init(configId: configId, size: size, adFormats: adFormats)
        self.bidRequester = bidRequester
    }
    
    deinit {
        dispatcher?.invalidate()
        impressionTracker.stop()
    }
    
    // TODO: dynamic is used by tests
    
    /// Makes bid request  and provides the result as a `BidInfo` object.
    ///
    /// - Parameter completionBidInfo: A closure called with a `BidInfo` object representing the fetched demand.
    dynamic public func fetchDemand(completionBidInfo: @escaping (_ bidInfo: BidInfo) -> Void) {
        baseFetchDemand { bidInfo in
            DispatchQueue.main.async {
                completionBidInfo(bidInfo)
            }
        }
    }
    
    /// Makes bid request for a specific ad object and provides the result code. Setups targeting keywords into the adObject.
    ///
    /// - Parameters:
    ///   - adObject: The ad object for which demand is being fetched.
    ///   - completion: A closure called with the result code indicating the outcome of the demand fetch.
    dynamic public func fetchDemand(
        adObject: AnyObject,
        completion: @escaping(_ result: ResultCode) -> Void
    ) {
        baseFetchDemand(adObject: adObject) { bidInfo in
            DispatchQueue.main.async {
                completion(bidInfo.resultCode)
            }
        }
    }
    
    // SDK internal
    func baseFetchDemand(
        adObject: AnyObject? = nil,
        completion: @escaping (_ bidInfo: BidInfo) -> Void
    ) {
        if !(self is NativeRequest) {
            if adSizes.contains(where: { $0.width < 0 || $0.height < 0 }) {
                completion(BidInfo(resultCode: .prebidInvalidSize))
                return
            }
        }
        
        if let adObject {
            Utils.shared.removeHBKeywords(adObject: adObject)
        }
        
        if adUnitConfig.configId.isEmpty || adUnitConfig.configId.containsOnly(.whitespaces) {
            completion(BidInfo(resultCode: .prebidInvalidConfigId))
            return
        }
        
        if Prebid.shared.prebidServerAccountId.isEmpty || Prebid.shared.prebidServerAccountId.containsOnly(.whitespaces) {
            completion(BidInfo(resultCode: .prebidInvalidAccountId))
            return
        }
        
        if !isInitialFetchDemandCallMade {
            isInitialFetchDemandCallMade = true
            startDispatcher()
        }
        
        didReceiveResponse = false
        timeOutSignalSent = false
        lastFetchDemandCompletion = completion
        adServerObject = adObject
        
        let timeoutHandler = DispatchWorkItem {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(BidInfo(resultCode: .prebidDemandTimedOut))
                return
            }
        }
        
        bidRequester.requestBids { [weak self] bidResponse, error in
            timeoutHandler.cancel()

            guard let self = self else { return }
            self.didReceiveResponse = true
            
            guard let bidResponse = bidResponse else {
                if (!self.timeOutSignalSent) {
                    completion(BidInfo(resultCode: PBMError.demandResult(from: error)))
                }
                
                return
            }
            
            // Create a tracker for server event, f.e. firing `burl`
            let serverEventTracker = PrebidServerEventTracker()
            eventManager.registerTracker(serverEventTracker)
            
            // Register impression URLs
            let impServerEvents = bidResponse.winningBid?
                .impressionTrackingURLs
                .map { ServerEvent(url: $0, expectedEventType: .impression) } ?? []
            serverEventTracker.addServerEvents(impServerEvents)
            
            if #available(iOS 14.5, *) {
                if let skadn = bidResponse.winningBid?.skadn,
                   let imp = SkadnParametersManager.getSkadnImpression(for: skadn) {
                    let skadnEventTracker = SkadnEventTracker(with: imp)
                    eventManager.registerTracker(skadnEventTracker)
                }
            }
            
            let impressionTrackingPayload = PrebidImpressionTracker.Payload(
                cacheID: bidResponse.winningBid?.targetingInfo?["hb_cache_id"]
            )
            
            self.impressionTracker.register(payload: impressionTrackingPayload)
            self.impressionTracker.register(eventManager: eventManager)
            
            if (!self.timeOutSignalSent) {
                let resultCode = self.setUp(adObject, with: bidResponse)
                let bidInfo = BidInfo.create(resultCode: resultCode, bidResponse: bidResponse)
                completion(bidInfo)
            }
        }
        
        let timeout = Int(truncating: Prebid.shared.timeoutMillisDynamic ?? NSNumber(value: .PB_Request_Timeout))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timeout), execute: timeoutHandler)
    }
    
    func setUp(_ adObject: AnyObject?, with bidResponse: BidResponse) -> ResultCode {
        
        if Targeting.shared.forceSdkToChooseWinner {
            Log.error("Breaking change: set Targeting.forceSdkToChooseWinner = false and test your behavior. In the upcoming major release, the SDK will send all targeting keywords to the AdSever, so you should prepare your setup.")
        }

        guard let winningBid = bidResponse.winningBid else {
            
            //When the new behavior is active
            if !Targeting.shared.forceSdkToChooseWinner {
                
                if let adObject {
                    Utils.shared.validateAndAttachKeywords(adObject: adObject, bidResponse: bidResponse)
                }
                //If there are no winning bids, but there are bids the SDK will send back prebidDemandFetchSuccess
                if let bids = bidResponse.allBids, !bids.isEmpty {
                    return .prebidDemandFetchSuccess
                }
            }
            return .prebidDemandNoBids
        }

        if let cacheId = cacheBidIfNeeded(winningBid) {
            bidResponse.addTargetingInfoValue(key: PrebidLocalCacheIdKey, value: cacheId)
        }
        
        if let adObject {
            Utils.shared.validateAndAttachKeywords(adObject: adObject, bidResponse: bidResponse)
        }
        
        return .prebidDemandFetchSuccess
    }
    
    private func cacheBidIfNeeded(_ winningBid: Bid) -> String? {
        let isNative = winningBid.adFormat == .native
        let isSkadnPresent = winningBid.skadn != nil && SkadnParametersManager
            .getSkadnProductParameters(for: winningBid.skadn!) != nil
        
        guard isNative || isSkadnPresent else {
            return nil
        }
        
        let expireInterval = TimeInterval(
            truncating: winningBid.bid.exp ?? CacheManager.cacheManagerExpireInterval as NSNumber
        )
        
        do {
            if let cacheId = CacheManager.shared.save(
                content: try winningBid.bid.toJsonString(),
                expireInterval: expireInterval
            ), !cacheId.isEmpty {
                return cacheId
            }
        } catch {
            Log.error("Error saving bid content to cache: \(error.localizedDescription)")
        }
        
        return nil
    }
        
    // MARK: GPID
    
    /// Sets the GPID for the ad unit.
    ///
    /// - Parameter gpid: The GPID string to set. Can be `nil` to clear the GPID.
    public func setGPID(_ gpid: String?) {
        adUnitConfig.gpid = gpid
    }
    
    /// Retrieves the current GPID for the ad unit.
    ///
    /// - Returns: The GPID string, or `nil` if no GPID is set.
    public func getGPID() -> String? {
        return adUnitConfig.gpid
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
    }
    
    // MARK: - Others
    
    
     /// This method allows to set the auto refresh period for the demand
     /// - Parameter time: refresh time interval
    public func setAutoRefreshMillis(time: Double) {
        
        guard checkRefreshTime(time) else {
            Log.error("auto refresh not set as the refresh time is less than to \(AdUnit.PB_MIN_RefreshTime as Double) milliseconds")
            return
        }
        
        if dispatcher?.state == .stopped {
            dispatcher?.setAutoRefreshMillis(time: time)
            return
        }
        
        stopDispatcher()
        
        initDispatcher(refreshTime: time)
        
        if isInitialFetchDemandCallMade {
            startDispatcher()
        }
    }
    
    /// This method stops the auto refresh of demand
    public func stopAutoRefresh() {
        stopDispatcher()
    }
    
    /// This method resumes the auto refresh of demand
    public func resumeAutoRefresh() {
        if dispatcher?.state == .stopped {
            if isInitialFetchDemandCallMade {
                startDispatcher()
            }
        }
    }
    
    dynamic func checkRefreshTime(_ time: Double) -> Bool {
        return time >= AdUnit.PB_MIN_RefreshTime
    }
    
    func refreshDemand() {
        if let lastFetchDemandCompletion = lastFetchDemandCompletion {
            baseFetchDemand(adObject: adServerObject, completion: lastFetchDemandCompletion)
        }
    }
    
    func initDispatcher(refreshTime: Double) {
        dispatcher = Dispatcher.init(withDelegate: self, autoRefreshMillies: refreshTime)
    }
    
    func startDispatcher() {
        guard let dispatcher = self.dispatcher else {
            Log.verbose("Dispatcher is nil")
            return
        }
        
        dispatcher.start()
    }
    
    func stopDispatcher() {
        guard let dispatcher = self.dispatcher else {
            Log.verbose("Dispatcher is nil")
            return
        }
        
        dispatcher.stop()
    }
}

