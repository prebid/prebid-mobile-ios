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
import UIKit

/// This class is responsible for making bid request and providing the winning bid and targeting keywords to mediating SDKs.
/// This class is a part of Mediation API.
@objcMembers
public class MediationBannerAdUnit : NSObject {
    
    var bidRequester: BidRequester?
    // The view in which ad is displayed
    weak var adView: UIView?
    var completion: ((BidInfo) -> Void)?

    weak var lastAdView: UIView?
    var lastCompletion: ((BidInfo) -> Void)?
    
    var isRefreshStopped = false
    var autoRefreshManager: AutoRefreshManager?
    
    // The connection and SDK configuration of the last explicit fetch, reused by auto-refresh.
    // The public fetch methods always pass the shared instances; unit tests pass mocks.
    private var refreshConnection: PrebidServerConnectionProtocol = PrebidServerConnection.shared
    private var refreshSDKConfiguration: Prebid = .shared
    
    var adRequestError: Error?
    
    var adUnitConfig: AdUnitConfig
    
    /// Property that performs certain utilty work for the `MediationBannerAdUnit`
    public let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Computed properties
    
    /// The configuration ID for an ad unit
    public var configID: String {
        adUnitConfig.configId
    }
    
    /// The set of ad formats requested for this ad unit.
    ///
    /// Defaults to `[.banner]`. Set `[.video]` for an outstream video banner, or
    /// `[.banner, .video]` for a multiformat request.
    ///
    /// Only `.banner` and `.video` can be rendered by the banner mediation adapters.
    public var adFormats: Set<AdFormat> {
        get { adUnitConfig.adFormats }
        set {
            guard let formats = AdFormat.validated(newValue, supported: Self.supportedAdFormats) else {
                return
            }
            
            adUnitConfig.adFormats = formats
        }
    }
    
    
    /// The ad format for the ad unit.
    ///
    /// - Note: Deprecated. Use `adFormats` instead, which supports multiformat requests.
    ///   Assigning goes through `adFormats`, so unsupported values such as `.native`
    ///   are ignored with a warning.
    @available(*, deprecated, message: "Use `adFormats` instead.")
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormats.first ?? .banner }
        set { adFormats = [newValue] }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    /// Parameters for configuring banner ads.
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    /// Parameters for configuring video ads.
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    /// The refresh interval for the ad.
    public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    /// Additional sizes for the ad unit.
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    /// Whether an outstream video creative starts muted. Defaults to `false`.
    ///
    /// Sent to the Prebid banner adapter with every winning video bid, so the value also applies
    /// to auto-refreshed ads. The user can still unmute the creative on screen; that does not
    /// change this setting. A server-side `ismuted` in the bid response
    /// (`ext.prebid.passthrough[].adconfiguration`) overrides this value for that ad only. Has no
    /// effect on HTML banners or on ads the mediated SDK renders itself.
    public var isMuted: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isMuted }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isMuted = newValue }
    }
    
    /// Whether an outstream video creative shows a mute/unmute button. Defaults to `false`.
    ///
    /// Sent to the Prebid banner adapter with every winning video bid, so the value also applies
    /// to auto-refreshed ads. Has no effect on HTML banners or on ads the mediated SDK renders itself.
    public var isSoundButtonVisible: Bool {
        get { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible }
        set { adUnitConfig.adConfiguration.videoControlsConfig.isSoundButtonVisible = newValue }
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbConfig: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
    }
    
    /// Sets the global OpenRTB configuration string for the ad unit. It takes precedence over `Targeting.setGlobalOrtbConfig`.
    ///
    /// - Parameter ortbConfig: The global OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setGlobalORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.globalORTBConfig = ortbConfig
    }
    
    /// Returns the global OpenRTB configuration string.
    public func getGlobalORTBConfig() -> String? {
        adUnitConfig.globalORTBConfig
    }
    
    // MARK: - Public Methods
    
    /// Initializes a new mediation banner ad unit with the specified configuration ID, size, and mediation delegate.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    /// - Parameter size: The size of the ad.
    /// - Parameter mediationDelegate: The delegate for handling mediation.
    public init(configID: String, size: CGSize, mediationDelegate: PrebidMediationDelegate) {
        adUnitConfig = AdUnitConfig(configId: configID, size: size)
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals
        
        self.mediationDelegate = mediationDelegate
        super.init()
        
        autoRefreshManager = AutoRefreshManager(
            prefetchTime: PrebidConstants.AD_PREFETCH_TIME,
            lockingQueue: nil,
            lockProvider: nil,
            refreshDelayBlock: { [weak self] in
                (self?.adUnitConfig.refreshInterval ?? 0) as NSNumber
            },
            mayRefreshNowBlock: { [weak self] in
                (self?.isAdObjectVisible() == true && self?.isVideoPlaying == false) || self?.adRequestError != nil
            },
            refreshBlock: { [weak self] in
                self?.refreshDemand()
            }
        )
    }

    /// Makes bid request and setups mediation parameters.
    ///
    /// If another fetch for this ad unit, an auto-refresh included, is still in progress, `completion`
    /// is called at once with `.prebidSDKMisusePreviousFetchNotCompletedYet` and that fetch continues.
    /// - Parameter completion: The completion handler to call when the demand fetch is complete.
    public func fetchDemand(completion: ((ResultCode)->Void)?) {

        fetchDemand(connection: PrebidServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    completion: completion)
    }

    /// Makes bid request and setups mediation parameters. Like `fetchDemand(completion:)`, but provides
    /// the full `BidInfo` (including the winning-bid economics) instead of only the result code.
    ///
    /// With auto-refresh enabled, `completion` is called again on every refresh.
    ///
    /// If another fetch for this ad unit, an auto-refresh included, is still in progress, `completion`
    /// is called at once with `.prebidSDKMisusePreviousFetchNotCompletedYet` and that fetch continues.
    /// - Parameter completion: A closure called with a `BidInfo` object representing the fetched demand.
    public func fetchDemandBidInfo(completion: @escaping (_ bidInfo: BidInfo) -> Void) {
        fetchDemandBidInfo(
            connection: PrebidServerConnection.shared,
            sdkConfiguration: Prebid.shared,
            targeting: Targeting.shared,
            completion: completion
        )
    }
    
    /// Stops the auto-refresh for the ad unit.
    ///
    /// Cancels the pending refresh. A fetch that is in progress still calls its completion, but does
    /// not schedule another refresh. `fetchDemand(completion:)` and `fetchDemandBidInfo(completion:)`
    /// keep working, and the next one turns auto-refresh back on. To turn it back on without
    /// fetching, call `resumeRefresh()`.
    public func stopRefresh() {
        isRefreshStopped = true
        autoRefreshManager?.cancelRefreshTimer()
    }
    
    /// Resumes the auto-refresh stopped by `stopRefresh()`.
    ///
    /// Schedules the next refresh of the last completed fetch. If no fetch has completed with a
    /// completion yet, auto-refresh starts with the next one. Has no effect if auto-refresh is not
    /// stopped.
    public func resumeRefresh() {
        guard isRefreshStopped else {
            return
        }
        
        isRefreshStopped = false
        
        // A fetch in progress schedules the refresh itself when it completes.
        if bidRequester == nil, lastAdView != nil, lastCompletion != nil {
            autoRefreshManager?.setupRefreshTimer()
        }
    }
    
    /// Handles the event when the ad object fails to load an ad.
    /// - Parameter adObject: The ad object that failed to load the ad.
    /// - Parameter error: The error that occurred during the ad load.
    public func adObjectDidFailToLoadAd(adObject: UIView,
                                        with error: Error) {
        if adObject === self.adView || adObject === self.lastAdView {
            self.adRequestError = error
        }
    }
    
    // MARK: - Private Properties
    
    /// Formats that the banner mediation adapters are able to render.
    private static let supportedAdFormats: [AdFormat] = [.banner, .video]
    
    /// Whether a Prebid video creative rendered inside the mediated ad view is playing.
    ///
    /// The adapters hand the `DisplayView` they render to the host SDK, which embeds it in the
    /// ad view returned by `PrebidMediationDelegate.getAdView()`. Reading the state off that
    /// view on every refresh tick means the gate follows whatever is actually on screen: it
    /// clears when the video finishes or when the host SDK replaces the creative.
    var isVideoPlaying: Bool {
        lastAdView?.firstDescendant(of: DisplayView.self)?.isVideoPlaying ?? false
    }
    
    // MARK: Private functions
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(
        connection: PrebidServerConnectionProtocol,
        sdkConfiguration: Prebid,
        targeting: Targeting,
        completion: ((ResultCode) -> Void)?
    ) {
        fetchDemandBidInfo(
            connection: connection,
            sdkConfiguration: sdkConfiguration,
            targeting: targeting,
            completion: completion.map { completion in { completion($0.resultCode) } }
        )
    }

    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemandBidInfo(
        connection: PrebidServerConnectionProtocol,
        sdkConfiguration: Prebid,
        targeting: Targeting,
        completion: ((BidInfo) -> Void)?
    ) {
        guard bidRequester == nil else {
            // The running fetch keeps its own completion and is left alone.
            Log.warn("The previous fetch for this ad unit has not completed yet. This call is ignored.")
            deliver(BidInfo(resultCode: .prebidSDKMisusePreviousFetchNotCompletedYet), to: completion)
            return
        }
        
        // An explicit fetch turns auto-refresh back on after `stopRefresh()`.
        isRefreshStopped = false
        refreshConnection = connection
        refreshSDKConfiguration = sdkConfiguration
        
        requestBids(connection: connection,
                    sdkConfiguration: sdkConfiguration,
                    targeting: targeting,
                    completion: completion)
    }
    
    private func refreshDemand() {
        // A fetch clears the stored completion when it starts, so a tick that finds one in progress
        // stops here. It is skipped silently: the app's completion only hears about requests that ran.
        guard !isRefreshStopped,
              bidRequester == nil,
              lastAdView != nil,
              let completion = lastCompletion else {
            return
        }
        
        requestBids(connection: refreshConnection,
                    sdkConfiguration: refreshSDKConfiguration,
                    targeting: Targeting.shared,
                    completion: completion)
    }
    
    private func requestBids(
        connection: PrebidServerConnectionProtocol,
        sdkConfiguration: Prebid,
        targeting: Targeting,
        completion: ((BidInfo) -> Void)?
    ) {
        autoRefreshManager?.cancelRefreshTimer()
        
        lastAdView = nil
        lastCompletion = nil
        adRequestError = nil
        
        guard let adView = mediationDelegate.getAdView() else {
            Log.error("The mediation delegate returned no ad view, so the bid cannot be attached to it.")
            deliver(BidInfo(resultCode: .prebidWrongArguments), to: completion)
            return
        }
        
        self.adView = adView
        self.completion = completion
        
        mediationDelegate.cleanUpAdObject()
        
        bidRequester = Factory.createBidRequester(connection: connection,
                                                  sdkConfiguration: sdkConfiguration,
                                                  targeting: targeting,
                                                  adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { bidResponse, error in
            // Note: we have to run the completion on the main thread since
            // the handlePrebidResponse changes the Primary SDK Object which is UIView
            // This point to switch the context to the main thread looks the most accurate.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if let response = bidResponse {
                    self.handlePrebidResponse(response: response)
                } else {
                    self.handlePrebidError(error: error)
                }
            }
        })
    }
    
    private func isAdObjectVisible() -> Bool {
        guard let adObject = lastAdView else {
            return false
        }
        
        return adObject.isVisible()
    }
    
    private func markLoadingFinished() {
        adView = nil
        completion = nil
        bidRequester = nil
    }
    
    private func handlePrebidResponse(response: BidResponse) {
        // The ad view is held weakly, so it can be gone by the time the response arrives.
        guard adView != nil else {
            Log.error("The ad view was released before the bid response arrived.")
            completeWithResult(BidInfo.create(resultCode: .prebidWrongArguments, requestId: response.rawResponse?.requestID))
            return
        }
        
        var demandResult = ResultCode.prebidDemandNoBids
        
        if let winningBid = response.winningBid, let targetingInfo = response.targetingInfo {
            
            var adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: configID,
                PBMMediationTargetingInfoKey: targetingInfo,
                PBMMediationAdUnitBidKey: winningBid
            ]
            
            if winningBid.adFormat == .video {
                adObjectSetupDictionary[PBMMediationVideoAdConfiguration] = adUnitConfig.adConfiguration.videoControlsConfig
            }
            
            if mediationDelegate.setUpAdObject(with: adObjectSetupDictionary) {
                demandResult = .prebidDemandFetchSuccess
            } else {
                demandResult = .prebidWrongArguments
            }    
        } else {
            Log.error("The winning bid is absent in response!")
        }

        let bidInfo = demandResult == .prebidWrongArguments
            ? BidInfo.create(resultCode: demandResult, requestId: response.rawResponse?.requestID)
            : BidInfo.create(resultCode: demandResult, bidResponse: response)
        
        completeWithResult(bidInfo)
    }

    private func handlePrebidError(error: Error?) {
        completeWithResult(BidInfo(resultCode: PBMError.demandResult(from: error)))
    }

    private func completeWithResult(_ bidInfo: BidInfo) {
        let adObject = self.adView
        let completion = self.completion
        
        markLoadingFinished()
        
        // Without the ad view there is nothing to refresh, but the call still gets its result.
        if let adObject, let completion {
            lastAdView = adObject
            lastCompletion = completion
            
            // A fetch that was in progress when `stopRefresh()` was called does not schedule another refresh.
            if !isRefreshStopped {
                autoRefreshManager?.setupRefreshTimer()
            }
        }
        
        deliver(bidInfo, to: completion)
    }
    
    private func deliver(_ bidInfo: BidInfo, to completion: ((BidInfo) -> Void)?) {
        guard let completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(bidInfo)
        }
    }
}
