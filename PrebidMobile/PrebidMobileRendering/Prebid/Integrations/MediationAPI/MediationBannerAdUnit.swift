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
    var completion: ((ResultCode) -> Void)?
    
    weak var lastAdView: UIView?
    var lastCompletion: ((ResultCode) -> Void)?
    
    var isRefreshStopped = false
    var autoRefreshManager: PBMAutoRefreshManager?
    
    var adRequestError: Error?
    
    var adUnitConfig: AdUnitConfig
    
    /// Property that performs certain utilty work for the `MediationBannerAdUnit`
    public let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Computed properties
    
    /// The configuration ID for an ad unit
    public var configID: String {
        adUnitConfig.configId
    }
    
    /// The ad format for the ad unit.
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormats.first ?? .banner }
        set { adUnitConfig.adFormats = [newValue] }
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
    
    // MARK: Arbitrary ORTB Configuration
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The  impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
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
        
        autoRefreshManager = PBMAutoRefreshManager(prefetchTime: PBMAdPrefetchTime,
                                                   locking: nil,
                                                   lockProvider: nil,
                                                   refreshDelay: { [weak self] in
            (self?.adUnitConfig.refreshInterval ?? 0) as NSNumber
        },
                                                   mayRefreshNowBlock: { [weak self] in
            guard let self = self else { return false }
            return self.isAdObjectVisible() || self.adRequestError != nil
        }, refreshBlock: { [weak self] in
            guard let self = self,
                  self.lastAdView != nil,
                  let completion = self.lastCompletion else {
                return
            }
            
            self.fetchDemand(connection: PrebidServerConnection.shared,
                             sdkConfiguration: Prebid.shared,
                             targeting: Targeting.shared,
                             completion: completion)
        })
    }
    
    /// Makes bid request and setups mediation parameters.
    /// - Parameter completion: The completion handler to call when the demand fetch is complete.
    public func fetchDemand(completion: ((ResultCode)->Void)?) {
        
        fetchDemand(connection: PrebidServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    completion: completion)
    }
    
    /// Stops the auto-refresh for the ad unit.
    public func stopRefresh() {
        isRefreshStopped = true
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
    
    // MARK: Private functions
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: PrebidServerConnectionProtocol,
                     sdkConfiguration: Prebid,
                     targeting: Targeting,
                     completion: ((ResultCode)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        autoRefreshManager?.cancelRefreshTimer()
        
        if isRefreshStopped {
            return
        }
        
        self.adView = mediationDelegate.getAdView()
        self.completion = completion
        
        lastAdView = nil
        lastCompletion = nil
        adRequestError = nil
        
        mediationDelegate.cleanUpAdObject()
        
        bidRequester = Factory.BidRequester(connection: connection,
                                            sdkConfiguration: sdkConfiguration,
                                            targeting: targeting,
                                            adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { bidResponse, error in
            // Note: we have to run the completion on the main thread since
            // the handlePrebidResponse changes the Primary SDK Object which is UIView
            // This point to switch the context to the main thread looks the most accurate.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.isRefreshStopped {
                    self.markLoadingFinished()
                    return
                }
                
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
        
        return adObject.pbmIsVisible()
    }
    
    private func markLoadingFinished() {
        adView = nil
        completion = nil
        bidRequester = nil
    }
    
    private func handlePrebidResponse(response: BidResponse) {
        var demandResult = ResultCode.prebidDemandNoBids
        
        if self.adView != nil, let winningBid = response.winningBid, let targetingInfo = response.targetingInfo {
            
            let adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: configID,
                PBMMediationTargetingInfoKey: targetingInfo,
                PBMMediationAdUnitBidKey: winningBid
            ]
            
            if mediationDelegate.setUpAdObject(with: adObjectSetupDictionary) {
                demandResult = .prebidDemandFetchSuccess
            } else {
                demandResult = .prebidWrongArguments
            }    
        } else {
            Log.error("The winning bid is absent in response!")
        }
        
        completeWithResult(demandResult)
    }
    
    private func handlePrebidError(error: Error?) {
        completeWithResult(PBMError.demandResult(from: error))
    }
    
    private func completeWithResult(_ fetchDemandResult: ResultCode) {
        defer {
            markLoadingFinished()
        }
        
        guard let adObject = self.adView,
              let completion = self.completion else {
            return
        }
        
        lastAdView = adObject
        lastCompletion = completion
        
        autoRefreshManager?.setupRefreshTimer()
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
}
