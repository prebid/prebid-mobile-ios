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

public class MoPubBannerAdUnit : NSObject {
    
    var bidRequester: PBMBidRequester?
    //This is an MPAdView object
    //But we can't use it indirectly as don't want to have additional MoPub dependency in the SDK core
    weak var adObject: NSObject?
    var completion: ((FetchDemandResult) -> Void)?

    weak var lastAdObject: NSObject?
    var lastCompletion: ((FetchDemandResult) -> Void)?

    var isRefreshStopped = false
    var autoRefreshManager: PBMAutoRefreshManager?

    var  adRequestError: Error?
    
    var adUnitConfig: AdUnitConfig
    
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

    public var nativeAdConfig: NativeAdConfiguration? {
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
    
    public init(configID: String, size: CGSize) {
        adUnitConfig = AdUnitConfig(configID: configID, size: size)
        
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
                                                          let adObject = self.lastAdObject,
                                                          let completion = self.lastCompletion else {
                                                        return
                                                    }
                                                    
                                                    self.fetchDemand(with: adObject,
                                                                     connection: PBMServerConnection.shared,
                                                                     sdkConfiguration: PrebidRenderingConfig.shared,
                                                                     targeting: PrebidRenderingTargeting.shared,
                                                                     completion: completion)
                                                   })
    }
    
    public func fetchDemand(with adObject: NSObject,
                            completion: ((FetchDemandResult)->Void)?) {
        
        fetchDemand(with: adObject,
                    connection: PBMServerConnection.shared,
                    sdkConfiguration: PrebidRenderingConfig.shared,
                    targeting: PrebidRenderingTargeting.shared,
                    completion: completion)
    }
    
    public func stopRefresh() {
        isRefreshStopped = true
    }

    public func adObjectDidFailToLoadAd(adObject: NSObject,
                                        with error: Error) {
        if adObject === self.adObject || adObject === self.lastAdObject {
            self.adRequestError = error;
        }
    }

    // MARK: Private functions
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(with adObject: NSObject,
                             connection: PBMServerConnectionProtocol,
                             sdkConfiguration: PrebidRenderingConfig,
                             targeting: PrebidRenderingTargeting,
                             completion: ((FetchDemandResult)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        guard MoPubUtils.isCorrectAdObject(adObject) else {
            completion?(.wrongArguments)
            return;
        }
        
        autoRefreshManager?.cancelRefreshTimer()
        
        if isRefreshStopped {
            return
        }
        
        self.adObject = adObject
        self.completion = completion
        
        lastAdObject = nil
        lastCompletion = nil
        adRequestError = nil
        
        MoPubUtils.cleanUpAdObject(adObject)
        
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
        if let adObject = lastAdObject as? UIView {
            return adObject.pbmIsVisible()
        }
        
        return true;
    }
    
    private func markLoadingFinished() {
        adObject = nil;
        completion = nil;
        bidRequester = nil;
    }
    
    private func handlePrebidResponse(response: BidResponseForRendering) {
        var demandResult = FetchDemandResult.demandNoBids
        
        if  let adObject = self.adObject,
            let winningBid = response.winningBid {
            if MoPubUtils.setUpAdObject(adObject,
                                        configID: configID,
                                        targetingInfo: winningBid.targetingInfo ?? [:],
                                        extraObject: winningBid,
                                        forKey: PBMMoPubAdUnitBidKey) {
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
        
        guard let adObject = self .adObject,
              let completion = self.completion else {
            return
        }
        
        lastAdObject = adObject
        lastCompletion = completion
        
        autoRefreshManager?.setupRefreshTimer()
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
}
