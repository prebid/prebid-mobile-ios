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

@objcMembers
public class MediationBannerAdUnit : NSObject {
    
    var bidRequester: PBMBidRequester?
    // The view in which ad is displayed
    weak var adView: UIView?
    var completion: ((FetchDemandResult) -> Void)?
    
    weak var lastAdView: UIView?
    var lastCompletion: ((FetchDemandResult) -> Void)?
    
    var isRefreshStopped = false
    var autoRefreshManager: PBMAutoRefreshManager?
    
    var adRequestError: Error?
    
    var adUnitConfig: AdUnitConfig
    
    public let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Computed properties
    
    public var configID: String {
        adUnitConfig.configID
    }
    
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormat }
        set { adUnitConfig.adFormat = newValue }
    }
    
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    public var videoPlacementType: VideoPlacementType {
        get { VideoPlacementType(rawValue: adUnitConfig.videoPlacementType.rawValue) ?? .undefined }
        set { adUnitConfig.videoPlacementType = PBMVideoPlacementType(rawValue: newValue.rawValue) ?? .undefined }
    }
    
    // The feature is not available. Use original Prebid Native API
    // TODO: Merge Native engine from original SDK and rendering codebase
    var nativeAdConfig: NativeAdConfiguration? {
        get { adUnitConfig.nativeAdConfiguration }
        set { adUnitConfig.nativeAdConfiguration = newValue }
    }
    
    public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    // MARK: - Context Data
    
    public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addContextData(data, forKey: key)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateContextData(data, forKey: key)
    }
    
    public func removeContextDate(forKey key: String) {
        adUnitConfig.removeContextData(forKey: key)
    }
    
    public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    // MARK: - Public Methods
    
    public init(configID: String, size: CGSize, mediationDelegate: PrebidMediationDelegate) {
        adUnitConfig = AdUnitConfig(configID: configID, size: size)
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
            
            self.fetchDemand(connection: PBMServerConnection.shared,
                             sdkConfiguration: PrebidRenderingConfig.shared,
                             targeting: PrebidRenderingTargeting.shared,
                             completion: completion)
        })
    }
    
    public func fetchDemand(completion: ((FetchDemandResult)->Void)?) {
        
        fetchDemand(connection: PBMServerConnection.shared,
                    sdkConfiguration: PrebidRenderingConfig.shared,
                    targeting: PrebidRenderingTargeting.shared,
                    completion: completion)
    }
    
    public func stopRefresh() {
        isRefreshStopped = true
    }
    
    public func adObjectDidFailToLoadAd(adObject: UIView,
                                        with error: Error) {
        if adObject === self.adView || adObject === self.lastAdView {
            self.adRequestError = error
        }
    }
    
    // MARK: Private functions
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: PBMServerConnectionProtocol,
                     sdkConfiguration: PrebidRenderingConfig,
                     targeting: PrebidRenderingTargeting,
                     completion: ((FetchDemandResult)->Void)?) {
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
        
        bidRequester = PBMBidRequester(connection: connection,
                                       sdkConfiguration: sdkConfiguration,
                                       targeting: targeting,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { bidResponse, error in
            // Note: we have to run the completion on the main thread since
            // the handlePrebidResponse changes the MoPub object which is UIView
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
        guard let adObject = adView else {
            return false
        }

        return adObject.pbmIsVisible()
    }
    
    private func markLoadingFinished() {
        adView = nil
        completion = nil
        bidRequester = nil
    }
    
    private func handlePrebidResponse(response: BidResponseForRendering) {
        var demandResult = FetchDemandResult.demandNoBids
        
        if self.adView != nil,
           let winningBid = response.winningBid {
            if mediationDelegate.setUpAdObject(configID: configID,
                                               targetingInfo: winningBid.targetingInfo ?? [:],
                                               extrasObject: winningBid,
                                               for: PBMMediationAdUnitBidKey) {
                demandResult = .ok
            } else {
                demandResult = .wrongArguments
            }
        } else {
            PBMLog.error("The winning bid is absent in response!")
        }
        
        completeWithResult(demandResult)
    }
    
    private func handlePrebidError(error: Error?) {
        completeWithResult(PBMError.demandResult(from: error))
    }
    
    private func completeWithResult(_ fetchDemandResult: FetchDemandResult) {
        defer {
            markLoadingFinished()
        }
        
        guard let adObject = self .adView,
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
